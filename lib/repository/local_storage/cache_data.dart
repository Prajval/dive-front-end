import 'package:json_annotation/json_annotation.dart';

part 'cache_data.g.dart';

@JsonSerializable()
class CacheData {
  final String key;
  final bool shouldEraseOnSignout;
  final int expiryInHours;
  final DateTime timeOfEntry;
  final dynamic data;

  CacheData({
    this.key,
    this.shouldEraseOnSignout,
    this.expiryInHours,
    this.timeOfEntry,
    this.data,
  });

  factory CacheData.fromJson(Map<String, dynamic> json) =>
      _$CacheDataFromJson(json);

  Map<String, dynamic> toJson() => _$CacheDataToJson(this);
}
