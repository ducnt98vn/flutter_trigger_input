import 'package:flutter_quill/flutter_quill.dart';

class MentionEmbed extends CustomBlockEmbed {
  const MentionEmbed(String value) : super(mentionType, value);

  static const String mentionType = 'mention';

  // Chuyển đổi dữ liệu JSON từ Delta thành Embed
  static MentionEmbed fromMap(Map<String, dynamic> data) {
    return MentionEmbed(data.toString());
  }
}
