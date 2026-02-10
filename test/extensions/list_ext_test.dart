import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/extensions/list_ext.dart';

void main() {
  group('ListExtension Tests', () {
    final list = ['A', 'B', 'C'];

    test('tryGet: trả về phần tử đúng index', () {
      expect(list.tryGet(0), 'A');
      expect(list.tryGet(2), 'C');
    });

    test('tryGet: trả về null khi index ngoài phạm vi hoặc null', () {
      expect(list.tryGet(-1), isNull);
      expect(list.tryGet(3), isNull);
      expect(list.tryGet(null), isNull);
    });
  });
}
