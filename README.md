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

Theo cấp của GOR (`profiles.role`). Cơ sở dữ liệu chặn bằng RLS và trigger (`supabase/007_phan_quyen.sql`), giao diện ẩn nút tương ứng.

| Quyền | Super Admin | Admin | CTO/COO | Manager | User |
|---|---|---|---|---|---|
| Xem thư viện, tạo và xuất báo giá | ✓ | ✓ | ✓ | ✓ | ✓ |
| Thêm, sửa model | ✓ | ✓ | ✓ | ✓ (về chờ duyệt) | |
| Duyệt model | ✓ | | | | |
| Xóa model | ✓ | ✓ | ✓ | | |
| Dòng máy & hãng | ✓ | ✓ | ✓ | | |
| Cài đặt, điều khoản | ✓ | ✓ | ✓ | | |
| Mục mẫu, đoạn mẫu | ✓ | ✓ | ✓ | ✓ | |

CTO/COO có quyền như Admin chỉ trong thư viện báo giá (`supabase/008_cto_coo_nhu_admin.sql`); quyền trong GOR không đổi.

Chưa đăng nhập: không truy cập.

## Cấu trúc

- `index.html` – toàn bộ ứng dụng
- `config.js` – địa chỉ Supabase và khóa công khai
- `supabase/schema.sql` – tạo 2 bảng và chính sách RLS (đã chạy)
- `supabase/seed.sql` – dữ liệu ban đầu: cài đặt công ty, máy LW230H (đã chạy)
- `supabase/002_nhap_lieu.sql` – trạng thái duyệt, đoạn mẫu dùng chung, hộp thư nhập liệu
- `supabase/003_danh_muc.sql` – danh mục dòng máy và hãng
- `supabase/004_hop_thu_super_admin.sql` – khóa hộp thư cho Super Admin (hộp thư đã gỡ khỏi ứng dụng)
- `supabase/005_duyet_super_admin.sql` – chỉ Super Admin duyệt model
- `supabase/006_xoa_hop_thu.sql` – xóa bảng hộp thư
- `supabase/007_phan_quyen.sql` – phân quyền theo cấp GOR
- `supabase/008_cto_coo_nhu_admin.sql` – CTO/COO có quyền như Admin trong thư viện báo giá
- `CLAUDE.md` – ghi chú cho Claude

## Nhập model

Trang **Thêm model** có: nhập từ file Excel báo giá cũ, nhân bản model, công cụ gộp dòng bị ngắt / tự nhận tiêu đề / dọn dòng trống, dán cấu hình tiêu chuẩn từ Excel, xem trước trực tiếp, cảnh báo trùng model và tự lưu bản nháp.

Thêm từ bản nâng cấp nhập liệu:

- **Kiểm tra trước khi lưu**: cảnh báo tiêu đề mục trống, dòng còn tiếng Anh, mục cấu hình thiếu mô tả hoặc SL; gợi ý thiếu xuất xứ, dòng lặp, dòng quá dài. Còn cảnh báo thì phải bấm Lưu lần hai.
- **Chuẩn hóa ký hiệu**: `m3` → `m³`, `+/-` → `±`, `oC` → `°C`, `546x573` → `546 × 573`, `220 v` → `220V`, `5kw` → `5 kW`, `uS/cm` → `μS/cm`, `100 ml` → `100 mL`. Có Hoàn tác.
- **Khung mục theo dòng máy**: lấy các tiêu đề mục mà model cùng dòng máy đang dùng.
- **Đoạn mẫu / Mục mẫu**: lưu và chèn đoạn mô tả hoặc bộ mục cấu hình dùng chung; gợi ý mục giống nhau ở từ 2 model.
- **Xem nội dung bản nháp** trước khi khôi phục.

## Model chờ duyệt

Model do Claude tạo từ catalog (gửi file trong chat) ở trạng thái **Chờ duyệt**: không chọn được để báo giá cho tới khi Super Admin mở ra và bấm **Duyệt và lưu**. Admin và Manager sửa được nhưng không duyệt được (cơ sở dữ liệu cũng chặn).

(Tính năng Hộp thư nhập liệu đã gỡ khỏi ứng dụng và bảng `quote_inbox` đã xóa.)

## Dòng máy & hãng

Danh mục tạo riêng ở trang **Dòng máy & hãng**: thêm, đổi tên (cập nhật luôn các model đang dùng), xóa (chỉ khi chưa có model nào dùng). Khi thêm model hoặc gửi catalog vào hộp thư, người dùng chọn dòng máy và hãng từ danh mục; không gõ tự do. Dòng máy chưa có model vẫn hiện trong bộ lọc thư viện.
