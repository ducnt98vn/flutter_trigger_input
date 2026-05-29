Mã ID: TC_VietnameseIME_01
Tên kịch bản: Xử lý bộ gõ tiếng Việt (Telex/VNI) và biến đổi ký tự có dấu.

1. BỐI CẢNH (GIVEN):
Người dùng đang ở màn hình: Trigger Input Page
Điều kiện sẵn có: Ô nhập liệu đang chứa từ "sao".

2. HÀNH ĐỘNG (WHEN):
Bước 1: Người dùng đặt con trỏ sau chữ "sao" và nhập thêm ký tự "s" (quy tắc Telex để tạo dấu sắc).

3. KẾT QUẢ (THEN):
Kết quả 1: Ô nhập liệu hiển thị chính xác chữ "sáo". 
Kết quả 2: Con trỏ (cursor) vẫn giữ đúng vị trí ở cuối từ (vị trí index 3), không bị nhảy về giữa hoặc đầu câu.
Kết quả 3: Nếu phía trước hoặc phía sau từ này có các Mention/Hashtag, vị trí của chúng không bị dịch chuyển sai lệch do sự biến đổi của ký tự (từ 3 ký tự "sao" + 1 ký tự "s" gộp thành 3 ký tự "sáo").
