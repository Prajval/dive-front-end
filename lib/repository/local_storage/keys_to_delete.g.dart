// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keys_to_delete.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeysToDeleteOnSignout _$KeysToDeleteOnSignoutFromJson(
    Map<String, dynamic> json) {
  return KeysToDeleteOnSignout(
    keys: (json['keys'] as List)?.map((e) => e as String)?.toSet(),
  );
}

Map<String, dynamic> _$KeysToDeleteOnSignoutToJson(
        KeysToDeleteOnSignout instance) =>
    <String, dynamic>{
      'keys': instance.keys?.toList(),
    };
