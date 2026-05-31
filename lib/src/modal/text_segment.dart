class TextSegment {
  String text;
  final Map<String, dynamic>? attributes;

  TextSegment({required this.text, this.attributes});

  bool get isPlain => attributes == null || attributes!.isEmpty;
  bool get isMention => attributes?.containsKey('mention') ?? false;
  bool get isHashtag => attributes?.containsKey('hashtag') ?? false;
  bool get isLink => attributes?.containsKey('link') ?? false;

  Map<String, dynamic> toJson() {
    return {'insert': text, if (attributes != null) 'attributes': attributes};
  }

  TextSegment copyWith({String? text, Map<String, dynamic>? attributes}) {
    return TextSegment(
      text: text ?? this.text,
      attributes: attributes ?? this.attributes,
    );
  }
}
