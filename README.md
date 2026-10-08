# Báo giá SatiCus

Ứng dụng web lưu, tạo và xuất báo giá Excel theo form SatiCus.

1. **Thư viện báo giá** (màn hình đầu): model được nhóm theo **dòng máy** → **hãng**, có bộ lọc theo dòng máy, theo hãng và ô tìm kiếm.
2. **Chọn model**: tick một hoặc nhiều model, thanh dưới cùng hiện số model đã chọn.
3. **Xuất báo giá**: điền số lượng, đơn giá từng model, bỏ/đổi SL cấu hình tiêu chuẩn, thông tin khách, ngày, điều khoản → tải file Excel.

Trong dữ liệu: dòng máy = cột `name`, hãng = cột `maker`.

- Giao diện: `index.html` tĩnh, chạy trên GitHub Pages.
- Dữ liệu và đăng nhập: dùng chung project Supabase với Alex workspace (cùng tên đăng nhập, mật khẩu, vai trò).
- Bảng riêng của ứng dụng: `quote_products` (thư viện máy), `quote_settings` (cài đặt báo giá). Không sửa bảng nào của Alex workspace.

## Quyền

| Vai trò trong Alex workspace | Thư viện máy | Cài đặt báo giá |
|---|---|---|
| super_admin, admin | Xem, thêm, sửa, xóa | Sửa |
| manager, user, cto_coo | Xem, thêm, sửa, xóa | Xem |
| Chưa đăng nhập | Không truy cập | Không truy cập |

## Cấu trúc

- `index.html` – toàn bộ ứng dụng
- `config.js` – địa chỉ Supabase và khóa công khai
- `supabase/schema.sql` – tạo 2 bảng và chính sách RLS (đã chạy)
- `supabase/seed.sql` – dữ liệu ban đầu: cài đặt công ty, máy LW230H (đã chạy)
- `supabase/002_nhap_lieu.sql` – trạng thái duyệt, đoạn mẫu dùng chung, hộp thư nhập liệu
- `supabase/003_danh_muc.sql` – danh mục dòng máy và hãng
- `supabase/004_hop_thu_super_admin.sql` – khóa hộp thư cho Super Admin
- `CLAUDE.md` – quy trình Claude xử lý hộp thư

## Nhập model

Trang **Thêm model** có: nhập từ file Excel báo giá cũ, nhân bản model, công cụ gộp dòng bị ngắt / tự nhận tiêu đề / dọn dòng trống, dán cấu hình tiêu chuẩn từ Excel, xem trước trực tiếp, cảnh báo trùng model và tự lưu bản nháp.

Thêm từ bản nâng cấp nhập liệu:

- **Kiểm tra trước khi lưu**: cảnh báo tiêu đề mục trống, dòng còn tiếng Anh, mục cấu hình thiếu mô tả hoặc SL; gợi ý thiếu xuất xứ, dòng lặp, dòng quá dài. Còn cảnh báo thì phải bấm Lưu lần hai.
- **Chuẩn hóa ký hiệu**: `m3` → `m³`, `+/-` → `±`, `oC` → `°C`, `546x573` → `546 × 573`, `220 v` → `220V`, `5kw` → `5 kW`, `uS/cm` → `μS/cm`, `100 ml` → `100 mL`. Có Hoàn tác.
- **Khung mục theo dòng máy**: lấy các tiêu đề mục mà model cùng dòng máy đang dùng.
- **Đoạn mẫu / Mục mẫu**: lưu và chèn đoạn mô tả hoặc bộ mục cấu hình dùng chung; gợi ý mục giống nhau ở từ 2 model.
- **Xem nội dung bản nháp** trước khi khôi phục.

## Hộp thư nhập liệu

Chỉ tài khoản **Super Admin** thấy và dùng được (giao diện ẩn mục này với tài khoản khác, cơ sở dữ liệu cũng chặn). Gửi catalog PDF (ứng dụng chỉ trích phần chữ trên trình duyệt, không tải file lên) hoặc dán nội dung. Nhắn Claude "xử lý hộp thư báo giá"; Claude tạo model **Chờ duyệt**. Model chờ duyệt không chọn được để báo giá cho tới khi có người mở ra và bấm **Duyệt và lưu**.

## Dòng máy & hãng

Danh mục tạo riêng ở trang **Dòng máy & hãng**: thêm, đổi tên (cập nhật luôn các model đang dùng), xóa (chỉ khi chưa có model nào dùng). Khi thêm model hoặc gửi catalog vào hộp thư, người dùng chọn dòng máy và hãng từ danh mục; không gõ tự do. Dòng máy chưa có model vẫn hiện trong bộ lọc thư viện.
