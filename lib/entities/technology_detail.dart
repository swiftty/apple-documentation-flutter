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
    required List<Variant> variants,
    required List<PrimaryContentSection> primaryContentSections,
    required List<InlineContent> abstract,
    required List<SeeAlsoSection> seeAlsoSections,
    required List<Hierarchy> hierarchy,
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
    required RefId identifier,
    required String title,
  }) = _TechnologyDetailIdentifier;

  factory TechnologyDetailIdentifier.fromJson(Map<String, dynamic> json) =>
      _$TechnologyDetailIdentifierFromJson(json);
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
    required List<TechnologyId> paths,
  }) = _Hierarchy;

  factory Hierarchy.fromJson(Map<String, dynamic> json) => _$HierarchyFromJson(json);
}

// MARK: - PrimaryContentSection
@freezed
class PrimaryContentSection with _$PrimaryContentSection {
  const factory PrimaryContentSection({
    required String title,
    required List<PrimaryContent> content,
  }) = _PrimaryContentSection;

  factory PrimaryContentSection.fromJson(Map<String, dynamic> json) =>
      _$PrimaryContentSectionFromJson(json);
}

@Freezed(unionKey: 'type')
sealed class PrimaryContent with _$PrimaryContent {
  const factory PrimaryContent.heading({
    required String text,
    required int level,
    required String anchor,
  }) = PrimaryContentHeading;

  const factory PrimaryContent.paragraph({
    required List<InlineContent> inlineContent,
  }) = PrimaryContentParagraph;

  const factory PrimaryContent.unorderedList({
    required List<ListContent> items,
  }) = PrimaryContentUnorderedList;

  factory PrimaryContent.fromJson(Map<String, dynamic> json) => _$PrimaryContentFromJson(json);
}

@freezed
class ListContent with _$ListContent {
  const factory ListContent({
    required List<BlockContent> content,
  }) = _ListContent;

  factory ListContent.fromJson(Map<String, dynamic> json) => _$ListContentFromJson(json);
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
