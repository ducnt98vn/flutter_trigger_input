// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuggestionInfo _$SuggestionInfoFromJson(Map<String, dynamic> json) =>
    SuggestionInfo(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SuggestionInfoToJson(SuggestionInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'score': instance.score,
    };
