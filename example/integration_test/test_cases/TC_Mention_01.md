Mã ID: TC_Mention_01
Tên kịch bản: Người dùng thêm Mention thành công.

1. BỐI CẢNH (GIVEN):
Người dùng đang ở màn hình: Trigger Input Page
Điều kiện sẵn có: Ô nhập liệu rỗng, danh sách gợi ý chưa hiển thị.

2. HÀNH ĐỘNG (WHEN):
Bước 1: Người dùng nhập ký tự "@" vào ô nhập liệu.
Bước 2: Người dùng chọn tên "John Doe" từ danh sách gợi ý hiển thị phía trên bàn phím.

3. KẾT QUẢ (THEN):
Kết quả 1: Ô nhập liệu hiển thị "@John Doe " (có khoảng trắng ở cuối nếu cấu hình appendSpaceOnAdd=true). Chữ "@John Doe" có màu xanh và in đậm.
Kết quả 2: Bảng hiển thị Full Text (Markup) xuất hiện mã BBCode: `[mention trigger="@" id="..." name="John Doe"][/mention]`.
