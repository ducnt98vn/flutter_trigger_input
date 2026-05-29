Mã ID: TC_PasteMarkup_01
Tên kịch bản: Người dùng dán (Paste) đoạn văn bản chứa mã BBCode thành công.

1. BỐI CẢNH (GIVEN):
Người dùng đang ở màn hình: Trigger Input Page
Điều kiện sẵn có: Người dùng có một đoạn mã BBCode trong clipboard, ví dụ: `Check [mention trigger="@" id="u1" name="John Doe"][/mention]`.

2. HÀNH ĐỘNG (WHEN):
Bước 1: Người dùng nhấn giữ vào ô nhập liệu và chọn "Paste" (Dán).

3. KẾT QUẢ (THEN):
Kết quả 1: Ô nhập liệu hiển thị văn bản đã được giải mã: "Check @John Doe". 
Kết quả 2: Chữ "@John Doe" được highlight (có màu sắc/style) ngay lập tức, chứng tỏ hệ thống đã nhận diện được thực thể từ mã BBCode.
Kết quả 3: Bảng Markup phía trên hiển thị đúng cấu trúc BBCode ban đầu.
