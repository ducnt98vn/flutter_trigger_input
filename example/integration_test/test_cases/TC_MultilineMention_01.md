Mã ID: TC_MultilineMention_01
Tên kịch bản: Mention hoạt động chính xác trên văn bản nhiều dòng.

1. BỐI CẢNH (GIVEN):
Người dùng đang ở màn hình: Trigger Input Page
Điều kiện sẵn có: Ô nhập liệu đang có 2 dòng:
Dòng 1: "First line"
Dòng 2: "@John"

2. HÀNH ĐỘNG (WHEN):
Bước 1: Người dùng đặt con trỏ ở cuối Dòng 1 và nhập thêm " - updated".

3. KẾT QUẢ (THEN):
Kết quả 1: Văn bản trở thành:
"First line - updated"
"@John"
Kết quả 2: Mention "@John" ở dòng dưới vẫn giữ đúng vị trí và định dạng, không bị ảnh hưởng bởi việc thêm text ở dòng trên.
