// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'length_map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LengthMap _$LengthMapFromJson(Map<String, dynamic> json) => LengthMap(
      start: (json['start'] as num).toInt(),
      end: (json['end'] as num).toInt(),
      displayStr: json['display_str'] as String,
      originStr: json['origin_str'] as String? ?? '',
    );

Map<String, dynamic> _$LengthMapToJson(LengthMap instance) => <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
      'display_str': instance.displayStr,
      'origin_str': instance.originStr,
    };
