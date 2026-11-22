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
