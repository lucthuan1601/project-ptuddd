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

## 4.8 Bảng đặc tả UC-08: Đánh giá & Viết nhận xét

| Mục | Nội dung |
| --- | --- |
| Tên use case | Đánh giá & Viết nhận xét (UC-08) |
| Tác nhân chính | Rider (Khách hàng) |
| Mục đích (mô tả) | Cho phép khách hàng chấm điểm mức độ hài lòng (1–5 sao) kèm bình luận về chất lượng dịch vụ của tiệm sửa xe/cây xăng, giúp người dùng khác tham khảo khi lựa chọn. |
| Mức độ ưu tiên | Trung bình |
| Điều kiện kích hoạt | Rider nhấn nút "Đánh giá" tại màn hình Chi tiết địa điểm (UC-04), hoặc nhấn gợi ý "Đánh giá dịch vụ" sau khi ca cứu hộ SOS do tiệm tiếp nhận chuyển sang `completed` (UC-12). |
| Điều kiện tiên quyết | Rider đã đăng nhập (UC-01), tài khoản `status = 'active'`; tiệm được đánh giá có `status = 'approved'`. |
| Điều kiện thành công | Một bản ghi mới được thêm vào bảng `reviews`; `rating` (trung bình) và `review_count` của tiệm trong bảng `shops` được tính lại; đánh giá mới hiển thị ngay trên trang chi tiết tiệm. |
| Điều kiện thất bại | Đánh giá không được lưu do chưa chọn số sao, nội dung vượt giới hạn, tài khoản bị khóa hoặc mất kết nối mạng. Dữ liệu `shops` giữ nguyên. |

**Đầu vào (Input)**

| STT | Dữ liệu | Kiểu dữ liệu | Bắt buộc | Ràng buộc / Định dạng | Nguồn |
| --- | --- | --- | --- | --- | --- |
| 1 | Mã tiệm (`shop_id`) | UUID | Có | Tồn tại trong `shops`, `status = 'approved'` | Hệ thống (ngữ cảnh màn hình Chi tiết tiệm) |
| 2 | Mã khách hàng (`rider_id`) | UUID | Có | Lấy từ phiên đăng nhập, `role = 'rider'` | Hệ thống (Supabase Auth – `auth.uid()`) |
| 3 | Số sao (`rating`) | SMALLINT | Có | Số nguyên 1 ≤ rating ≤ 5 | Người dùng chọn trên thanh sao |
| 4 | Nội dung nhận xét (`comment`) | TEXT | Không | Tối đa 500 ký tự, tự động cắt khoảng trắng đầu/cuối | Người dùng nhập |

**Đầu ra (Output)**

| STT | Dữ liệu | Kiểu dữ liệu | Đích | Mô tả |
| --- | --- | --- | --- | --- |
| 1 | Bản ghi đánh giá mới (`id`, `shop_id`, `rider_id`, `rating`, `comment`, `created_at`) | Row bảng `reviews` | CSDL | Lưu đánh giá của Rider |
| 2 | Điểm trung bình mới (`shops.rating`) | NUMERIC(2,1) | CSDL | `AVG(reviews.rating)` của tiệm, làm tròn 1 chữ số thập phân |
| 3 | Tổng lượt đánh giá mới (`shops.review_count`) | INTEGER | CSDL | `review_count + 1` |
| 4 | Thông báo "Gửi đánh giá thành công" | Chuỗi (SnackBar) | UI | Hiển thị cho Rider |
| 5 | Danh sách đánh giá & điểm trung bình đã làm mới | Danh sách `reviews` + điểm `rating` | UI | Trang chi tiết tiệm hiển thị đánh giá mới nhất ở đầu |
| 6 | Thông báo lỗi (khi thất bại) | Chuỗi | UI | Xem luồng ngoại lệ |

**Luồng sự kiện chính**

1. Rider nhấn nút "Đánh giá" tại màn hình chi tiết tiệm.
2. Hệ thống hiển thị hộp thoại đánh giá gồm thanh chọn số sao (1–5) và ô nhập nhận xét (đếm ký tự còn lại).
3. Rider chọn số sao và (tùy chọn) nhập nội dung nhận xét.
4. Rider nhấn "Gửi đánh giá".
5. Hệ thống kiểm tra dữ liệu: đã chọn số sao trong khoảng 1–5, nhận xét không quá 500 ký tự.
6. Hệ thống thêm bản ghi vào bảng `reviews` với `shop_id`, `rider_id` lấy từ phiên đăng nhập.
7. Trigger CSDL tính lại `rating` trung bình và `review_count` của tiệm trong bảng `shops`.
8. Hệ thống hiển thị thông báo thành công, đóng hộp thoại và làm mới danh sách đánh giá, điểm trung bình trên trang chi tiết tiệm.

**Luồng sự kiện thay thế**

- **A1 – Đánh giá từ gợi ý sau ca SOS:** Tại bước 1, nếu Rider mở từ thông báo "Ca cứu hộ đã hoàn thành" (UC-12), hệ thống tự điền `shop_id` của tiệm đã tiếp nhận ca và chuyển thẳng tới bước 2.
- **A2 – Hủy đánh giá:** Tại bước 3–4, nếu Rider nhấn "Hủy" hoặc đóng hộp thoại, hệ thống không lưu dữ liệu và quay về màn hình chi tiết tiệm.

**Luồng sự kiện ngoại lệ**

- **E1 – Chưa chọn số sao:** Tại bước 5, hệ thống báo *"Vui lòng chọn số sao trước khi gửi"*, giữ nguyên nội dung đã nhập.
- **E2 – Nhận xét quá dài:** Tại bước 5, hệ thống báo *"Nội dung nhận xét không được vượt quá 500 ký tự"*.
- **E3 – Tài khoản bị khóa:** Tại bước 6, chính sách RLS từ chối thao tác ghi; hệ thống báo *"Tài khoản của bạn đã bị khóa, không thể gửi đánh giá"*.
- **E4 – Mất kết nối mạng:** Tại bước 6, hệ thống báo *"Không thể kết nối mạng, vui lòng thử lại sau"*, giữ nguyên dữ liệu trong hộp thoại và hiển thị nút "Thử lại".

---

