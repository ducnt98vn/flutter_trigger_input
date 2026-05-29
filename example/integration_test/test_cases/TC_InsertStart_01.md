Mã ID: TC_InsertStart_01
Tên kịch bản: Người dùng chèn thực thể vào đầu văn bản bằng nút bấm.

1. BỐI CẢNH (GIVEN):
Người dùng đang ở màn hình: Trigger Input Page
Điều kiện sẵn có: Ô nhập liệu đang có văn bản "Welcome to the app".

2. HÀNH ĐỘNG (WHEN):
Bước 1: Người dùng nhấn vào nút "Add @Mention" ở trên bàn phím.

3. KẾT QUẢ (THEN):
Kết quả 1: Một mention ngẫu nhiên (ví dụ "@Alice") được chèn vào ngay đầu văn bản. Ô nhập liệu trở thành "@Alice Welcome to the app".
Kết quả 2: Văn bản cũ không bị mất, vị trí của các ký tự cũ được dịch chuyển chính xác về phía sau.
