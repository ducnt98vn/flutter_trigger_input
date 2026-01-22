import 'package:json_annotation/json_annotation.dart';

import 'length_map.dart';

part 'text_diff_result.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TextDiffResult {
  LengthMap leftStr;
  LengthMap rightStr;

  TextDiffResult({required this.leftStr, required this.rightStr});

  factory TextDiffResult.fromJson(Map<String, dynamic> json) =>
      _$TextDiffResultFromJson(json);
  Map<String, dynamic> toJson() => _$TextDiffResultToJson(this);

  @override
  String toString() {
    return 'TextDiffResult('
        ' startStr1Index: ${leftStr.start}, '
        ' endStr1Index: ${leftStr.end}, '
        ' text1: ${leftStr.displayStr}, '
        ' startStr2Index: ${rightStr.start}, '
        ' endStr2Index: ${rightStr.end}, '
        ' text2: ${rightStr.displayStr})';
  }
}
