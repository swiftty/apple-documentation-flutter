import 'package:freezed_annotation/freezed_annotation.dart';

part 'technology_id.freezed.dart';

@Freezed(fromJson: false, toJson: false, copyWith: false)
abstract class TechnologyId with _$TechnologyId {
  const TechnologyId._();

  const factory TechnologyId(String value) = _TechnologyId;

  factory TechnologyId.fromJson(String json) => TechnologyId(json);
  String toJson() => value;
}
