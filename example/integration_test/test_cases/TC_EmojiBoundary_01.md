Mã ID: TC_EmojiBoundary_01
Tên kịch bản: Chỉnh sửa văn bản có Emoji xen kẽ với Mention.

1. BỐI CẢNH (GIVEN):
Người dùng đang ở màn hình: Trigger Input Page
Điều kiện sẵn có: Ô nhập liệu đang chứa văn bản: "Hi @James 🔥".

2. HÀNH ĐỘNG (WHEN):
Bước 1: Người dùng đặt con trỏ sau emoji 🔥 và nhập thêm chữ " updated".

3. KẾT QUẢ (THEN):
Kết quả 1: Ô nhập liệu hiển thị: "Hi @James 🔥 updated".
Kết quả 2: Mention "@James" vẫn giữ nguyên định dạng màu sắc và vị trí, không bị dịch chuyển sai lệch do ảnh hưởng của emoji (vốn chiếm nhiều byte hơn ký tự thường).
