Mã ID: TC_KeywordSpace_01
Tên kịch bản: Người dùng tìm kiếm mention có dấu cách trong tên (allowSpace).

1. BỐI CẢNH (GIVEN):
Người dùng đang ở màn hình: Trigger Input Page
Điều kiện sẵn có: Thuộc tính `allowSpace` của `TriggerInputField` được thiết lập là `true`.

2. HÀNH ĐỘNG (WHEN):
Bước 1: Người dùng nhập "@Nguyen".
Bước 2: Người dùng nhập thêm dấu cách và chữ "Trung" (Thành "@Nguyen Trung").

3. KẾT QUẢ (THEN):
Kết quả 1: Danh sách gợi ý vẫn tiếp tục hiển thị và lọc theo từ khoá "Nguyen Trung".
Kết quả 2: Nếu người dùng nhấn chọn gợi ý, toàn bộ cụm "@Nguyen Trung" sẽ được chuyển thành một thực thể mention hoàn chỉnh.
