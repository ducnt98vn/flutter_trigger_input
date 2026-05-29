Mã ID: TC_AtomicDelete_01
Tên kịch bản: Người dùng xoá một phần thực thể dẫn đến xoá toàn bộ thực thể (Atomic Deletion).

1. BỐI CẢNH (GIVEN):
Người dùng đang ở màn hình: Trigger Input Page
Điều kiện sẵn có: Ô nhập liệu đang chứa một mention hoàn chỉnh, ví dụ: "Hello @John Doe".

2. HÀNH ĐỘNG (WHEN):
Bước 1: Người dùng đặt con trỏ sau chữ "@John Doe" và nhấn phím Backspace một lần (xoá chữ "e").

3. KẾT QUẢ (THEN):
Kết quả 1: Toàn bộ mention "@John Doe" biến mất khỏi ô nhập liệu. Ô nhập liệu chỉ còn lại "Hello ".
Kết quả 2: Trạng thái Markup cập nhật tương ứng, không còn chứa mã BBCode của mention đã xoá.
