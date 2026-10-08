# Báo giá SatiCus: ghi chú cho Claude

Ứng dụng tĩnh (`index.html`) trên GitHub Pages, dữ liệu trên Supabase project `xfgqtgzgptavhqjjklkh` (dùng chung với GOR, chỉ đụng các bảng `quote_*`).

Dòng máy và hãng là danh mục tạo riêng trong bảng `quote_taxonomy` (`kind` = `category` / `brand`). Model chỉ được dùng tên có trong danh mục.

## Quy trình "xử lý hộp thư báo giá"

Khi người dùng nhắn "xử lý hộp thư báo giá" (hoặc tương tự):

1. Đọc danh sách yêu cầu mới (không lấy `text_content` để tránh quá dài):
   `select id, file_name, note, hint_name, hint_maker, pages, created_by_name, length(text_content) as n from quote_inbox where status = 'new' order by created_at;`
2. Với từng yêu cầu, đọc chữ theo từng đoạn nếu dài:
   `select substr(text_content, 1, 60000) from quote_inbox where id = '…';`
3. Dịch và soạn model theo skill `lam-bao-gia` (quy tắc dịch, cách đặt tiêu đề mục, cấu hình tiêu chuẩn). Bắt buộc:
   - Chỉ dùng thông tin có trong tài liệu, không bịa. Thiếu thông tin thì để trống trường đó và ghi chú vào `result`.
   - Làm theo `note` của người gửi (model nào, bỏ phần nào).
   - Dòng máy và hãng do người gửi chọn từ danh mục: dùng **đúng nguyên văn** `hint_name` cho `name` và `hint_maker` cho `maker`. Không tự tạo dòng máy hay hãng mới trong `quote_taxonomy`; nếu tài liệu rõ ràng thuộc dòng máy/hãng khác thì ghi chú vào `result` để người dùng sửa.
   - Xuất xứ: dùng cách viết đã có trong thư viện (`select distinct origin from quote_products`).
   - Đơn vị theo cách viết của thư viện: `220V`, `5 kW`, `40°C`, `100 mL`, `150 m³/h`, `5 μS/cm`, `546 × 573 mm`.
4. Tạo model ở trạng thái **chờ duyệt**:
   `insert into quote_products (name, maker, model, code, origin, sections, scope, status, source) values (…, 'draft', 'Hộp thư: <file_name> (<created_by_name>)') returning id;`
   - `sections`: `[{"title": "Cấu trúc thiết bị:", "lines": ["…"]}]`
   - `scope`: `[{"code": "", "text": "…", "qty": "1"}]`; nhãn nhóm thì `qty` là `""`.
5. Cập nhật yêu cầu và **xóa phần chữ** để tiết kiệm dung lượng:
   `update quote_inbox set status = 'done', result = '<tóm tắt: tạo model nào, thiếu gì>', product_ids = '["id1","id2"]'::jsonb, text_content = '' where id = '…';`
   - Không xử lý được (không có chữ, sai tài liệu…): `status = 'failed'`, ghi lý do vào `result`, giữ nguyên `text_content`.
6. Báo lại cho người dùng: danh sách model đã tạo, những chỗ còn trống cần người duyệt kiểm tra.

Không đổi `status` của model sang `approved`: việc duyệt do người dùng làm trên ứng dụng.

## Kiểm thử

Không có truy cập mạng tới Supabase hay jsdelivr từ máy làm việc; chạy thử bằng Playwright với Supabase giả lập.
