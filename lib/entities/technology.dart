import 'package:freezed_annotation/freezed_annotation.dart';

part 'technology.freezed.dart';
part 'technology.g.dart';

/// Represents a technology.
@freezed
class Technology with _$Technology {
  const factory Technology({
    required String title,
    required TechnologyDestination description,
    required List<String> tags,
    @_LanguageEnumConverter() required List<Language> languages,
  }) = _Technology;

  factory Technology.fromJson(Map<String, dynamic> json)
    => _$TechnologyFromJson(json);
}

/// Represents a technology identifier.
@freezed
class TechnologyId with _$TechnologyId {
  const factory TechnologyId(String value) = _TechnologyId;

  factory TechnologyId.fromJson(String json) => TechnologyId(json);
}

/// Represents a technology destination value.
@freezed
class TechnologyDestinationValue with _$TechnologyDestinationValue {
  const factory TechnologyDestinationValue(String value) = _TechnologyDestinationValue;

  factory TechnologyDestinationValue.fromJson(String json) => TechnologyDestinationValue(json);
}

/// Represents a technology destination.
@freezed
class TechnologyDestination with _$TechnologyDestination {
  const factory TechnologyDestination({
    required TechnologyId identifier,
    required String title,
    required TechnologyDestinationValue value,
    required String abstract,
  }) = _TechnologyDestination;

  factory TechnologyDestination.fromJson(Map<String, dynamic> json)
    => _$TechnologyDestinationFromJson(json);
}

/// Represents a language.
enum Language {
  objectiveC,
  swift,
  other,
}

class _LanguageEnumConverter implements JsonConverter<Language, String> {
  const _LanguageEnumConverter();

  @override
  Language fromJson(String json) {
    switch (json) {
      case "swift":
        return Language.swift;
      case "occ":
        return Language.objectiveC;
      default:
        return Language.other;
    }
  }

  @override
  String toJson(Language object) {
    switch (object) {
      case Language.swift:
        return "swift";
      case Language.objectiveC:
        return "occ";
      default:
        return "data";
    }
  }
}
