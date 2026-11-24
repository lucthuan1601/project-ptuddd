# Ứng dụng Kết nối & Tình nguyện Xe máy — Nhóm 18 (65KTPM)

Tài liệu hướng dẫn làm việc nhóm, phân chia nhiệm vụ, quy trình Git/GitHub và thiết lập môi trường phát triển cho các thành viên **Nhóm 18 – Lớp 65KTPM**, học phần *Phát triển Ứng dụng cho các Thiết bị Di động* (GVHD: ThS. Đỗ Oanh Cường).

- **Công nghệ:** Flutter (chỉ hỗ trợ Android trong phạm vi môn học) + Supabase (Auth, PostgreSQL/PostGIS, Storage, Realtime, Edge Functions) + Google Maps + Firebase Cloud Messaging (FCM).
- **Kho lưu trữ làm việc của nhóm (`origin`):** `https://github.com/lucthuan1601/project-ptuddd.git`
- **Kho lưu trữ gốc môn học (`upstream`):** `https://github.com/oanhcuongdo/project-ptuddd.git`
- **Thư mục nhóm:** `nhom18-65ktpm/` | **Nhánh chính của nhóm:** `nhom/nhom18-65ktpm`
- **Tài liệu liên quan:**
  - Danh sách thành viên: [danhsachnhom.md](../danhsachnhom.md)
  - Hướng dẫn khởi tạo CSDL & tài khoản test: [supabase/README.md](../supabase/README.md)
  - Đặc tả Use Case UC-08 → UC-15: [dac-ta-use-case-uc08-uc15.md](../dac-ta-use-case-uc08-uc15.md)
  - Quy định nộp bài chung của môn học: [project-ptuddd/README.md](../../README.md)

---

## 1. Phân chia nhiệm vụ & Trạng thái bàn giao

### 1.1. Bảng phân công thành viên (chốt theo Báo cáo mục 2.4)

| STT | Họ và Tên | Mã SV | Vai trò | Nhánh Git làm việc | Phần tài liệu | Phần mã nguồn (Code) |
| :-: | --- | --- | --- | --- | --- | --- |
| 1 | **Lục Văn Thuận** | `2351170624` | Trưởng nhóm | `nhom/nhom18-65ktpm` | Thu thập & phân tích yêu cầu; rà soát chéo toàn bộ báo cáo | Nền tảng dự án Flutter, Supabase (bảng, RLS, hàm RPC, Storage, seed), Firebase, xác thực & điều hướng theo vai trò (**UC-01**); review, tích hợp và gộp code |
| 2 | **Trần Văn Hồng Quân** | `2351170613` | Thành viên | `feat/quan-rider` | Đặc tả **UC-01 → UC-07** | Phân hệ Khách hàng (Rider): **UC-02, UC-03, UC-04, UC-05, UC-06** (phối hợp **UC-01** phần Rider) |
| 3 | **Hoàng Tùng** | `2351170630` | Thành viên | `feat/tung-sos-volunteer` | Đặc tả **UC-08 → UC-15** | Luồng Cứu hộ, Đánh giá & Tình nguyện viên: **UC-07, UC-08, UC-11 (phần TNV), UC-12, UC-13**; Supabase Edge Function gửi thông báo **FCM** |
| 4 | **Nguyễn Khắc Minh Hiếu** | `2251162000` | Thành viên | `feat/hieu-owner-admin` | Sơ đồ Use Case tổng quát và phân rã theo tác nhân | Phân hệ Chủ tiệm (Owner) & Quản trị (Admin): **UC-09, UC-10, UC-11 (phần Chủ tiệm), UC-14, UC-15** |

### 1.2. Chi tiết 15 Use Case và người phụ trách triển khai

| Mã UC | Tên Use Case | Tác nhân | Người phụ trách code | Ghi chú |
| :---: | --- | --- | --- | --- |
| **UC-01** | Đăng nhập / Đăng ký | Tất cả | **Thuận** *(Quân phối hợp)* | Đã hoàn thiện nền tảng Auth + phân luồng theo vai trò |
| **UC-02** | Định vị vị trí hiện tại | Rider, Owner, Volunteer | **Quân** | Lấy GPS qua `geolocator`, hiển thị Marker trên Google Maps |
| **UC-03** | Tìm kiếm Tiệm sửa xe & Cây xăng | Rider | **Quân** | Gọi RPC `get_nearby_shops`, lọc từ khóa/danh mục/bán kính/đang mở |
| **UC-04** | Xem chi tiết địa điểm | Rider | **Quân** | Hiển thị thông tin tiệm, ảnh, badge mở/đóng, danh sách review |
| **UC-05** | Gọi điện nhanh Hotline | Rider | **Quân** | Mở trình quay số `tel:` qua `url_launcher` |
| **UC-06** | Chỉ đường (Navigation) | Rider, Owner, Volunteer | **Quân** | Vẽ Polyline hoặc chuyển tiếp sang ứng dụng Google Maps |
| **UC-07** | Gửi yêu cầu Cứu hộ SOS | Rider | **Tùng** | Tạo bản ghi `sos_requests`, hủy khi `pending`, kích hoạt gửi FCM |
| **UC-08** | Đánh giá & Viết nhận xét | Rider | **Tùng** | Chấm 1–5 sao + nhận xét (`upsert`), tự cập nhật `shops.rating` |
| **UC-09** | Đăng ký & Quản lý tiệm | Owner | **Hiếu** | Tạo/sửa hồ sơ tiệm, upload ảnh mặt tiền lên Supabase Storage |
| **UC-10** | Ghim vị trí tiệm trên bản đồ | Owner | **Hiếu** | Chọn tọa độ Lat/Lng trên bản đồ + Reverse Geocoding |
| **UC-11** | Cập nhật trạng thái hoạt động | Owner, Volunteer | **Hiếu** *(Owner)* / **Tùng** *(TNV)* | Chủ tiệm bật/tắt `shops.is_open`; TNV bật/tắt `volunteer_profiles.is_available` |
| **UC-12** | Tiếp nhận yêu cầu SOS | Owner, Volunteer | **Tùng** *(Hiếu gắn vào Owner)* | Nhận/từ chối ca qua RPC `accept_sos`, gọi khách, chỉ đường, hoàn thành |
| **UC-13** | Đăng ký Hồ sơ Tình nguyện viên | Volunteer | **Tùng** | Kỹ năng, dụng cụ, bán kính, upload ảnh giấy tờ xác minh |
| **UC-14** | Quản lý tài khoản, Tiệm & TNV | Admin | **Hiếu** | Duyệt/từ chối tiệm & hồ sơ TNV; khóa/mở khóa tài khoản |
| **UC-15** | Thống kê hệ thống | Admin | **Hiếu** | Báo cáo số lượng người dùng, tiệm, TNV và lượt cứu hộ SOS |

### 1.3. Trạng thái bàn giao hiện tại

- **Đã có sẵn (nền tảng do Thuận dựng):**
  - Schema 5 bảng (`users`, `shops`, `sos_requests`, `reviews`, `volunteer_profiles`), RLS, RPC PostGIS, Storage và dữ liệu seed trong [`../supabase/`](../supabase/README.md).
  - 5 model (`lib/models/`) kèm unit test và 5 hợp đồng repository (`lib/repositories/`).
  - **UC-01:** Đăng nhập, đăng ký, chặn tài khoản `banned`, tự động điều hướng theo vai trò (`AuthGate`).
  - 4 màn hình khung rỗng (`lib/core/shells/`) để từng thành viên lắp ghép giao diện của mình.
- **Cần triển khai theo phân công:** Bản đồ & tìm kiếm, gọi điện/chỉ đường, luồng SOS & FCM, đánh giá, quản lý chủ tiệm, hồ sơ tình nguyện viên và bảng quản trị Admin.

---

## 2. Thiết lập môi trường & Chạy ứng dụng lần đầu

### 2.1. Công cụ cần cài đặt

- **Git** (đã cấu hình tài khoản GitHub được thêm làm Collaborator vào kho `lucthuan1601/project-ptuddd`).
- **Flutter SDK** (Dart >= 3.x) và **Android Studio** (Android SDK + Emulator hoặc điện thoại Android bật *USB Debugging*).

### 2.2. Cấu hình định danh Git & lấy mã nguồn

Mỗi thành viên thiết lập đúng tên và email gắn với tài khoản GitHub để lịch sử commit ghi nhận chính xác đóng góp:

```bash
git config --global user.name "Ho Va Ten Cua Ban"
git config --global user.email "email_github_cua_ban@example.com"
```

Clone kho làm việc của nhóm và chuyển sang nhánh cá nhân đã tạo sẵn:

```bash
git clone https://github.com/lucthuan1601/project-ptuddd.git
cd project-ptuddd
git fetch origin

# Chọn ĐÚNG nhánh được phân công cho bạn:
git checkout --track origin/feat/quan-rider            # Quân
# git checkout --track origin/feat/tung-sos-volunteer  # Tùng
# git checkout --track origin/feat/hieu-owner-admin    # Hiếu
```

> **Lưu ý:** Không làm việc trên các nhánh cũ (`quan`, `khac-minh-hieu`, `Hoang-Tung`). Chỉ làm việc trên nhánh `feat/*` tương ứng ở trên.

### 2.3. Cấu hình biến môi trường và chạy app

Di chuyển vào thư mục mã nguồn Flutter `nhom18-65ktpm/src/`:

```bash
cd nhom18-65ktpm/src
flutter pub get

# Tạo file env.json từ file mẫu (file env.json đã được .gitignore bỏ qua)
# Windows (PowerShell):
Copy-Item env.json.example env.json
# macOS / Linux:
cp env.json.example env.json
```

1. Điền `SUPABASE_URL` và `SUPABASE_ANON_KEY` (anon/publishable key) vào `env.json` *(nhận thông tin từ Trưởng nhóm hoặc tạo project Supabase riêng và chạy SQL theo [`../supabase/README.md`](../supabase/README.md))*. **Tuyệt đối không dùng `service_role key` và không commit `env.json`.**
2. Thay `YOUR_GOOGLE_MAPS_API_KEY` trong `android/app/src/main/AndroidManifest.xml` bằng key của bạn khi chạy bản đồ *(không commit key thật lên GitHub)*.
3. Chạy ứng dụng:

```bash
flutter run --dart-define-from-file=env.json
```

Không có `env.json`, app vẫn mở được nhưng sẽ hiển thị màn hình hướng dẫn cấu hình.

### 2.4. Tài khoản test

Xem danh sách đầy đủ trong [`../supabase/README.md`](../supabase/README.md) (`rider1@test.local`, `owner1@test.local`, `owner2@test.local`, `volunteer1@test.local`, `volunteer2@test.local`, `admin@test.local`). Mật khẩu gợi ý: `123456`.

---

## 3. Quy trình làm việc nhóm với Git & GitHub

### 3.1. Nguyên tắc bắt buộc (theo quy định môn học)

1. **Cấm đụng vào nhánh `main`:** Tuyệt đối không commit hoặc push trực tiếp vào `main` (đã khóa bằng Branch Protection Rule).
2. **Chỉ thao tác trong `nhom18-65ktpm/`:** Không chỉnh sửa, đổi tên hoặc xóa `README.md`, `.gitignore` ở thư mục gốc repo hay thư mục của nhóm khác.
3. **Cấm `git add .` ở thư mục gốc:** Luôn kiểm tra `git status` và chỉ stage trong `nhom18-65ktpm/`.
4. **Không đẩy tệp rác / tệp bí mật:** Không commit `env.json`, `google-services.json`, `.env`, `build/`, `.dart_tool/`, `.gradle/`, `*.apk`, `.idea/`, `~$*` (file tạm khi đang mở Word).
5. **Không `git push --force`** lên nhánh chung `nhom/nhom18-65ktpm`.

### 3.2. Mô hình phân nhánh của nhóm

```text
upstream/main  (Kho giảng viên — chỉ Trưởng nhóm mở PR nộp bài cuối kỳ)
   └── nhom/nhom18-65ktpm  (Nhánh tích hợp chính của Nhóm 18 — chỉ Thuận merge PR)
         ├── feat/quan-rider          (Quân: UC-02 → UC-06)
         ├── feat/tung-sos-volunteer  (Tùng: UC-07, UC-08, UC-11 TNV, UC-12, UC-13, FCM)
         └── feat/hieu-owner-admin    (Hiếu: UC-09, UC-10, UC-11 Chủ tiệm, UC-14, UC-15)
```

### 3.3. Quy trình làm việc hằng ngày (7 bước)

**Bước 1 – Đồng bộ code mới nhất từ nhánh nhóm trước khi code:**

```bash
git checkout feat/<nhanh-cua-ban>
git fetch origin
git merge origin/nhom/nhom18-65ktpm
```

**Bước 2 – Lập trình trong đúng thư mục tính năng được giao** (xem Mục 4).

**Bước 3 – Kiểm tra chất lượng mã nguồn (bắt buộc trước khi commit/PR):**

```bash
cd nhom18-65ktpm/src
flutter analyze   # Phải đạt 0 issue
flutter test      # Toàn bộ test phải pass
```

**Bước 4 – Rà soát các tệp thay đổi (tại thư mục gốc `project-ptuddd/`):**

```bash
git status
```

Kiểm tra kỹ: đang ở đúng nhánh `feat/...` và **100% đường dẫn tệp thay đổi đều bắt đầu bằng `nhom18-65ktpm/`**, không lẫn `env.json` hay file build.

**Bước 5 – Stage tệp theo đúng đường dẫn nhóm:**

```bash
# Khuyến nghị chỉ định rõ tệp hoặc thư mục con đã sửa:
git add nhom18-65ktpm/src/lib/features/<module-cua-ban>/
# Hoặc toàn bộ thư mục nhóm sau khi đã kiểm tra kỹ git status:
git add nhom18-65ktpm/
```

**Bước 6 – Commit theo đúng quy tắc:**

```bash
git commit -m "<type>(<scope>): <mo ta ngan gon khong dau>"
```

**Bước 7 – Push lên nhánh cá nhân và mở Pull Request:**

```bash
git push origin feat/<nhanh-cua-ban>
```

### 3.4. Quy tắc đặt tên Commit

Định dạng bắt buộc: `<type>(<scope>): <mô tả ngắn gọn, tiếng Việt không dấu, viết thường>`.

| `type` | Mục đích sử dụng | Ví dụ chuẩn |
| --- | --- | --- |
| `feat` | Thêm tính năng, màn hình hoặc mã nguồn mới | `feat(rider): hien thi ban do GPS va tim tiem quanh day` |
| `fix` | Sửa lỗi logic, giao diện hoặc CSDL | `fix(sos): chan bam nhan ca trung lap tren man hinh TNV` |
| `docs` | Cập nhật tài liệu, README, báo cáo, `danhsachnhom.md` | `docs(nhom18): cap nhat huong dan lam viec nhom` |
| `chore` | Cấu hình project, thêm package, quyền Android | `chore(android): bo sung quyen thong bao FCM` |
| `refactor` | Tối ưu cấu trúc code nhưng không đổi hành vi | `refactor(owner): tach widget chon gio mo cua` |
| `test` | Bổ sung hoặc cập nhật unit/widget test | `test(review): them test kiem tra so sao hop le` |

**Quy ước `<scope>`:**
- Dùng `nhom18` cho thay đổi chung của nhóm (tài liệu, danh sách nhóm, cấu hình chung).
- Dùng tên phân hệ/module cho commit tính năng: `auth`, `rider`, `map`, `shop`, `sos`, `review`, `volunteer`, `owner`, `admin`, `db`, `core`, `android`.

### 3.5. Quy trình Pull Request, Review & Definition of Done (DoD)

1. Mở PR trên GitHub tại kho `lucthuan1601/project-ptuddd`:
   - **base:** `nhom/nhom18-65ktpm` ← **compare:** `feat/<nhanh-cua-ban>`
2. **Tiêu đề PR:** `[UC-xx] Mô tả ngắn tính năng` (ví dụ: `[UC-02,03] Bản đồ GPS và tìm kiếm tiệm gần đây`).
3. **Nội dung PR (Description)** cần có:
   - Danh sách UC / công việc đã hoàn thành.
   - Ảnh chụp màn hình hoặc video ngắn demo chạy trên máy thật / emulator.
   - Xác nhận đã chạy `flutter analyze` (0 issue) và `flutter test` (pass).
4. **Quyền merge:** **Chỉ Trưởng nhóm (Thuận)** review và merge PR vào `nhom/nhom18-65ktpm`. Sau khi PR được merge, các thành viên khác kéo lại `origin/nhom/nhom18-65ktpm` về nhánh của mình.
5. **Nộp bài cho Giảng viên (Trưởng nhóm thực hiện):** Mở PR từ `lucthuan1601/project-ptuddd` (`nhom/nhom18-65ktpm`) sang `oanhcuongdo/project-ptuddd` (`main`) với tiêu đề `[Nộp bài] nhom18-65ktpm - Ứng dụng Kết nối & Tình nguyện Xe máy`.

### 3.6. Xử lý nhanh các sự cố Git thường gặp

- **Lỡ `git add` nhầm tệp ngoài `nhom18-65ktpm/` hoặc `env.json`:**
  ```bash
  git restore --staged <duong-dan-tep-bi-nham>
  ```
- **Bị từ chối push (`rejected - non-fast-forward`):**
  ```bash
  git pull --rebase origin feat/<nhanh-cua-ban>
  git push origin feat/<nhanh-cua-ban>
  ```
- **Gặp xung đột (merge conflict):**
  - Không tự ý xóa hoặc ghi đè code của thành viên khác khi chưa trao đổi.
  - Sau khi giải quyết conflict, bắt buộc chạy lại `flutter analyze`, `flutter test` và test lại luồng liên quan trên máy trước khi commit.

---

## 4. Cấu trúc mã nguồn, Hợp đồng module & Điểm giáp ranh

### 4.1. Cấu trúc thư mục `lib/` & quyền sở hữu

```text
lib/
  core/
    env.dart, supabase_client.dart, theme.dart, validators.dart  # Dùng chung (Thuận quản lý)
    auth_gate.dart               # Thuận (không tự sửa)
    shells/
      rider_shell.dart           # Quân (gắn nút gửi SOS của Tùng)
      owner_shell.dart           # Hiếu (gắn màn hình nhận SOS của Tùng)
      volunteer_shell.dart       # Tùng
      admin_shell.dart           # Hiếu
  models/                        # Thuận đã chốt — KHÔNG tự ý đổi tên trường/cột
  repositories/                  # Hợp đồng dùng chung — muốn đổi chữ ký hàm phải báo Thuận
  features/
    auth/                        # Thuận (UC-01)
    map/ shop/ call/ navigation/ # Quân (UC-02 → UC-06)
    sos/ review/ volunteer/      # Tùng (UC-07, UC-08, UC-11 phần TNV, UC-12, UC-13)
    owner/ admin/                # Hiếu (UC-09, UC-10, UC-11 phần Chủ tiệm, UC-14, UC-15)
```

Quy ước trong mỗi module: tổ chức thành `screens/`, `widgets/` và `data/` (lớp gọi Supabase đặt cạnh module, ví dụ `features/sos/data/supabase_sos_repository.dart`).

### 4.2. Hợp đồng Repository (`lib/repositories/`)

| Repository | Người phụ trách | Ghi chú triển khai |
| --- | --- | --- |
| `AuthRepository` | Thuận | Đã hoạt động ổn định, dùng trực tiếp |
| `ShopRepository` | Thuận (đọc) + Hiếu (CRUD chủ tiệm) | `nearby()` gọi RPC `get_nearby_shops`; Quân dùng `nearby`/`byId` cho UC-02 → UC-04 |
| `ReviewRepository` | Tùng | UC-08 (`upsert` — mỗi rider 1 review/tiệm) và `listByShop` để Quân hiển thị trong UC-04 |
| `SosRepository` | Tùng | UC-07 (`create`/`cancel`) & UC-12 (`watchPending`/`accept`/`complete`/`contact`). Nhận ca **bắt buộc** qua RPC `accept_sos` |
| `VolunteerRepository` | Tùng | UC-13 & UC-11 phần TNV. `updateLocation` ghi EWKT: `SRID=4326;POINT(lng lat)` |

### 4.3. Các điểm giáp ranh cần thống nhất (không tự ý đổi)

1. **Quân ↔ Tùng (UC-04, UC-07, UC-08):**
   - Trên màn hình chính Rider (`RiderShell`) và màn hình Chi tiết tiệm (UC-04) do Quân xây dựng: đặt sẵn nút **Gửi SOS** (mở màn hình UC-07 của Tùng), nút **Đánh giá** (mở hộp thoại UC-08 của Tùng) và khu vực hiển thị danh sách review lấy qua `ReviewRepository.listByShop(shopId)`.
2. **Hiếu ↔ Tùng (UC-11, UC-12):**
   - **UC-11:** Chủ tiệm dùng `shops.is_open` (Hiếu), Tình nguyện viên dùng `volunteer_profiles.is_available` (Tùng) — hai luồng riêng, không gộp.
   - **UC-12:** Tùng xây dựng màn hình tiếp nhận & xử lý ca SOS dưới dạng widget/screen tái sử dụng theo tham số (`volunteerId` hoặc `shopId`) để Hiếu gắn trực tiếp vào `OwnerShell`.
3. **Khóa ca cứu hộ:** Chỉ RPC `accept_sos` được đổi `sos_requests.status` sang `accepted`; tuyệt đối không update trực tiếp bảng `sos_requests` từ client để tránh 2 người nhận trùng ca.
4. **Payload FCM (khi triển khai Edge Function):** `{ "sos_id", "issue_type", "lat", "lng" }`.
5. **Tệp dùng chung (`pubspec.yaml`, `models/`, `repositories/`, `core/`, `supabase/*.sql`):** Cần bổ sung thư viện hoặc chỉnh sửa schema phải trao đổi trên nhóm với Thuận trước để tránh conflict khi merge.

---

## 5. Phối hợp trong nhóm & Lỗi kỹ thuật thường gặp

### 5.1. Nguyên tắc phối hợp nội bộ

- **Trao đổi sớm khi bị chặn:** Nếu thiếu dữ liệu mẫu, bị lỗi RLS hay cần thêm package trong `pubspec.yaml`, báo ngay cho Thuận để xử lý tập trung trên nhánh `nhom/nhom18-65ktpm`.
- **Chia nhỏ PR:** Mỗi PR chỉ nên tập trung vào 1–2 Use Case hoàn chỉnh thay vì dồn quá nhiều thay đổi vào cuối kỳ.
- **Tôn trọng phạm vi code:** Không tự sửa code trong thư mục `features/` của thành viên khác nếu chưa thống nhất.

### 5.2. Lỗi kỹ thuật thường gặp

- `st_dwithin does not exist` → PostGIS chưa bật hoặc function thiếu `extensions` trong `search_path` (đã xử lý trong `supabase/03_functions.sql`).
- Đăng nhập xong quay lại form → chưa có dòng tương ứng trong `public.users`; kiểm tra trigger `on_auth_user_created` đã chạy.
- Bản đồ trắng → chưa thay Google Maps API key trong `AndroidManifest.xml` hoặc chưa bật billing/Maps SDK for Android.
- `permission denied for table ...` → thiếu policy RLS hoặc quyền `GRANT` tương ứng, không phải do sai API key.
