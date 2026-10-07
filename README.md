# Báo giá SatiCus

Ứng dụng web tạo báo giá Excel theo form SatiCus: thư viện máy dùng chung, điền khách hàng, giá, ngày, điều khoản và xuất file `.xlsx`.

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
