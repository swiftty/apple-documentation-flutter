import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:appledocumentationflutter/entities/value_object/ref_id.dart';
import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';
import 'package:appledocumentationflutter/entities/value_object/text_content.dart';

part 'reference.freezed.dart';
part 'reference.g.dart';

@Freezed(unionKey: 'type', fallbackUnion: 'unknown')
sealed class Reference with _$Reference {
  const factory Reference.topic({
    required Kind kind,
    required Role? role,
    required String title,
    required TechnologyId url,
    @Default([]) List<InlineContent> abstract,
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
    required RefId identifier,
    required String type,
  }) = ReferenceUnknown;

  factory Reference.fromJson(Map<String, dynamic> json) => _$ReferenceFromJson(json);
}

enum Kind {
  article,
  symbol,
  technologies,
  overview,
}

enum Role {
  article,
  collection,
  sampleCode,
  collectionGroup,
  overview,
  symbol,
}

@freezed
class ImageVariant with _$ImageVariant {
  const factory ImageVariant({
    required String url,
    required List<String> traits,
  }) = _ImageVariant;

  factory ImageVariant.fromJson(Map<String, dynamic> json) => _$ImageVariantFromJson(json);
}
