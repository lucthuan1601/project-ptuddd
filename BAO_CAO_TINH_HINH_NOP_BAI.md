# Báo Cáo Thống Kê Tình Hình Nộp Bài Tập Lớn (Fork, Commit, Issue, Pull Request)

- **Kho lưu trữ gốc (Upstream):** `oanhcuongdo/project-ptuddd`
- **Học phần:** Phát Triển Ứng Dụng Di Động (PTUDDD - Lớp 65KTPM)
- **Thời điểm trích xuất dữ liệu:** 21/11/2026 07:30 (GMT+7)
- **Phương pháp thống kê:**
  - Số lượng **Commit** chỉ tính các commit riêng của từng nhóm (đã loại bỏ 06 commit gốc từ `oanhcuongdo` và khử trùng lặp SHA giữa các nhánh trong cùng kho fork; phân tách rõ commit thường `Non-Merge` và commit gộp `Merge`).
  - Số lượng **Issue** tính theo tổng số Issue thực tế tồn tại trên từng kho fork (tách riêng trạng thái `Open` / `Closed`), phân biệt với số lượng sự kiện `IssuesEvent` trên nhật ký API.
  - Số lượng **Pull Request (PR)** tách biệt giữa **PR nộp bài lên kho gốc** và **PR nội bộ trong kho fork**.

---

## 1. Tổng Quan Toàn Kho Lưu Trữ

| Chỉ số tổng hợp | Giá trị ghi nhận | Ghi chú kỹ thuật |
| :--- | :---: | :--- |
| Tổng số Fork (metadata `forkCount`) | 21 | Gồm 18 fork công khai liệt kê được qua API và 03 fork không hiển thị công khai/riêng tư. |
| Số nhóm đã xác định | 18 | Đã ghi nhận Nhóm 01 đến Nhóm 16, Nhóm 18, Nhóm 19. Chưa ghi nhận kho fork của **Nhóm 17**. |
| Tổng số PR lên kho gốc (Upstream PRs) | 23 | 13 OPEN, 10 CLOSED, 0 MERGED (trong đó có 10 PR do thành viên mở nhầm đích từ nhánh cá nhân hoặc bị đóng). |
| Tổng số Unique Commits trên 18 Fork | 358 | 295 Non-Merge commits, 63 Merge commits. |
| Tổng số GitHub Issues trên 18 Fork | 116 | 112 OPEN, 4 CLOSED (kho gốc có 0 Issues). |
| Tổng số PR nội bộ trên 18 Fork | 56 | 43 MERGED, 10 OPEN, 3 CLOSED (không merge). |
| Tổng số GitHub Events trên 18 Fork | 1.004 | Tổng sự kiện ghi nhận trong giới hạn lịch sử gần nhất của GitHub Events API. |

---

## 2. Thống Kê Chi Tiết Theo Nhóm (Xếp Hạng Theo Số Lượng Commit)

| Hạng | Nhóm | Kho Fork | Tên Đề Tài | Nhánh Chính | Unique Commits (Non-Merge / Merge) | Số Tác Giả Commit | Issues (Open / Closed) | PR Nội Bộ (Merged / Open / Closed) | PR Kho Gốc | Repo Events | Commit Gần Nhất (GMT+7) |
| :-: | :--- | :--- | :--- | :--- | :---: | :---: | :---: | :---: | :--- | :---: | :--- |
| **1** | **Nhóm 10** | `tungcorn/project-ptuddd` | SingLearn | `nhom10-65ktpm` | **135** (117 / 18) | 4 | **5** (3 / 2) | **12** (8 / 3 / 1) | Chưa mở PR | 159 | 21/11 00:03 |
| **2** | **Nhóm 16** | `hhuynh2005/project-ptuddd` | GoodDeeds Fund | `nhom16-65ktpm` | **53** (45 / 8) | 4 | **5** (5 / 0) | **9** (6 / 3 / 0) | Chưa mở PR | 64 | 20/11 21:32 |
| **3** | **Nhóm 15** | `DuongNguyenAnhh-3185/nhom15-65ktpm` | Finger Math Kids App | `nhom15-65ktpm` | **35** (26 / 9) | 4 | **4** (4 / 0) | **9** (7 / 1 / 1) | `#4` (OPEN), `#15` (OPEN)* | 79 | 21/11 07:26 |
| **3** | **Nhóm 13** | `iam-mia/project-ptuddd` | TLU PeerLearn | `nhom/nhom13-65ktpm` | **35** (31 / 4) | 3 | **1** (1 / 0) | **3** (3 / 0 / 0) | `#11` (OPEN) | 21 | 21/11 07:01 |
| **5** | **Nhóm 14** | `Maya0612/project-ptuddd` | Hỗ trợ định hướng ĐATN | `nhom14-65ktpm` | **25** (21 / 4) | 5 | **5** (5 / 0) | **5** (5 / 0 / 0) | `#10` (OPEN) | 48 | 21/11 00:08 |
| **6** | **Nhóm 09** | `pvhung2112/project-ptuddd` | BuddyTalk | `nhom9-65ktpm` | **14** (10 / 4) | 5 | **0** (0 / 0) | **6** (4 / 2 / 0) | `#9` (OPEN) | 34 | 19/11 00:58 |
| **7** | **Nhóm 01** | `Khacsy05/project-ptuddd` | Football Discipline Tracker | `nhom01-65ktpm` | **13** (9 / 4) | 5 | **2** (2 / 0) | **3** (3 / 0 / 0) | `#8` (OPEN) | 30 | 21/11 07:26 |
| **8** | **Nhóm 12** | `NguyenTruongNT/project-ptuddd` | StudyShare | `nhom12-65ktpm` | **12** (5 / 7) | 2 | **4** (4 / 0) | **4** (4 / 0 / 0) | `#21` (OPEN) | 38 | 18/11 09:11 |
| **9** | **Nhóm 05** | `phamquanganhcode/project-ptuddd-nhom5-65ktpm` | Speak Up | `nhom05-65ktpm` | **8** (4 / 4) | 2 | **4** (2 / 2) | **4** (3 / 0 / 1) | `#3` (OPEN) | 38 | 19/11 01:46 |
| **10** | **Nhóm 03** | `Minh-lab/project-ptuddd` | NoteSmart | `nhom03-65ktpm` | **7** (7 / 0) | 1 | **22** (22 / 0) | **0** (0 / 0 / 0) | `#7` (OPEN) | 120 | 19/11 23:13 |
| **10** | **Nhóm 08** | `dinhan125/project-ptuddd` | Travel Buddy | `nhom08-65ktpm` | **7** (6 / 1) | 1 | **4** (4 / 0) | **0** (0 / 0 / 0) | `#20` (OPEN) | 26 | 21/11 07:06 |
| **12** | **Nhóm 19** | `NguyenThinh1004/project-ptuddd` | StudyMate AI | `nhom19-65ktpm` | **3** (3 / 0) | 2 | **11** (11 / 0) | **1** (0 / 1 / 0) | Chưa mở PR | 58 | 19/11 23:29 |
| **12** | **Nhóm 04** | `NDKha-DEV/project-ptuddd` | TLU B1 Daily | `nhom04-65ktpm` | **3** (3 / 0) | 2 | **5** (5 / 0) | **0** (0 / 0 / 0) | Chưa mở PR | 18 | 20/11 15:50 |
| **14** | **Nhóm 11** | `LoudlyDawn2108/project-ptuddd` | ChaiLish | `nhom/nhom11-65ktpm` | **2** (2 / 0) | 1 | **31** (31 / 0) | **0** (0 / 0 / 0) | `#1` (CLOSED) | 191 | 14/11 14:35 |
| **14** | **Nhóm 02** | `VietPham21/project-ptuddd` | *(Đang cập nhật)* | `nhom02-65ktpm` | **2** (2 / 0) | 1 | **1** (1 / 0) | **0** (0 / 0 / 0) | `#6` (OPEN) | 7 | 18/11 08:00 |
| **14** | **Nhóm 07** | `linhdontcare/project-ptuddd` | DCSleep | `nhom07-65ktpm` | **2** (2 / 0) | 1 | **0** (0 / 0) | **0** (0 / 0 / 0) | `#2` (OPEN) | 5 | 18/11 08:00 |
| **17** | **Nhóm 06** | `trggg2185/project-ptdudd` | HealthyLife | `nhom06-65ktpm` | **1** (1 / 0) | 1 | **12** (12 / 0) | **0** (0 / 0 / 0) | Chưa mở PR | 65 | 15/11 18:22 |
| **17** | **Nhóm 18** | `lucthuan1601/project-ptuddd` | Kết nối xe máy tình nguyện | `nhom/nhom18-65ktpm` | **1** (1 / 0) | 1 | **0** (0 / 0) | **0** (0 / 0 / 0) | `#5` (OPEN) | 3 | 15/11 21:23 |

*\*Ghi chú Nhóm 15: Ngoài PR nộp bài chính `#4`, thành viên `ThuHoai10` có mở PR `#15` trực tiếp lên kho gốc từ nhánh cá nhân.*

---

## 3. Thống Kê Nhóm Theo Số Lượng Issue Và Quy Trình Phối Hợp Nội Bộ

| Hạng Issue | Nhóm | Tổng Issue | Open | Closed | Issue Comments | Nhánh Hiện Có Trên Fork | Đánh Giá Thực Tế Việc Dùng Issue & PR Nội Bộ |
| :-: | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **1** | **Nhóm 11** (`LoudlyDawn2108`) | **31** | 31 | 0 | 0 | 2 | Toàn bộ 31 issues được tạo hàng loạt trong vài giây (186 `IssuesEvent`); chưa có commit mã nguồn mới hay PR nội bộ. |
| **2** | **Nhóm 03** (`Minh-lab`) | **22** | 22 | 0 | 0 | 2 | Tạo 22 issues (110 `IssuesEvent`) và phân công 5 thành viên, chưa đóng issue nào; toàn bộ 7 commit do tài khoản bot `rhoggs-bot-test-account` thực hiện. |
| **3** | **Nhóm 06** (`trggg2185`) | **12** | 12 | 0 | 0 | 2 | Tạo 12 issues hàng loạt (60 `IssuesEvent`), chưa đóng issue nào; mới có 1 commit khởi tạo. |
| **4** | **Nhóm 19** (`NguyenThinh1004`) | **11** | 11 | 0 | 0 | 3 | Tạo 11 issues phân công 4 thành viên (50 `IssuesEvent`); có 1 PR nội bộ đang mở. |
| **5** | **Nhóm 10** (`tungcorn`) | **5** | 3 | 2 | **31** | 15 | Có trao đổi thực tế qua 31 bình luận trên Issue, đã đóng 2/5 issue, sử dụng 12 PR nội bộ và review chéo (23 `PullRequestReviewEvent`). |
| **5** | **Nhóm 16** (`hhuynh2005`) | **5** | 5 | 0 | 3 | 9 | Tạo 5 issues theo module, phối hợp qua 9 PR nội bộ (đã merge 6) từ cả 4 thành viên. |
| **5** | **Nhóm 14** (`Maya0612`) | **5** | 5 | 0 | 0 | 7 | Tạo 5 issues phân công 5 thành viên, sử dụng 5 PR nội bộ (đã merge 5) với sự tham gia của đủ 5 thành viên. |
| **5** | **Nhóm 04** (`NDKha-DEV`) | **5** | 5 | 0 | 0 | 2 | Tạo 5 issues phân công 5 thành viên (M1–M5), chưa dùng nhánh feature/PR nội bộ. |
| **9** | **Nhóm 15** (`DuongNguyenAnhh-3185`) | **4** | 4 | 0 | 0 | 16 | Tạo 4 issues cho 4 thành viên, 9 PR nội bộ (đã merge 7), 16 nhánh feature; hoạt động push liên tục (30 `PushEvent`). |
| **9** | **Nhóm 05** (`phamquanganhcode`) | **4** | 2 | 2 | 1 | 5 | Đã đóng 2/4 issue, 4 PR nội bộ (đã merge 3). |
| **9** | **Nhóm 12** (`NguyenTruongNT`) | **4** | 4 | 0 | 0 | 3 | Tạo 4 issues cho 4 thành viên, 4 PR nội bộ (đã merge 4). |
| **9** | **Nhóm 08** (`dinhan125`) | **4** | 4 | 0 | 0 | 2 | Tạo 4 issues cho 4 thành viên, chưa sử dụng PR nội bộ. |
| **13** | **Nhóm 01** (`Khacsy05`) | **2** | 2 | 0 | 0 | 3 | Tạo 2 issues (gán cho trưởng nhóm), 3 PR nội bộ (đã merge 3) từ các thành viên. |
| **14** | **Nhóm 13** (`iam-mia`) | **1** | 1 | 0 | 0 | 5 | Tạo 1 issue, 3 PR nội bộ (đã merge 3). |
| **14** | **Nhóm 02** (`VietPham21`) | **1** | 1 | 0 | 0 | 2 | Tạo 1 issue khởi tạo. |
| **16** | **Nhóm 09** (`pvhung2112`) | **0** | 0 | 0 | 0 | 8 | Không dùng Issues trên fork, nhưng có 6 PR nội bộ (đã merge 4) từ 5 thành viên. |
| **16** | **Nhóm 07** (`linhdontcare`) | **0** | 0 | 0 | 0 | 2 | Chưa sử dụng Issues và PR nội bộ. |
| **16** | **Nhóm 18** (`lucthuan1601`) | **0** | 0 | 0 | 0 | 2 | Chưa sử dụng Issues và PR nội bộ. |

---

## 4. Thống Kê Hoạt Động Theo Từng Cá Nhân

### 4.1. Bảng Xếp Hạng Cá Nhân Tích Cực Nhất (Theo Số Lượng Commit)

Thống kê dưới đây ghi nhận các cá nhân có đóng góp commit thực tế trên toàn bộ 18 kho fork (gộp theo định danh GitHub; trường hợp một sinh viên dùng hai tài khoản Git trên cùng nhóm được chú thích rõ):

| Hạng | Tài khoản GitHub | Họ và Tên (Theo Danh Sách Nhóm) | Nhóm | Tổng Commits (Non-Merge / Merge) | Issues Đã Tạo | Issues Được Gán | PR Mở (Kho Gốc / Nội Bộ) | Tổng Events API | Ghi chú kỹ thuật |
| :-: | :--- | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **1** | `tungcorn` | Ngô Quang Tùng (Trưởng nhóm) | Nhóm 10 | **64** (48 / 16) | 5 | 2 | 0 / 4 | 82 | Đứng đầu về số lượng commit và review PR nội bộ trên fork. |
| **2** | `HaiNinh1` | Nguyễn Hải Ninh | Nhóm 10 | **28** (26 / 2) | 0 | 1 | 0 / 3 | 32 | Tham gia commit và tạo/review PR nội bộ đều đặn. |
| **3** | `DaoNgocDinh` | Đào Ngọc Đình | Nhóm 10 | **27** (27 / 0) | 0 | 1 | 0 / 4 | 32 | Toàn bộ 27 commit là non-merge commits. |
| **4** | `iam-mia` | Phùng Minh Anh (Trưởng nhóm) | Nhóm 13 | **19** (17 / 2) | 1 | 0 | 1 / 1 | 9 | Tác giả chính của mã nguồn Nhóm 13. |
| **5** | `DuongNguyenAnhh-3185` | Dương Nguyên Anh (Trưởng nhóm) | Nhóm 15 | **18** (13 / 5) | 4 | 1 | 1 / 3 | 57 | Hoạt động Git thực chất cao (23 PushEvent, 7 CreateEvent). |
| **6** | `hhuynh2005` | Nguyễn Văn Huỳnh (Trưởng nhóm) | Nhóm 16 | **16** (8 / 8) | 5 | 2 | 0 / 1 | 35 | Điều phối và merge chính cho Nhóm 16. |
| **6** | `phamngocbach05-debug` | Phạm Ngọc Bách | Nhóm 10 | **16** (16 / 0) | 0 | 1 | 0 / 1 | 13 | Thành viên Nhóm 10. |
| **8** | `AhTuan66` | Trần Anh Tuấn | Nhóm 16 | **14** (14 / 0) | 0 | 1 | 0 / 2 | 12 | Thành viên tích cực nhất về code non-merge của Nhóm 16. |
| **9** | `Maya0612` (+ `thudao612`) | Đào Hà Thu (Trưởng nhóm) | Nhóm 14 | **13** (9 / 4) | 5 | 1 | 1 / 4 | 42 | Gồm 12 commits từ `Maya0612` và 1 commit từ `thudao612` (cùng email MSSV `2351170623`). |
| **9** | `ngotuananh2005` | Ngô Tuấn Anh | Nhóm 13 | **13** (12 / 1) | 0 | 0 | 0 / 2 | 9 | Thành viên Nhóm 13. |
| **11** | `trunk-kien` | Nguyễn Trung Kiên | Nhóm 16 | **12** (12 / 0) | 0 | 1 | 0 / 3 | 9 | Thành viên Nhóm 16. |
| **12** | `atunnee` | Lê Anh Tuấn | Nhóm 16 | **11** (11 / 0) | 0 | 1 | 2 / 3 | 14 | Mở 2 PR nhầm lên kho gốc (`#19`, `#22` - đã tự đóng) và 3 PR nội bộ. |
| **13** | `NguyenTruongNT` | Nguyễn Văn Trường (Trưởng nhóm) | Nhóm 12 | **10** (5 / 5) | 4 | 1 | 1 / 4 | 34 | Mở PR `#21` từ nhánh `main` của fork lên kho gốc. |
| **14** | `pvhung2112` | Phạm Văn Hưng (Trưởng nhóm) | Nhóm 09 | **9** (5 / 4) | 0 | 0 | 1 / 1 | 17 | Điều phối và merge 4 PR nội bộ của Nhóm 09. |
| **14** | `ThuHoai10` | Nguyễn Thị Thu Hoài | Nhóm 15 | **9** (7 / 2) | 0 | 1 | 1 / 3 | 12 | Đang có PR `#15` mở nhầm lên kho gốc từ nhánh cá nhân. |
| **16** | `kimanh19-p` | Phạm Kim Anh | Nhóm 14 | **8** (8 / 0) | 0 | 1 | 0 / 0 | 3 | Commit đều trên nhánh làm việc của Nhóm 14. |
| **17** | `dinhan125` | Đỗ Đình An (Trưởng nhóm) | Nhóm 08 | **7** (6 / 1) | 4 | 1 | 0 / 0 | 24 | Thực hiện toàn bộ 7 commit của Nhóm 08. |
| **17** | `rhoggs-bot-test-account` | *(Tài khoản Git: `AI Assistant`)* | Nhóm 03 | **7** (7 / 0) | 0 | 0 | 0 / 0 | 0 | Tài khoản bot/tự động thực hiện toàn bộ 7 commit của Nhóm 03. |
| **19** | `phamquanganhcode` | Phạm Quang Anh (Trưởng nhóm) | Nhóm 05 | **6** (3 / 3) | 4 | 1 | 1 / 2 | 29 | Điều phối và nộp PR `#3` cho Nhóm 05. |
| **20** | `Khacsy05` | Nguyễn Khắc Sỹ (Trưởng nhóm) | Nhóm 01 | **4** (2 / 2) | 2 | 2 | 1 / 1 | 14 | Nộp PR `#8` cho Nhóm 01. |
| **20** | `ThaiPahm` | Phạm Duy Thái | Nhóm 15 | **4** (3 / 1) | 0 | 1 | 1 / 2 | 11 | Mở nhầm PR `#18` lên kho gốc (đã đóng). |
| **20** | `superbeo` | Nguyễn Thị Cẩm Ly | Nhóm 15 | **4** (3 / 1) | 0 | 1 | 1 / 1 | 8 | Mở nhầm PR `#17` lên kho gốc (đã đóng). |

### 4.2. Toàn Bộ Danh Sách Các Thành Viên Còn Lại (1–3 Commits Hoặc Chỉ Tham Gia Issue / PR / Collaborator)

| Tài khoản GitHub | Họ và Tên (Nếu xác định được) | Nhóm | Commits (NM/M) | Issues Tạo / Được Gán | PR (Gốc / Nội Bộ) | Events API |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: |
| `HaVanPhong1` | Hà Văn Phong | Nhóm 01 | 3 (2 / 1) | 0 / 0 | 0 / 0 | 2 |
| `Duchiephehe` | Bùi Đức Hiệp | Nhóm 01 | 3 (2 / 1) | 0 / 0 | 0 / 1 | 7 |
| `I-eat-short-people` | Phạm Văn Phước | Nhóm 13 | 3 (2 / 1) | 0 / 0 | 1 / 0 | 4 |
| `LoudlyDawn2108` | Nguyễn Hồng Phúc (Trưởng nhóm) | Nhóm 11 | 2 (2 / 0) | **31** / 7 | 1 / 0 | **191** |
| `NguyenThinh1004` | Nguyễn Văn Thịnh (Trưởng nhóm) | Nhóm 19 | 2 (2 / 0) | **11** / 2 | 0 / 0 | **54** |
| `VietPham21` | Phạm Văn Việt (Trưởng nhóm) | Nhóm 02 | 2 (2 / 0) | 1 / 1 | 1 / 0 | 7 |
| `kyokoxdev` | Ngô Đức Nam Khánh | Nhóm 05 | 2 (1 / 1) | 0 / 1 | 0 / 2 | 9 |
| `TrinhTrKien-crypto` | Trịnh Trung Kiên | Nhóm 09 | 2 (2 / 0) | 0 / 0 | 1 / 2 | 5 |
| `linhdontcare` | Mã Khánh Linh (Trưởng nhóm) | Nhóm 07 | 2 (2 / 0) | 0 / 0 | 1 / 0 | 5 |
| `germnguyen` | Nguyễn Minh Đức | Nhóm 01 | 2 (2 / 0) | 0 / 0 | 0 / 1 | 4 |
| `lydinhson` | Lý Đình Sơn | Nhóm 12 | 2 (0 / 2) | 0 / 1 | 0 / 0 | 3 |
| `vuongtiendung257` | Vương Tiến Dũng | Nhóm 14 | 2 (2 / 0) | 0 / 1 | 0 / 1 | 3 |
| `tugduong` (+ `tugduong57`) | Nguyễn Tùng Dương | Nhóm 04 | 2 (2 / 0) | 0 / 0 | 0 / 0 | 2 |
| `trggg2185` | Nguyễn Thế Trưởng (Trưởng nhóm) | Nhóm 06 | 1 (1 / 0) | **12** / 3 | 0 / 0 | **62** |
| `NDKha-DEV` | Nguyễn Đình Kha (Trưởng nhóm) | Nhóm 04 | 1 (1 / 0) | 5 / 0 | 0 / 0 | 14 |
| `CaoDucDao` | Cao Đức Đạo | Nhóm 09 | 1 (1 / 0) | 0 / 0 | 1 / 1 | 11 |
| `truonghaiii` | Trương Tuấn Hải | Nhóm 09 | 1 (1 / 0) | 0 / 0 | 1 / 1 | 6 |
| `lucthuan1601` | Lục Văn Thuận (Trưởng nhóm) | Nhóm 18 | 1 (1 / 0) | 0 / 0 | 1 / 0 | 3 |
| `Do-tien-452` | Đỗ Việt Tiến | Nhóm 09 | 1 (1 / 0) | 0 / 0 | 0 / 1 | 3 |
| `Yen411` | Đào Thị Yến | Nhóm 19 | 1 (1 / 0) | 0 / 3 | 0 / 1 | 3 |
| `DuckTrun` | Trần Đức Trung | Nhóm 14 | 1 (1 / 0) | 0 / 1 | 0 / 0 | 1 |
| `duckenger` | Trịnh Mạnh Đức | Nhóm 14 | 1 (1 / 0) | 0 / 1 | 0 / 0 | 1 |
| `thai1` (`ngotuananh2005@gmail.com`) | Nguyễn Hồng Thái | Nhóm 01 | 1 (1 / 0) | 0 / 0 | 0 / 0 | 0 |
| `Minh-lab` | Nguyễn Minh (Trưởng nhóm) | Nhóm 03 | 0 | **22** / 5 | 1 / 0 | **118** |
| `SonTuanmandosupport` | Nguyễn Đình Tuấn Sơn | Nhóm 13 | 0 | 0 / 0 | 1 / 0 | 4 |
| `khanhviphy29-blip` | Đỗ Tùng Khánh | Nhóm 08 | 0 | 0 / 1 | 1 / 0 | 2 |
| `vdng05` | Vũ Hải Đăng | Nhóm 12 | 0 | 0 / 1 | 0 / 0 | 2 |
| `quan-IT` | Nguyễn Hữu Quân | Nhóm 03 | 0 | 0 / 5 | 0 / 0 | 2 |
| `bhanh8762-jpg` | Mông Thị Bích Hạnh | Nhóm 03 | 0 | 0 / 5 | 0 / 0 | 1 |
| `dangit2005` | Dương Hải Đăng | Nhóm 03 | 0 | 0 / 4 | 0 / 0 | 1 |
| `dattom1234567` | Nguyễn Tiến Đạt | Nhóm 03 | 0 | 0 / 3 | 0 / 0 | 1 |
| `trung12345450` | Lê Đức Trung | Nhóm 19 | 0 | 0 / 3 | 0 / 0 | 1 |
| `VuHung440` | Nguyễn Năng Vũ Hùng | Nhóm 19 | 0 | 0 / 3 | 0 / 0 | 1 |
| `pvduc05`, `HanHoangHa`, `nddai0710` | Phương Văn Đức, Hàn Hoàng Hà, Nguyễn Đăng Đại | Nhóm 06 | 0 | 0 / 3 (mỗi người) | 0 / 0 | 1 (mỗi người) |
| `khanhx419`, `dinhhoa65ktpm`, `ngxcbao` | Lê Tuấn Khanh, Đinh Thị Hoa, Phạm Vũ Ngọc Bảo | Nhóm 11 | 0 | 0 / 6 (mỗi người) | 0 / 0 | 0 |
| `thedung051`, `Iwant2dye8976` | Hồ Thế Dũng, Nguyễn Xuân Bình | Nhóm 08 | 0 | 0 / 1 (mỗi người) | 0 / 0 | 1 (mỗi người) |
| `DuongHung1565`, `nguyenan1404z-spec` | Dương Văn Hưng, Nguyễn Phúc Bình An | Nhóm 05 | 0 | 0 / 1 (mỗi người) | 0 / 0 | 1 (mỗi người) |
| `tuankhanh594` | Vũ Tuấn Khanh | Nhóm 12 | 0 | 0 / 1 | 0 / 0 | 1 |
| `nnthanhan`, `trinhbao2002`, `harvey-nguyenn` | Nguyễn Ngọc Thành An, Trịnh Quốc Bảo, Nguyễn Huy Hoàng | Nhóm 04 | 0 | 0 / 0 | 0 / 0 | 1 (mỗi người) |
| `vubadai02`, `VuongDuongg` | Vũ Bá Đài, Dương Quốc Vượng | Nhóm 07 | 0 | 0 / 0 | 0 / 0 | 1 (mỗi người) |
| `XuanMinh833`, `Mashall-Anie` | Đặng Xuân Minh, thành viên Nhóm 02 | Nhóm 02 | 0 | 0 / 0 | 0 / 0 | 1 (mỗi người) |
| `LuvAbyss`, `quantranna05` | Thành viên Nhóm 18 | Nhóm 18 | 0 | 0 / 0 | 0 / 0 | 1 (mỗi người) |
| `thai1323` | Nguyễn Hồng Thái (tài khoản GitHub) | Nhóm 01 | 0 | 0 / 0 | 0 / 0 | 1 |

*(Ngoài ra có `chatgpt-codex-connector[bot]` ghi nhận 4 events review tự động trên fork của Nhóm 01).*

---

## 5. Tổng Hợp Tình Trạng Pull Request Lên Kho Gốc (`oanhcuongdo/project-ptuddd`)

| PR | Trạng thái | Tác giả / Nhóm | Nhánh nguồn | Số tệp thay đổi | Tiêu đề PR | Đánh giá tuân thủ quy chuẩn |
| :-: | :--- | :--- | :--- | :---: | :--- | :--- |
| **#2** | OPEN | `linhdontcare` (Nhóm 07) | `linhdontcare:nhom07-65ktpm` | 4 | `docs(nhom07-65ktpm): cap nhat danh sach nhom va thong tin thanh vien` | Đúng nhánh và thư mục; tiêu đề PR chưa theo mẫu `[Nộp bài] ...`, thiếu thư mục `src/`, `danhsachnhom.md` còn thiếu email thành viên. |
| **#3** | OPEN | `phamquanganhcode` (Nhóm 05) | `phamquanganhcode:nhom05-65ktpm` | 101 | `feat(nhom05-65ktpm): them danh sach nhom va ma nguon Speak Up (TH3)` | Đúng nhánh, mã nguồn Flutter sạch `.gitignore`; thiếu thư mục `docs/`, tiêu đề PR chưa theo mẫu `[Nộp bài] ...`. |
| **#4** | OPEN | `DuongNguyenAnhh-3185` (Nhóm 15) | `DuongNguyenAnhh-3185:nhom15-65ktpm` | 192 | `[Nộp bài] nhom15-65ktpm - Ứng dụng học toán Finger Math...` | **Đạt chuẩn:** đúng nhánh, đúng tiêu đề PR, đủ `danhsachnhom.md`, `docs/`, `src/`, không sửa tệp gốc, không vi phạm `.gitignore`. |
| **#5** | OPEN | `lucthuan1601` (Nhóm 18) | `lucthuan1601:nhom/nhom18-65ktpm` | 2 | `[Nộp bài] Nhóm 18 - 65KTPM` | Dùng nhánh tiền tố cũ `nhom/...`; tệp `.docx` đặt ngoài `docs/`, chưa có `src/`. |
| **#6** | OPEN | `VietPham21` (Nhóm 02) | `VietPham21:nhom02-65ktpm` | 3 | `[Nộp bài] nhom02-65ktpm - Khởi tạo thư mục nhóm và danh sách thành viên` | Đúng nhánh, cấu trúc và tiêu đề; mới ở bước khởi tạo, chưa có nội dung đề tài và mã nguồn. |
| **#7** | OPEN | `Minh-lab` (Nhóm 03) | `Minh-lab:nhom03-65ktpm` | 148 | `feat: khoi tao thu muc nhom03-65ktpm va ma nguon NoteSmart` | Đúng nhánh và cấu trúc (`danhsachnhom.md`, `docs/`, `src/`); tiêu đề PR chưa theo mẫu `[Nộp bài] ...`, commit bởi tài khoản bot. |
| **#8** | OPEN | `Khacsy05` (Nhóm 01) | `Khacsy05:nhom01-65ktpm` | 7 | `feat(nhom01-65ktpm): nop cai dat thu muc va tai lieu` | **[Lỗi]** Sửa tệp `README.md` ở thư mục gốc (`+35/-10`); đính kèm tệp tạm Word `~$O_CAO_DE_CUONG_TH4_BALLER_DISCIPLINE.docx` và tệp thừa `test.md`, `docs/report`. |
| **#9** | OPEN | `pvhung2112` (Nhóm 09) | `pvhung2112:nhom9-65ktpm` | 13 | `feat(nhom09-65ktpm): cap nhat danh sach nhom va khoi tao thu muc` | Đúng cấu trúc `danhsachnhom.md`, `docs/`, `src/`; tên nhánh và thư mục thiếu số `0` (`nhom9-65ktpm` thay vì `nhom09-65ktpm`). |
| **#10** | OPEN | `Maya0612` (Nhóm 14) | `Maya0612:nhom14-65ktpm` | 152 | `[Nộp bài] nhom14-65ktpm` | Đúng nhánh và sạch `.gitignore`; tuy nhiên `danhsachnhom.md` bị di chuyển vào `docs/danhsachnhom.md` thay vì ở cấp gốc của `nhom14-65ktpm/`. |
| **#11** | OPEN | `iam-mia` (Nhóm 13) | `iam-mia:nhom/nhom13-65ktpm` | 190 | `Nhom/nhom13 65ktpm` | **[Lỗi]** Đưa tệp `danhsachnhom.md` ra thư mục gốc repository; dùng nhánh tiền tố cũ `nhom/...`; thư mục mã nguồn đặt là `tlu_peerlearn/` thay vì `src/`. |
| **#15** | OPEN | `ThuHoai10` (Nhóm 15) | `DuongNguyenAnhh-3185:feature/nhom15/...` | 192 | `Feature/nhom15/nguyen thi thu hoai 2351170594` | **[Lỗi quy trình]** Thành viên mở nhầm PR từ nhánh cá nhân trực tiếp lên kho gốc (Nhóm 15 đã có PR `#4` hợp lệ). Cần đóng PR `#15`. |
| **#20** | OPEN | `khanhviphy29-blip` (Nhóm 08) | `dinhan125:nhom08-65ktpm` | 154 | `Nhom08 65ktpm` | Đúng nhánh và cấu trúc (`danhsachnhom.md`, `docs/`, `src/`); tiêu đề PR chưa theo mẫu `[Nộp bài] ...`. |
| **#21** | OPEN | `NguyenTruongNT` (Nhóm 12) | `NguyenTruongNT:main` | 2 | `Nhóm 12 - 65KTPM: Phối hợp làm việc nhóm trên GitHub` | **[Lỗi nhánh]** Tạo PR từ nhánh `main` của fork thay vì nhánh riêng `nhom12-65ktpm`; thiếu thư mục `src/`. |
| **#1, #12–#14, #16–#19, #22–#23** | CLOSED | Nhóm 11, 13, 09, 15, 16 | Nhiều nhánh cá nhân | - | *(Các PR đã đóng, không merge)* | PR `#1` do Nhóm 11 tự đóng từ 20/10; 09 PR còn lại do thành viên mở nhầm lên kho gốc rồi đóng lại. |

---

## 6. Tổng Kết Các Vấn Đề Kỹ Thuật Cần Khắc Phục

1. **Nhóm chưa nộp PR về kho gốc (06 nhóm):** Nhóm 10 (nhiều commit nhất: 135 commits), Nhóm 16 (53 commits), Nhóm 04, Nhóm 06, Nhóm 11 (đã đóng PR `#1` cũ), Nhóm 19. Ngoài ra **Nhóm 17** chưa có kho fork công khai.
2. **Vi phạm phạm vi tệp gốc (Root Directory):**
   - **PR `#8` (Nhóm 01):** Sửa trực tiếp `README.md` ở root và đẩy tệp lock tạm `~$O_CAO_DE_CUONG_TH4_BALLER_DISCIPLINE.docx`.
   - **PR `#11` (Nhóm 13):** Tạo thêm `danhsachnhom.md` ở root repository.
3. **Sai vị trí tệp / tên nhánh:**
   - **Nhóm 14 (PR `#10`):** Đặt `danhsachnhom.md` bên trong `nhom14-65ktpm/docs/` thay vì `nhom14-65ktpm/danhsachnhom.md`.
   - **Nhóm 12 (PR `#21`):** Mở PR từ nhánh `main` thay vì nhánh `nhom12-65ktpm`.
   - **Nhóm 15 (PR `#15`):** Thành viên mở dư 01 PR cá nhân lên kho gốc (cần đóng PR `#15`, chỉ giữ PR `#4`).
   - **Nhóm 09 (`nhom9-65ktpm`):** Tên nhánh và thư mục thiếu số `0`; **Nhóm 11, 13, 18** vẫn dùng tiền tố `nhom/`.
4. **Dấu hiệu hoạt động nhân tạo trên nhật ký:**
   - Một số nhóm (Nhóm 11: 31 issues / 186 events; Nhóm 03: 22 issues / 110 events; Nhóm 06: 12 issues / 60 events; Nhóm 19: 11 issues / 50 events) sử dụng script tạo hàng loạt Issues nhưng chưa có hoặc có rất ít commit phát triển thực tế.
   - Nhóm 03 toàn bộ 7 commits đứng tên tài khoản bot (`rhoggs-bot-test-account` / `AI Assistant`), chưa ghi nhận commit trực tiếp từ tài khoản sinh viên thành viên.
   - Nhóm 10 cần lưu ý chuỗi commit giai đoạn 14/11–17/11 có timestamp tròn theo chu kỳ 12 phút (trước khi có các commit và PR review thực tế sau đó).
