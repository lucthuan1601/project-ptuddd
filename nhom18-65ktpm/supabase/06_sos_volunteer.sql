-- 06_sos_volunteer.sql
-- Bổ sung cho SOS (UC-07, UC-12), tình nguyện viên (UC-11, UC-13) và thông báo FCM.
-- Chạy sau 05_seed.sql. Chạy lại nhiều lần không lỗi.

-- ============================================================
-- 1. Realtime cho sos_requests
-- Rider theo dõi ca của mình, người nhận theo dõi ca mới / ca đang xử lý.
-- ============================================================
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
     and not exists (
       select 1
         from pg_publication_tables
        where pubname = 'supabase_realtime'
          and schemaname = 'public'
          and tablename = 'sos_requests'
     ) then
    alter publication supabase_realtime add table public.sos_requests;
  end if;
end $$;

-- ============================================================
-- 2. Sửa trigger bảo vệ cột trong 03_functions.sql
-- Hàm security definer luôn thấy current_user = postgres nên điều kiện
-- "current_user in (authenticated, anon)" không bao giờ đúng: client tự đổi
-- được role/status/rating. Chạy với quyền người gọi thì trigger mới có tác dụng.
-- ============================================================
alter function public.protect_user_columns() security invoker;
alter function public.protect_shop_columns() security invoker;

-- ============================================================
-- 3. Quy tắc hồ sơ tình nguyện viên (UC-11, UC-13)
-- Thay hàm cùng tên trong 03_functions.sql (trigger cũ tự dùng bản mới),
-- chạy với quyền người gọi giống mục 2.
-- - Đổi SĐT / giấy tờ khi đã duyệt -> chờ duyệt lại.
-- - Hồ sơ bị từ chối mà sửa lại -> gửi duyệt lại.
-- - Không tắt "sẵn sàng" khi đang có ca SOS chưa hoàn thành.
-- - Hồ sơ chưa duyệt / bị khóa thì không được ở trạng thái sẵn sàng.
-- ============================================================
create or replace function public.protect_volunteer_columns()
returns trigger
language plpgsql
security invoker
set search_path = public, extensions
as $$
begin
  if current_user::text in ('authenticated', 'anon') and not public.is_admin() then
    new.user_id := old.user_id;
    new.status := old.status;
    new.completed_count := old.completed_count;
    new.created_at := old.created_at;

    if old.status = 'rejected' then
      new.status := 'pending';
    elsif old.status = 'approved'
       and (new.phone is distinct from old.phone
            or new.id_card_url is distinct from old.id_card_url) then
      new.status := 'pending';
    end if;

    if old.is_available and not new.is_available and exists (
      select 1
        from public.sos_requests
       where accepted_volunteer_id = old.id
         and status = 'accepted'
    ) then
      raise exception 'Vui lòng hoàn thành ca cứu hộ đang xử lý trước khi tạm nghỉ';
    end if;
  end if;

  if new.status <> 'approved' then
    new.is_available := false;
  end if;

  return new;
end;
$$;

-- ============================================================
-- 4. Khóa ca: mỗi tiệm / TNV chỉ xử lý một ca tại một thời điểm (UC-12)
-- Thay accept_sos trong 03_functions.sql (giữ nguyên chữ ký hàm).
-- ============================================================
create unique index if not exists sos_one_active_shop
  on public.sos_requests (accepted_shop_id)
  where status = 'accepted';

create unique index if not exists sos_one_active_volunteer
  on public.sos_requests (accepted_volunteer_id)
  where status = 'accepted';

create or replace function public.accept_sos(
  p_sos_id uuid,
  p_shop_id uuid default null,
  p_volunteer_id uuid default null
)
returns public.sos_requests
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_row public.sos_requests;
begin
  if (p_shop_id is null) = (p_volunteer_id is null) then
    raise exception 'Phải truyền đúng một trong p_shop_id hoặc p_volunteer_id';
  end if;

  if exists (
    select 1 from public.users where id = auth.uid() and status = 'banned'
  ) then
    raise exception 'Tài khoản của bạn đã bị khóa';
  end if;

  if p_shop_id is not null and not exists (
    select 1 from public.shops
     where id = p_shop_id
       and owner_id = auth.uid()
       and status = 'approved'
       and is_open
  ) then
    raise exception 'Bạn không sở hữu tiệm này, tiệm chưa được duyệt hoặc đang đóng cửa';
  end if;

  if p_volunteer_id is not null and not exists (
    select 1 from public.volunteer_profiles
     where id = p_volunteer_id
       and user_id = auth.uid()
       and status = 'approved'
       and is_available
  ) then
    raise exception 'Hồ sơ tình nguyện viên chưa được duyệt hoặc chưa sẵn sàng';
  end if;

  if exists (
    select 1 from public.sos_requests
     where status = 'accepted'
       and (accepted_shop_id = p_shop_id or accepted_volunteer_id = p_volunteer_id)
  ) then
    raise exception 'Bạn đang xử lý một ca cứu hộ khác, hãy hoàn thành ca đó trước';
  end if;

  begin
    -- Câu lệnh có điều kiện status = 'pending': người thứ hai UPDATE sẽ không khớp dòng nào.
    update public.sos_requests
       set status = 'accepted',
           accepted_shop_id = p_shop_id,
           accepted_volunteer_id = p_volunteer_id
     where id = p_sos_id
       and status = 'pending'
       and rider_id <> auth.uid()
    returning * into v_row;
  exception
    -- Hai lần nhận gần như đồng thời của cùng một người: index unique chặn lại.
    when unique_violation then
      raise exception 'Bạn đang xử lý một ca cứu hộ khác, hãy hoàn thành ca đó trước';
  end;

  if v_row.id is null then
    raise exception 'Ca cứu hộ đã được người khác nhận hoặc không còn hiệu lực';
  end if;

  return v_row;
end;
$$;
