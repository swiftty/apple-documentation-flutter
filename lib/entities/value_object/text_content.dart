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
    required List<ListItem> items,
  }) = BlockContentUnorderedList;

  const factory BlockContent.orderedList({
    required List<ListItem> items,
  }) = BlockContentOrderedList;

  const factory BlockContent.termList({
    required List<TermListItem> items,
  }) = BlockContentTermList;

  const factory BlockContent.aside({
    required List<BlockContent> content,
    required String style,
    required String? name,
  }) = BlockContentAside;

  factory BlockContent.fromJson(Map<String, dynamic> json) => _$BlockContentFromJson(json);
}

@freezed
class ListItem with _$ListItem {
  const factory ListItem({
    required List<BlockContent> content,
  }) = _ListItem;

  factory ListItem.fromJson(Map<String, dynamic> json) => _$ListItemFromJson(json);
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
  }) = InlineContentImage;

  const factory InlineContent.unknown({
    required String type,
  }) = InlineContentUnknown;

  factory InlineContent.fromJson(Map<String, dynamic> json) => _$InlineContentFromJson(json);
}
