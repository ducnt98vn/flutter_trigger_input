// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_diff_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextDiffResult _$TextDiffResultFromJson(Map<String, dynamic> json) =>
    TextDiffResult(
      leftStr: LengthMap.fromJson(json['left_str'] as Map<String, dynamic>),
      rightStr: LengthMap.fromJson(json['right_str'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TextDiffResultToJson(TextDiffResult instance) =>
    <String, dynamic>{
      'left_str': instance.leftStr.toJson(),
      'right_str': instance.rightStr.toJson(),
    };
