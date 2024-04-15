import 'package:freezed_annotation/freezed_annotation.dart';

part 'fetch_all_technologies_response.freezed.dart';
part 'fetch_all_technologies_response.g.dart';

@freezed
class FetchAllTechnologiesResponse with _$FetchAllTechnologiesResponse {
  const factory FetchAllTechnologiesResponse({
    required Metadata metadata,
    required String kind,
    required List<Section> sections,
    required Hierarchy hierarchy,
    required Identifier identifier,
    required SchemaVersion schemaVersion,
    required Map<String, Reference> references,
    required DiffAvailability diffAvailability,
    required LegalNotices legalNotices,
  }) = _FetchAllTechnologiesResponse;

  factory FetchAllTechnologiesResponse.fromJson(Map<String, dynamic> json) =>
      _$FetchAllTechnologiesResponseFromJson(json);
}

@freezed
class DiffAvailability with _$DiffAvailability {
  const factory DiffAvailability({
    required Beta minor,
    required Beta major,
    required Beta beta,
  }) = _DiffAvailability;

  factory DiffAvailability.fromJson(Map<String, dynamic> json) =>
      _$DiffAvailabilityFromJson(json);
}

@freezed
class Beta with _$Beta {
  const factory Beta({
    required String change,
    required String platform,
    required List<String> versions,
  }) = _Beta;

  factory Beta.fromJson(Map<String, dynamic> json) => _$BetaFromJson(json);
}

@freezed
class Hierarchy with _$Hierarchy {
  const factory Hierarchy({
    required List<HomepageNavigation> homepageNavigation,
  }) = _Hierarchy;

  factory Hierarchy.fromJson(Map<String, dynamic> json) =>
      _$HierarchyFromJson(json);
}

@freezed
class HomepageNavigation with _$HomepageNavigation {
  const factory HomepageNavigation({
    required String reference,
  }) = _HomepageNavigation;

  factory HomepageNavigation.fromJson(Map<String, dynamic> json) =>
      _$HomepageNavigationFromJson(json);
}

@freezed
class Identifier with _$Identifier {
  const factory Identifier({
    required Language interfaceLanguage,
    required String url,
  }) = _Identifier;

  factory Identifier.fromJson(Map<String, dynamic> json) =>
      _$IdentifierFromJson(json);
}

enum Language { data, occ, swift }

final languageValues = EnumValues(
    {"data": Language.data, "occ": Language.occ, "swift": Language.swift});

@freezed
class LegalNotices with _$LegalNotices {
  const factory LegalNotices({
    required String copyright,
    required String termsOfUse,
    required String privacyPolicy,
  }) = _LegalNotices;

  factory LegalNotices.fromJson(Map<String, dynamic> json) =>
      _$LegalNoticesFromJson(json);
}

@freezed
class Metadata with _$Metadata {
  const factory Metadata({
    required List<String> defaultSuggestedTags,
    required String title,
    required String role,
  }) = _Metadata;

  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);
}

@freezed
class Reference with _$Reference {
  const factory Reference({
    required Type type,
    required Role? role,
    required String? title,
    required Kind? kind,
    required String identifier,
    required String? url,
    required List<Abstract>? abstract,
    @Default(false) bool deprecated,
    required List<Image>? images,
  }) = _Reference;

  factory Reference.fromJson(Map<String, dynamic> json) =>
      _$ReferenceFromJson(json);
}

@freezed
class Abstract with _$Abstract {
  const factory Abstract({
    required AbstractType type,
    required String text,
  }) = _Abstract;

  factory Abstract.fromJson(Map<String, dynamic> json) =>
      _$AbstractFromJson(json);
}

enum AbstractType { text }

final abstractTypeValues = EnumValues({"text": AbstractType.text});

@freezed
class Image with _$Image {
  const factory Image({
    required String identifier,
    required String type,
  }) = _Image;

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
}

enum Kind { article, symbol }

final kindValues = EnumValues({"article": Kind.article, "symbol": Kind.symbol});

enum Role { article, collection }

final roleValues =
    EnumValues({"article": Role.article, "collection": Role.collection});

enum Type { image, link, topic }

final typeValues =
    EnumValues({"image": Type.image, "link": Type.link, "topic": Type.topic});

@freezed
class SchemaVersion with _$SchemaVersion {
  const factory SchemaVersion({
    required int major,
    required int minor,
    required int patch,
  }) = _SchemaVersion;

  factory SchemaVersion.fromJson(Map<String, dynamic> json) =>
      _$SchemaVersionFromJson(json);
}

@Freezed(unionKey: 'kind')
sealed class Section with _$Section {
  const factory Section.technologies({
    required String kind,
    required List<Group> groups,
  }) = SectionTechnologies;

  const factory Section.hero({
    required String kind,
    required String image,
  }) = SectionHero;

  factory Section.fromJson(Map<String, dynamic> json) =>
      _$SectionFromJson(json);
}

@freezed
class Group with _$Group {
  const factory Group({
    required String name,
    required List<Technology> technologies,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

@freezed
class Technology with _$Technology {
  const factory Technology({
    required String title,
    required List<Abstract> content,
    required List<Language> languages,
    required Destination destination,
    required List<String> tags,
  }) = _Technology;

  factory Technology.fromJson(Map<String, dynamic> json) =>
      _$TechnologyFromJson(json);
}

@freezed
class Destination with _$Destination {
  const factory Destination({
    required String identifier,
    required DestinationType type,
    required bool isActive,
  }) = _Destination;

  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);
}

enum DestinationType { reference }

final destinationTypeValues =
    EnumValues({"reference": DestinationType.reference});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
