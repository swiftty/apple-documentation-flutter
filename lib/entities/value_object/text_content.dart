import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:appledocumentationflutter/entities/value_object/ref_id.dart';

part 'text_content.freezed.dart';
part 'text_content.g.dart';

@freezed
class BlockContent with _$BlockContent {
  const factory BlockContent({
    required List<InlineContent> content,
  }) = _BlockContent;

  factory BlockContent.fromJson(Map<String, dynamic> json) => _$BlockContentFromJson(json);
}

@Freezed(unionKey: 'type', fallbackUnion: 'unknown')
sealed class InlineContent with _$InlineContent {
  const factory InlineContent.text({
    required String text,
  }) = InlineContentText;

  const factory InlineContent.reference({
    required RefId identifier,
    required bool isActive,
  }) = InlineContentLink;

  const factory InlineContent.unknown({
    required String type,
  }) = InlineContentUnknown;

  factory InlineContent.fromJson(Map<String, dynamic> json) => _$InlineContentFromJson(json);
}
