import 'package:freezed_annotation/freezed_annotation.dart';

part 'ref_id.freezed.dart';

@Freezed(fromJson: false, toJson: false, copyWith: false)
abstract class RefId with _$RefId {
  const RefId._();

  const factory RefId(String value) = _RefId;

  factory RefId.fromJson(String json) => RefId(json);
  String toJson() => value;
}
