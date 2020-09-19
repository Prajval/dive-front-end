// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheData _$CacheDataFromJson(Map<String, dynamic> json) {
  return CacheData(
    key: json['key'] as String,
    shouldEraseOnSignout: json['shouldEraseOnSignout'] as bool,
    expiryInHours: json['expiryInHours'] as int,
    timeOfEntry: json['timeOfEntry'] == null
        ? null
        : DateTime.parse(json['timeOfEntry'] as String),
    data: json['data'],
  );
}

Map<String, dynamic> _$CacheDataToJson(CacheData instance) => <String, dynamic>{
      'key': instance.key,
      'shouldEraseOnSignout': instance.shouldEraseOnSignout,
      'expiryInHours': instance.expiryInHours,
      'timeOfEntry': instance.timeOfEntry?.toIso8601String(),
      'data': instance.data,
    };
