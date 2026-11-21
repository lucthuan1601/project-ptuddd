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

## 4.9 Bảng đặc tả UC-09: Đăng ký & Quản lý tiệm

| Mục | Nội dung |
| --- | --- |
| Tên use case | Đăng ký & Quản lý tiệm (UC-09) |
| Tác nhân chính | Shop Owner (Chủ tiệm sửa xe) |
| Mục đích (mô tả) | Cho phép chủ tiệm tạo mới hồ sơ tiệm (tên, loại hình, hotline, giờ mở/đóng cửa, ảnh mặt tiền, vị trí) hoặc chỉnh sửa hồ sơ đã có. Hồ sơ mới ở trạng thái chờ Admin phê duyệt (UC-14) trước khi hiển thị công khai trên bản đồ. |
| Mức độ ưu tiên | Cao |
| Điều kiện kích hoạt | Chủ tiệm chọn mục "Quản lý tiệm" trên thanh điều hướng, hoặc được chuyển tới tự động ngay sau khi đăng ký tài khoản vai trò Owner (UC-01). |
| Điều kiện tiên quyết | Chủ tiệm đã đăng nhập với `role = 'owner'`, tài khoản `status = 'active'`, thiết bị có kết nối Internet. |
| Điều kiện thành công | Hồ sơ tiệm mới được lưu vào bảng `shops` với `status = 'pending'`, hoặc thông tin chỉnh sửa được cập nhật thành công; ảnh mặt tiền (nếu có) được lưu trên Supabase Storage. |
| Điều kiện thất bại | Không lưu được hồ sơ do thiếu trường bắt buộc, dữ liệu sai định dạng, tải ảnh thất bại hoặc mất kết nối. Dữ liệu cũ (nếu có) giữ nguyên. |

**Đầu vào (Input)**

| STT | Dữ liệu | Kiểu dữ liệu | Bắt buộc | Ràng buộc / Định dạng | Nguồn |
| --- | --- | --- | --- | --- | --- |
| 1 | Mã chủ tiệm (`owner_id`) | UUID | Có | Lấy từ phiên đăng nhập, `role = 'owner'` | Hệ thống (Supabase Auth) |
| 2 | Mã tiệm (`shop_id`) | UUID | Chỉ khi sửa | Tiệm thuộc sở hữu của `owner_id` | CSDL (hồ sơ tiệm hiện có) |
| 3 | Tên tiệm (`name`) | VARCHAR(150) | Có | 3–150 ký tự | Người dùng nhập |
| 4 | Loại hình (`category`) | VARCHAR(30) | Có | `'repair_shop'` (Tiệm sửa xe) hoặc `'gas_station'` (Cây xăng) | Người dùng chọn |
| 5 | SĐT hotline (`phone`) | VARCHAR(20) | Có | Số điện thoại Việt Nam 10 chữ số, bắt đầu bằng 0 | Người dùng nhập |
| 6 | Giờ mở cửa (`open_time`) | TIME | Có | Định dạng HH:mm | Người dùng chọn (Time Picker) |
| 7 | Giờ đóng cửa (`close_time`) | TIME | Có | Định dạng HH:mm, khác `open_time` | Người dùng chọn (Time Picker) |
| 8 | Ảnh mặt tiền | Tệp ảnh | Không (khuyến nghị) | JPG/PNG, dung lượng ≤ 5 MB | Người dùng chọn từ thư viện/camera |
| 9 | Vĩ độ, Kinh độ (`latitude`, `longitude`) | DOUBLE PRECISION | Có | Kết quả trả về từ UC-10 | UC-10 (include) |
| 10 | Địa chỉ chi tiết (`address`) | TEXT | Có | Chuỗi địa chỉ từ Reverse Geocoding (UC-10), cho phép sửa tay | UC-10 / Người dùng chỉnh |

**Đầu ra (Output)**

| STT | Dữ liệu | Kiểu dữ liệu | Đích | Mô tả |
| --- | --- | --- | --- | --- |
| 1 | Bản ghi tiệm mới/cập nhật (`id`, `owner_id`, `name`, `category`, `phone`, `address`, `latitude`, `longitude`, `open_time`, `close_time`, `image_url`) | Row bảng `shops` | CSDL | Tạo mới (INSERT) hoặc cập nhật (UPDATE) |
| 2 | Tọa độ không gian (`location`) | GEOGRAPHY(Point, 4326) | CSDL | Sinh từ `ST_MakePoint(longitude, latitude)` phục vụ truy vấn bán kính UC-03, UC-07 |
| 3 | Trạng thái kiểm duyệt (`status`) | VARCHAR(20) | CSDL | `'pending'` với hồ sơ mới; giữ nguyên `'approved'` khi chỉ sửa giờ/ảnh/SĐT; chuyển về `'pending'` khi đổi tên, loại hình hoặc vị trí |
| 4 | URL ảnh mặt tiền (`image_url`) | TEXT | Storage + CSDL | Ảnh tải lên bucket `shop-images`, URL công khai lưu vào `shops.image_url` |
| 5 | Thông báo kết quả | Chuỗi | UI | "Đăng ký tiệm thành công, vui lòng chờ Quản trị viên phê duyệt" hoặc "Cập nhật thông tin tiệm thành công" |
| 6 | Màn hình Tổng quan quản lý tiệm | Giao diện | UI | Hiển thị thông tin tiệm và nhãn trạng thái (Chờ duyệt / Đã duyệt / Bị từ chối) |

**Luồng sự kiện chính**

1. Chủ tiệm chọn mục "Quản lý tiệm".
2. Hệ thống kiểm tra chủ tiệm đã có hồ sơ tiệm chưa: nếu chưa, hiển thị form trống; nếu có, hiển thị form với dữ liệu hiện tại.
3. Chủ tiệm nhập/sửa tên tiệm, loại hình, SĐT hotline, giờ mở – đóng cửa và chọn ảnh mặt tiền.
4. Chủ tiệm chọn "Chọn vị trí trên bản đồ" để ghim tọa độ tiệm (*include* UC-10); hệ thống điền tọa độ và địa chỉ trả về vào form.
5. Chủ tiệm nhấn "Đăng ký tiệm" (hồ sơ mới) hoặc "Lưu thay đổi" (hồ sơ cũ).
6. Hệ thống kiểm tra dữ liệu: các trường bắt buộc không trống, SĐT đúng định dạng, giờ đóng khác giờ mở, ảnh đúng định dạng và dung lượng.
7. Hệ thống tải ảnh mới (nếu có) lên Supabase Storage và nhận về URL công khai.
8. Hệ thống ghi dữ liệu vào bảng `shops`; hồ sơ mới được gán `status = 'pending'`.
9. Hệ thống hiển thị thông báo thành công và chuyển về màn hình Tổng quan quản lý tiệm.

**Luồng sự kiện thay thế**

- **A1 – Sửa thông tin nhạy cảm của tiệm đã duyệt:** Tại bước 8, nếu chủ tiệm thay đổi tên tiệm, loại hình hoặc vị trí của tiệm đang `approved`, hệ thống chuyển `status` về `'pending'` để Admin duyệt lại và báo *"Thông tin thay đổi cần được Quản trị viên duyệt lại"*.
- **A2 – Hồ sơ bị từ chối:** Tại bước 2, nếu hồ sơ đang `rejected`, hệ thống hiển thị lý do từ chối (từ UC-14) phía trên form; sau khi chủ tiệm sửa và gửi lại, `status` chuyển về `'pending'`.

**Luồng sự kiện ngoại lệ**

- **E1 – Thiếu thông tin bắt buộc:** Tại bước 6, hệ thống tô đỏ các trường thiếu và báo *"Vui lòng nhập đầy đủ các thông tin bắt buộc"*.
- **E2 – Sai định dạng:** Tại bước 6, hệ thống báo *"Số điện thoại không hợp lệ"* hoặc *"Giờ đóng cửa phải khác giờ mở cửa"* ngay dưới trường tương ứng.
- **E3 – Ảnh không hợp lệ:** Tại bước 6, ảnh không phải JPG/PNG hoặc lớn hơn 5 MB, hệ thống báo *"Ảnh phải có định dạng JPG/PNG và dung lượng không quá 5 MB"*.
- **E4 – Tải ảnh thất bại:** Tại bước 7, hệ thống báo *"Không thể tải ảnh lên, vui lòng kiểm tra kết nối hoặc chọn ảnh khác"* và hủy tiến trình lưu form.
- **E5 – Mất kết nối mạng:** Tại bước 8, hệ thống báo lỗi kết nối, giữ nguyên dữ liệu đã nhập trên form để gửi lại.

---

