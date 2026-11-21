# Đặc Tả Use Case UC-08 Đến UC-15

- **Nhóm:** Nhóm 18 – 65KTPM
- **Đề tài:** Ứng dụng Kết nối Cứu hộ & Tình nguyện Xe máy
- **Người thực hiện:** Hoàng Tùng (2351170630)
- **Phạm vi:** UC-08 → UC-15 (phần tiếp nối UC-01 → UC-07)

**Quy ước chung cho bảng Đầu vào / Đầu ra:**

- **Nguồn** của đầu vào: *Người dùng nhập* (form/thao tác trên UI), *Hệ thống* (lấy tự động từ phiên đăng nhập, GPS, ngữ cảnh màn hình), *CSDL* (đọc từ Supabase PostgreSQL), *API ngoài* (Google Maps).
- **Đích** của đầu ra: *CSDL* (bảng trên Supabase PostgreSQL), *Storage* (Supabase Storage), *UI* (hiển thị trên màn hình tác nhân), *Realtime/FCM* (đẩy tới thiết bị khác).
- Tên cột/bảng khớp với mục 5.3 *Thiết kế Cơ sở dữ liệu* (`users`, `shops`, `sos_requests`, `reviews`, `volunteer_profiles`).

---

