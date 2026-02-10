import '../bbob_plugin_helper/char.dart';

enum TokenType { word, tag, attributeName, attributeValue, space, newLine }

/// A token representation during parsing.
class Token {
  final TokenType type;
  final String value;
  final int linePosition;
  final int columnPosition;

  const Token(this.type, this.value, [int line = 0, int column = 0])
    : linePosition = line,
      columnPosition = column;

  bool get isText =>
      type == TokenType.space ||
      type == TokenType.newLine ||
      type == TokenType.word;

  bool get isTag => type == TokenType.tag;

  bool get isAttributeName => type == TokenType.attributeName;

  bool get isAttributeValue => type == TokenType.attributeValue;

  bool get isStart => !isEnd;

  bool get isEnd => value[0] == slash;

  String get name => isEnd ? value.substring(1) : value;

  @override
  toString() {
    return '$openSquareBracket$value$closeSquareBracket';
  }
}
