import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:appledocumentationflutter/entities/value_object/ref_id.dart';

part 'text_content.freezed.dart';
part 'text_content.g.dart';

// MARK: - BlockContent

@Freezed(unionKey: 'type')
sealed class BlockContent with _$BlockContent {
  const factory BlockContent.heading({
    required String text,
    required int level,
    String? anchor,
  }) = BlockContentHeading;

  const factory BlockContent.paragraph(
    List<InlineContent> inlineContent,
  ) = BlockContentParagraph;

  const factory BlockContent.links({
    required List<RefId> items,
    required String style,
  }) = BlockContentLinks;

  const factory BlockContent.unorderedList({
    required List<BlockContentItem> items,
  }) = BlockContentUnorderedList;

  const factory BlockContent.orderedList({
    required List<BlockContentItem> items,
  }) = BlockContentOrderedList;

  const factory BlockContent.termList({
    required List<TermListItem> items,
  }) = BlockContentTermList;

  const factory BlockContent.codeListing({
    required List<String> code,
    required String syntax,
  }) = BlockContentCodeListing;

  const factory BlockContent.aside({
    required List<BlockContent> content,
    required String style,
    required String? name,
  }) = BlockContentAside;

  const factory BlockContent.row({
    required int numberOfColumns,
    required List<BlockContentItem> columns,
  }) = BlockContentRow;

  factory BlockContent.fromJson(Map<String, dynamic> json) => _$BlockContentFromJson(json);
}

@freezed
class BlockContentItem with _$BlockContentItem {
  const factory BlockContentItem({
    required List<BlockContent> content,
  }) = _BlockContentItem;

  factory BlockContentItem.fromJson(Map<String, dynamic> json) => _$BlockContentItemFromJson(json);
}

@freezed
class TermListItem with _$TermListItem {
  const factory TermListItem({
    required TermListItemTerm term,
    required TermListItemDefinition definition,
  }) = _TermListItem;

  factory TermListItem.fromJson(Map<String, dynamic> json) => _$TermListItemFromJson(json);
}

@freezed
class TermListItemTerm with _$TermListItemTerm {
  const factory TermListItemTerm({
    required List<InlineContent> inlineContent,
  }) = _TermListItemTerm;

  factory TermListItemTerm.fromJson(Map<String, dynamic> json) => _$TermListItemTermFromJson(json);
}

@freezed
class TermListItemDefinition with _$TermListItemDefinition {
  const factory TermListItemDefinition({
    required List<InlineContent> content,
  }) = _TermListItemDefinition;

  factory TermListItemDefinition.fromJson(Map<String, dynamic> json) =>
      _$TermListItemDefinitionFromJson(json);
}

// MARK: - InlineContent

@Freezed(unionKey: 'type', fallbackUnion: 'unknown')
sealed class InlineContent with _$InlineContent {
  const factory InlineContent.text({
    required String text,
  }) = InlineContentText;

  const factory InlineContent.emphasis({
    required List<InlineContent> inlineContent,
  }) = InlineContentEmphasis;

  const factory InlineContent.reference({
    required RefId identifier,
    required bool isActive,
  }) = InlineContentLink;

  const factory InlineContent.image({
    required RefId identifier,
    required ImageMetadata? metadata,
  }) = InlineContentImage;

  const factory InlineContent.unknown({
    required String type,
  }) = InlineContentUnknown;

  factory InlineContent.fromJson(Map<String, dynamic> json) => _$InlineContentFromJson(json);
}

@freezed
class ImageMetadata with _$ImageMetadata {
  const factory ImageMetadata({
    @Default([]) List<InlineContent> abstract,
  }) = _ImageMetadata;

  factory ImageMetadata.fromJson(Map<String, dynamic> json) => _$ImageMetadataFromJson(json);
}
