# Báo giá SatiCus: ghi chú cho Claude

Ứng dụng tĩnh (`index.html`) trên GitHub Pages, dữ liệu trên Supabase project `xfgqtgzgptavhqjjklkh` (dùng chung với GOR, chỉ đụng các bảng `quote_*`).

Dòng máy và hãng là danh mục tạo riêng trong bảng `quote_taxonomy` (`kind` = `category` / `brand`). Model chỉ được dùng tên có trong danh mục.

## Tạo model từ catalog người dùng gửi trong chat

Tính năng Hộp thư nhập liệu đã gỡ khỏi ứng dụng (lấy chữ từ PDF làm hỏng bảng thông số nhiều model). Người dùng gửi catalog trực tiếp trong chat.

- Dịch và soạn theo skill `lam-bao-gia`: chỉ dùng thông tin trong tài liệu; hỏi người dùng khi thiếu xuất xứ hoặc thông tin bắt buộc; không tự viết phần "Cung cấp bao gồm" (để `scope` trống).
- Dòng máy và hãng phải có sẵn trong `quote_taxonomy`; không tự tạo mới, hỏi người dùng nếu chưa có.
- Đơn vị theo cách viết của thư viện: `220V`, `5 kW`, `40°C`, `100 mL`, `150 m³/h`, `5 μS/cm`, `546 × 573 mm`.
- Tạo model ở trạng thái chờ duyệt: `status = 'draft'`, `source = 'Claude: <tên file>'`. Chỉ Super Admin duyệt trên ứng dụng; không tự đổi sang `approved`.

## Kiểm thử

Không có truy cập mạng tới Supabase hay jsdelivr từ máy làm việc; chạy thử bằng Playwright với Supabase giả lập.
