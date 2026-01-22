import 'package:json_annotation/json_annotation.dart';

part 'length_map.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LengthMap {
  LengthMap({
    required this.start,
    required this.end,
    required this.displayStr,
    this.originStr = '',
  });

  int start;
  int end;
  String displayStr;
  String originStr;

  String get trigger => displayStr.substring(0, 1);

  factory LengthMap.fromJson(Map<String, dynamic> json) =>
      _$LengthMapFromJson(json);
  Map<String, dynamic> toJson() => _$LengthMapToJson(this);
}
