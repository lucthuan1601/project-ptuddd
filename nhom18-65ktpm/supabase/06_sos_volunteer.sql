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
