import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/src/controllers/tf_controller.dart';
import 'package:flutter_trigger_input/src/modal/mention_text_renderer_result.dart';
import 'package:flutter_trigger_input/src/utils/text_edit/mention_text_renderer.dart';

void main() {
  late MentionTextRenderer renderer;
  late TFController tfController;

  setUp(() {
    renderer = MentionTextRenderer();
    // Đảm bảo controller này có thuộc tính text, selection, mentionedStrs
    tfController = TFController();
  });

  void expectResult(MentionTextRendererResult result, String text, int offset) {
    expect(result.cacheDisplayText, text);
    expect(result.selection.extentOffset, offset);
    expect(result.selection.isCollapsed, isTrue);
    expect(result.mentionedStrs, isEmpty);
  }

  // Kiểm tra trạng thái rỗng, khởi tạo ban đầu, null hoặc -1.
  group('MentionTextRenderer - Nhóm 1: Khởi tạo & Case rỗng', () {
    test('1. Văn bản rỗng', () {
      tfController.text = "";
      tfController.selection = const TextSelection.collapsed(offset: 0);
      final result = renderer.execute(
        cacheDisplayText: "",
        tfController: tfController,
        cacheSelection: const TextSelection.collapsed(offset: 0),
      );
      expect(result.cacheDisplayText, "");
      expect(result.mentionedStrs, isEmpty);
    });
  });
  // Nhập liệu tiếng Anh/số, Cắt/Dán/Xóa đoạn văn bản thông thường.
  group('MentionTextRenderer - Nhóm 2: Chỉnh sửa văn bản cơ bản (1 byte)', () {
    test('1. Văn bản rỗng', () {
      final result = renderer.execute(
        cacheDisplayText: "",
        tfController: tfController
          ..text = ""
          ..selection = const TextSelection.collapsed(offset: 0),
        cacheSelection: const TextSelection.collapsed(offset: 0),
      );
      expect(result.cacheDisplayText, "");
      expect(result.mentionedStrs, isEmpty);
    });

    test('2. Nhập một ký tự', () {
      final result = renderer.execute(
        cacheDisplayText: "",
        tfController: tfController
          ..text = "1"
          ..selection = const TextSelection.collapsed(offset: 1),
        cacheSelection: const TextSelection.collapsed(offset: 0),
      );

      expectResult(result, '1', 1);
    });

    test('3. Xoá một ký tự', () {
      final result = renderer.execute(
        cacheDisplayText: "12345",
        tfController: tfController
          ..text = "1235"
          ..selection = const TextSelection.collapsed(offset: 3),
        cacheSelection: const TextSelection.collapsed(offset: 4),
      );
      expectResult(result, '1235', 3);
    });
  });
  // Tiếng Việt (Telex/VNI), Emoji, ký tự đặc biệt (nơi con trỏ dễ bị nhảy sai).
  group(
    'MentionTextRenderer - Nhóm 3: Nhập liệu phức tạp & IME (Nhiều byte)',
    () {
      test('1. Gõ tiếng Việt: "e" + "e" -> "ê"', () {
        final result = renderer.execute(
          cacheDisplayText: "e",
          tfController: tfController
            ..text = "ê"
            ..selection = const TextSelection.collapsed(offset: 1),
          cacheSelection: const TextSelection.collapsed(offset: 1),
        );

        expectResult(result, 'ê', 1);
      });

      test('2. Gõ tiếng Việt: "làm" + "f" -> "lamf"', () {
        final result = renderer.execute(
          cacheDisplayText: "lam",
          tfController: tfController
            ..text = "làm"
            ..selection = const TextSelection.collapsed(offset: 3),
          cacheSelection: const TextSelection.collapsed(offset: 3),
        );

        expectResult(result, 'làm', 3);
      });

      test(
        '3. Gõ nhanh từ dài (gợi ý từ bàn phím) có dấu: "tiên" -> "tiếng"',
        () {
          final result = renderer.execute(
            cacheDisplayText: "tiên",
            tfController: tfController
              ..text = "tiếng"
              ..selection = const TextSelection.collapsed(offset: 5),
            cacheSelection: const TextSelection.collapsed(offset: 4),
          );

          expectResult(result, 'tiếng', 5);
        },
      );
    },
  );
  //Thêm mới, xóa một phần, xóa toàn bộ, hoặc dán đè lên Mention.
  group('MentionTextRenderer - Nhóm 4: Vòng đời Mention (CRUD)', () {
    test('1. Gõ tiếng Việt: "e" + "e" -> "ê"', () {
      final result = renderer.execute(
        cacheDisplayText: "e",
        tfController: tfController
          ..text = "ê"
          ..selection = const TextSelection.collapsed(offset: 1),
        cacheSelection: const TextSelection.collapsed(offset: 1),
      );

      expectResult(result, 'ê', 1);
    });
  });

  // Di chuyển con trỏ đi qua Mention, đặt con trỏ giữa Mention, gõ sát Mention.
  group('MentionTextRenderer - Nhóm 5: Logic ranh giới và con trỏ', () {});

  // Thêm text vào TRƯỚC một mention
  // Thêm text vào SAU một mention
  // Xóa trắng mention bằng phím Backspace
  // Xóa một đoạn text chứa nhiều mention
  // Parse BBCode mention
  // Bôi đen mention và gõ đè ký tự mới
  // 12. Dán (Paste) một đoạn text dài chứa mention.
  // 13. Xóa ký tự trắng ngay trước mention.
  // 14. Gõ dấu cách liên tục giữa 2 mention.
  // 15. Mention nằm ở dòng thứ 2 (Text đa dòng \n).
  // 16. Nhập ký tự trùng với ký tự đầu của mention (vd: gõ thêm @ vào @James).
  // 17. Xử lý khi BBCode bị lỗi cú pháp (Try-catch check).
  // 18. Thay đổi ID của mention trong markup nhưng giữ nguyên Name.
  // 19. Kiểm tra sự thay đổi start/end khi mention nằm cuối cùng của văn bản.
  // 20. Case emoji xen kẽ mention: "Hi @James 🔥".
  // 21. Case text có chứa ký tự escape BBCode.
  // 22. Case mention có tên chứa khoảng trắng (nếu hỗ trợ).
}
