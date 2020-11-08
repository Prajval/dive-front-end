import 'package:json_annotation/json_annotation.dart';

part 'keys_to_delete.g.dart';

@JsonSerializable()
class KeysToDeleteOnSignout {
  final Set<String> keys;

  KeysToDeleteOnSignout({this.keys});

  factory KeysToDeleteOnSignout.fromJson(Map<String, dynamic> json) =>
      _$KeysToDeleteOnSignoutFromJson(json);

  Map<String, dynamic> toJson() => _$KeysToDeleteOnSignoutToJson(this);
}
