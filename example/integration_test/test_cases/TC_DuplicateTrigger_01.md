Mã ID: TC_DuplicateTrigger_01
Tên kịch bản: Nhập ký tự trùng với ký tự đầu của Mention.

1. BỐI CẢNH (GIVEN):
Người dùng đang ở màn hình: Trigger Input Page
Điều kiện sẵn có: Ô nhập liệu đang chứa mention: "@James".

2. HÀNH ĐỘNG (WHEN):
Bước 1: Người dùng đặt con trỏ ở ngay trước chữ "@James" và gõ thêm một ký tự "@".

3. KẾT QUẢ (THEN):
Kết quả 1: Văn bản trở thành "@@James".
Kết quả 2: Ký tự "@" thứ hai (nguyên bản của mention cũ) vẫn là một phần của thực thể `@James`, còn ký tự "@" mới gõ sẽ kích hoạt danh sách gợi ý mới.
Kết quả 3: Toàn bộ vị trí của `@James` được dịch chuyển lùi về sau 1 đơn vị một cách chính xác.
