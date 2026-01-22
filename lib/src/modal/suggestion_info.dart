import 'package:json_annotation/json_annotation.dart';

part 'suggestion_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SuggestionInfo {
  String id;
  String name;
  int score;

  SuggestionInfo({required this.id, this.name = '', this.score = 0});

  String get suggestionName {
    return name;
  }

  factory SuggestionInfo.fromJson(Map<String, dynamic> json) =>
      _$SuggestionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SuggestionInfoToJson(this);
}
