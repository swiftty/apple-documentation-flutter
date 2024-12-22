import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:appledocumentationflutter/entities/value_object/language.dart';
import 'package:appledocumentationflutter/entities/value_object/ref_id.dart';
import 'package:appledocumentationflutter/entities/value_object/reference.dart';
import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';
import 'package:appledocumentationflutter/entities/value_object/text_content.dart';

part 'technology_detail.freezed.dart';
part 'technology_detail.g.dart';

@freezed
class TechnologyDetail with _$TechnologyDetail {
  const TechnologyDetail._();

  const factory TechnologyDetail({
    required TechnologyDetailIdentifier identifier,
    required Metadata metadata,
    required List<Variant>? variants,
    @Default([]) List<InlineContent> abstract,
    required Hierarchy? hierarchy,
    @Default([]) List<PrimaryContentSection> primaryContentSections,
    @Default([]) List<TopicSection> topicSections,
    @Default([]) List<RelationshipsSection> relationshipsSections,
    @Default([]) List<SeeAlsoSection> seeAlsoSections,
    // ignore: invalid_annotation_target
    @protected @JsonKey(name: 'references') required Map<String, Reference> rawReferences,
  }) = _TechnologyDetail;

  factory TechnologyDetail.fromJson(Map<String, dynamic> json) => _$TechnologyDetailFromJson(json);

  Reference? reference(RefId identifier) => rawReferences[identifier.value];
}

// MARK: - Identifier
@freezed
class TechnologyDetailIdentifier with _$TechnologyDetailIdentifier {
  const factory TechnologyDetailIdentifier({
    required Language interfaceLanguage,
    required RefId url,
  }) = _TechnologyDetailIdentifier;

  factory TechnologyDetailIdentifier.fromJson(Map<String, dynamic> json) =>
      _$TechnologyDetailIdentifierFromJson(json);
}

// MARK: - Metadata
@freezed
class Metadata with _$Metadata {
  const factory Metadata({
    required String title,
    required String? roleHeading,
    required List<MetadataPlatform>? platforms,
  }) = _Metadata;

  factory Metadata.fromJson(Map<String, dynamic> json) => _$MetadataFromJson(json);
}

@freezed
class MetadataPlatform with _$MetadataPlatform {
  const factory MetadataPlatform({
    @Default(false) bool beta,
    required String name,
    required String introducedAt,
  }) = _MetadataPlatform;

  factory MetadataPlatform.fromJson(Map<String, dynamic> json) => _$MetadataPlatformFromJson(json);
}

// MARK: - Variant
@freezed
class Variant with _$Variant {
  const factory Variant({
    required List<TechnologyId> paths,
    required List<VariantTrait> traits,
  }) = _Variant;

  factory Variant.fromJson(Map<String, dynamic> json) => _$VariantFromJson(json);
}

@freezed
class VariantTrait with _$VariantTrait {
  const factory VariantTrait({
    required Language interfaceLanguage,
  }) = _VariantTrait;

  factory VariantTrait.fromJson(Map<String, dynamic> json) => _$VariantTraitFromJson(json);
}

// MARK: - Hierarchy
@freezed
class Hierarchy with _$Hierarchy {
  const factory Hierarchy({
    required List<List<TechnologyId>> paths,
  }) = _Hierarchy;

  factory Hierarchy.fromJson(Map<String, dynamic> json) => _$HierarchyFromJson(json);
}

// MARK: - PrimaryContentSection
@Freezed(unionKey: 'kind', fallbackUnion: 'unknown')
sealed class PrimaryContentSection with _$PrimaryContentSection {
  const factory PrimaryContentSection.content({
    required List<BlockContent> content,
  }) = _PrimaryContentSectionContent;

  const factory PrimaryContentSection.declarations({
    required List<PrimaryContentDeclaration> declarations,
  }) = _PrimaryContentSectionDeclarations;

  const factory PrimaryContentSection.parameters({
    @Default([]) List<Language> languages,
    required List<PrimaryContentParameter> parameters,
  }) = _PrimaryContentSectionParameters;

  const factory PrimaryContentSection.details({
    required String title,
    required PrimaryContentDetails details,
  }) = _PrimaryContentSectionDetails;

  const factory PrimaryContentSection.unknown({
    required String kind,
  }) = _PrimaryContentSectionUnknown;

  factory PrimaryContentSection.fromJson(Map<String, dynamic> json) =>
      _$PrimaryContentSectionFromJson(json);
}

@freezed
class PrimaryContentDeclaration with _$PrimaryContentDeclaration {
  const factory PrimaryContentDeclaration({
    required List<Language> languages,
    required List<Fragment> tokens,
  }) = _PrimaryContentDeclaration;

  factory PrimaryContentDeclaration.fromJson(Map<String, dynamic> json) =>
      _$PrimaryContentDeclarationFromJson(json);
}

@freezed
class PrimaryContentParameter with _$PrimaryContentParameter {
  const factory PrimaryContentParameter({
    required String name,
    required List<BlockContent> content,
  }) = _PrimaryContentParameter;

  factory PrimaryContentParameter.fromJson(Map<String, dynamic> json) =>
      _$PrimaryContentParameterFromJson(json);
}

@freezed
class PrimaryContentDetails with _$PrimaryContentDetails {
  const factory PrimaryContentDetails({
    required String name,
    required String titleStyle,
    required String? ideTitle,
    required String rawName,
    required List<String> platforms,
    required List<Map<String, dynamic>> value,
  }) = _PrimaryContentDetails;

  factory PrimaryContentDetails.fromJson(Map<String, dynamic> json) =>
      _$PrimaryContentDetailsFromJson(json);
}

// MARK: - TopicSection
@freezed
class TopicSection with _$TopicSection {
  const factory TopicSection({
    required String title,
    required List<RefId> identifiers,
  }) = _TopicSection;

  factory TopicSection.fromJson(Map<String, dynamic> json) => _$TopicSectionFromJson(json);
}

// MARK: - RelationshipsSection
@Freezed(unionKey: 'kind')
sealed class RelationshipsSection with _$RelationshipsSection {
  const factory RelationshipsSection.taskGroup({
    required String title,
    required List<RefId> identifiers,
  }) = RelationshipsSectionTaskGroup;

  const factory RelationshipsSection.relationships({
    required String title,
    required List<RefId> identifiers,
    required String type,
  }) = RelationshipsSectionRelationship;

  factory RelationshipsSection.fromJson(Map<String, dynamic> json) =>
      _$RelationshipsSectionFromJson(json);
}

// MARK: - SeeAlsoSection
@freezed
class SeeAlsoSection with _$SeeAlsoSection {
  const factory SeeAlsoSection({
    required List<RefId> identifiers,
    required String title,
  }) = _SeeAlsoSection;

  factory SeeAlsoSection.fromJson(Map<String, dynamic> json) => _$SeeAlsoSectionFromJson(json);
}
