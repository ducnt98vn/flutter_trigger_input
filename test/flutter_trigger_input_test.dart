// import 'package:flutter_test/flutter_test.dart';
// import 'package:fb_tag_editor/src/logic/bbcode_parser.dart';
// import 'package:fb_tag_editor/src/models/tag_user_model.dart';

// void main() {
//   late BBCodeParser parser;

//   // Setup chạy trước mỗi bài test để đảm bảo môi trường sạch
//   setUp(() {
//     parser = BBCodeParser();
//   });

//   group('BBCodeParser - Basic Cases (Trường hợp cơ bản)', () {
//     test('1. Chuỗi rỗng -> Trả về chuỗi rỗng', () {
//       final result = parser.generateBBCode("", []);
//       expect(result, "");
//     });

//     test('2. Chuỗi text thường không có tag -> Trả về nguyên gốc', () {
//       final input = "Xin chào mọi người";
//       final result = parser.generateBBCode(input, []);
//       expect(result, "Xin chào mọi người");
//     });

//     test('3. Chuỗi có ký tự @ nhưng không phải tag -> Trả về nguyên gốc', () {
//       final input = "Email của tôi là admin@gmail.com";
//       final result = parser.generateBBCode(input, []);
//       expect(result, "Email của tôi là admin@gmail.com");
//     });
//   });

//   group('BBCodeParser - Tagging Cases (Trường hợp có Tag)', () {
//     // Giả lập dữ liệu user
//     final userA = TagUser(id: '101', name: 'Trung Duc');
//     final userB = TagUser(id: '102', name: 'Elon Musk');

//     test('4. Tag 1 người ở cuối câu', () {
//       // Input trên màn hình: "Hello Trung Duc"
//       final input = "Hello Trung Duc";
//       final tags = [userA];

//       final result = parser.generateBBCode(input, tags);

//       // Mong đợi: Format tùy bạn quy định, ví dụ: [tag id=...]name[/tag]
//       expect(result, "Hello [tag id=101]Trung Duc[/tag]");
//     });

//     test('5. Tag 1 người ở đầu câu', () {
//       final input = "Trung Duc ơi ra lấy hàng";
//       final result = parser.generateBBCode(input, [userA]);
//       expect(result, "[tag id=101]Trung Duc[/tag] ơi ra lấy hàng");
//     });

//     test('6. Tag 1 người ở giữa câu', () {
//       final input = "Hôm nay Trung Duc có đi làm không?";
//       final result = parser.generateBBCode(input, [userA]);
//       expect(result, "Hôm nay [tag id=101]Trung Duc[/tag] có đi làm không?");
//     });

//     test('7. Tag nhiều người khác nhau', () {
//       final input = "Trung Duc và Elon Musk là bạn thân";
//       final tags = [userA, userB];

//       final result = parser.generateBBCode(input, tags);

//       expect(result, "[tag id=101]Trung Duc[/tag] và [tag id=102]Elon Musk[/tag] là bạn thân");
//     });
//   });

//   group('BBCodeParser - Edge Cases & Complex Logic (Trường hợp hiểm hóc)', () {
//     final userA = TagUser(id: '101', name: 'Nam');
//     final userB = TagUser(id: '102', name: 'Nam'); // Trùng tên nhưng khác ID

//     test('8. Trùng tên hiển thị nhưng khác ID (Case quan trọng nhất)', () {
//       // Ví dụ: Tag bạn Nam (ID 101) và bạn Nam (ID 102) trong cùng 1 câu
//       final input = "Chào Nam và Nam nhé";
//       // List tags phải lưu được vị trí hoặc thứ tự
//       final tags = [userA, userB];

//       final result = parser.generateBBCode(input, tags);

//       // Parser phải đủ thông minh để map đúng người
//       expect(result, "Chào [tag id=101]Nam[/tag] và [tag id=102]Nam[/tag] nhé");
//     });

//     test('9. Người dùng xóa mất một phần tên của Tag', () {
//       // Đáng lẽ là "Hello Trung Duc", user xóa chữ "Duc" còn "Hello Trung"
//       // Lúc này logic của bạn phải quyết định: Xóa tag hay giữ tag?
//       // Thường thì: Nếu text không khớp hoàn toàn với user.name -> Xóa tag đó khỏi list.

//       final input = "Hello Trung";
//       final userOriginal = TagUser(id: '101', name: 'Trung Duc');

//       final result = parser.generateBBCode(input, [userOriginal]);

//       // Mong đợi: Không sinh ra BBCode vì tên đã bị sửa
//       expect(result, "Hello Trung");
//     });

//     test('10. Tag dính liền với ký tự đặc biệt', () {
//       final input = "Hello(Trung Duc)!"; // Dính dấu ngoặc
//       final user = TagUser(id: '101', name: 'Trung Duc');

//       final result = parser.generateBBCode(input, [user]);

//       expect(result, "Hello([tag id=101]Trung Duc[/tag])!");
//     });

//     test('11. Tag chứa ký tự đặc biệt trong tên', () {
//       final userCrazy = TagUser(id: '999', name: 'Mr. Robot #1');
//       final input = "Gửi Mr. Robot #1 file log nhé";

//       final result = parser.generateBBCode(input, [userCrazy]);

//       expect(result, "Gửi [tag id=999]Mr. Robot #1[/tag] file log nhé");
//     });
//   });
// }
