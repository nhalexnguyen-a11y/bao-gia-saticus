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

## Nhập model

Trang **Thêm model** có: nhập từ file Excel báo giá cũ, nhân bản model, công cụ gộp dòng bị ngắt / tự nhận tiêu đề / dọn dòng trống, dán cấu hình tiêu chuẩn từ Excel, xem trước trực tiếp, cảnh báo trùng model và tự lưu bản nháp.
