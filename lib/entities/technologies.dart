import 'package:freezed_annotation/freezed_annotation.dart';

part 'technologies.freezed.dart';
part 'technologies.g.dart';

/// Represents a technology.
@freezed
class Technologies with _$Technologies {
  const Technologies._();

  const factory Technologies({
    required List<Section> sections,
    // ignore: invalid_annotation_target
    @protected @JsonKey(name: 'references') required Map<String, Reference> rawReferences,
  }) = _Technologies;

  factory Technologies.fromJson(Map<String, dynamic> json) => _$TechnologiesFromJson(json);

  Reference? reference({required TechnologyId identifier}) => rawReferences[identifier.value];
}

@Freezed(unionKey: 'kind')
sealed class Section with _$Section {
  const factory Section.technologies({
    required String kind,
    required List<SectionGroup> groups,
  }) = SectionTechnologies;

  const factory Section.hero({
    required String kind,
    required String image,
  }) = SectionHero;

  factory Section.fromJson(Map<String, dynamic> json) => _$SectionFromJson(json);
}

@freezed
class SectionGroup with _$SectionGroup {
  const factory SectionGroup({
    required String name,
    required List<Technology> technologies,
  }) = _SectionGroup;

  factory SectionGroup.fromJson(Map<String, dynamic> json) => _$SectionGroupFromJson(json);
}

@freezed
class Technology with _$Technology {
  const factory Technology({
    required String title,
    required List<Abstract> content,
    @_LanguageEnumConverter() required List<Language> languages,
    required Destination destination,
    required List<String> tags,
  }) = _Technology;

  factory Technology.fromJson(Map<String, dynamic> json) => _$TechnologyFromJson(json);
}

@freezed
class Abstract with _$Abstract {
  const factory Abstract({
    required String type,
    required String text,
  }) = _Abstract;

  factory Abstract.fromJson(Map<String, dynamic> json) => _$AbstractFromJson(json);
}

/// Represents a technology identifier.
@Freezed(fromJson: false, toJson: false, copyWith: false)
class TechnologyId with _$TechnologyId {
  const TechnologyId._();

  const factory TechnologyId(String value) = _TechnologyId;

  factory TechnologyId.fromJson(String json) => TechnologyId(json);
  String toJson() => value;
}

/// Represents a technology destination.
@Freezed(unionKey: 'type')
sealed class Destination with _$Destination {
  const factory Destination.reference({
    required TechnologyId identifier,
    required bool isActive,
  }) = DestinationReference;

  factory Destination.fromJson(Map<String, dynamic> json) => _$DestinationFromJson(json);
}

@Freezed(unionKey: 'type', fallbackUnion: 'unknown')
sealed class Reference with _$Reference {
  const factory Reference.topic({
    required Kind kind,
    required Role role,
    required String title,
    required String url,
    required List<Abstract> abstract,
    @Default(false) bool deprecated,
  }) = ReferenceTopic;

  const factory Reference.link({
    required String title,
    required String url,
  }) = ReferenceLink;

  const factory Reference.image({
    required List<ImageVariant> variants,
  }) = ReferenceImage;

  const factory Reference.unknown({
    required TechnologyId identifier,
    required String type,
  }) = ReferenceUnknown;

  factory Reference.fromJson(Map<String, dynamic> json) => _$ReferenceFromJson(json);
}

@freezed
class ImageVariant with _$ImageVariant {
  const factory ImageVariant({
    required List<String> traits,
  }) = _ImageVariant;

  factory ImageVariant.fromJson(Map<String, dynamic> json) => _$ImageVariantFromJson(json);
}

enum Kind { article, symbol }

enum Role { article, collection }

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
