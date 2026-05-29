Mã ID: TC_MultiTrigger_01
Tên kịch bản: Người dùng sử dụng đồng thời nhiều loại trigger trong một đoạn văn bản.

1. BỐI CẢNH (GIVEN):
Người dùng đang ở màn hình: Trigger Input Page
Điều kiện sẵn có: App hỗ trợ trigger '@' cho mention và '#' cho hashtag.

2. HÀNH ĐỘNG (WHEN):
Bước 1: Người dùng nhập "@" và chọn một user.
Bước 2: Người dùng nhập thêm chữ " is talking about " và nhập "#", sau đó chọn một hashtag.

3. KẾT QUẢ (THEN):
Kết quả 1: Ô nhập liệu hiển thị cả hai thực thể với phong cách (style) riêng biệt đã định nghĩa (vd: user màu xanh, hashtag màu hồng).
Kết quả 2: Markup hiển thị đầy đủ cả thẻ `[mention]` và `[hashtag]` lồng trong văn bản thô.
