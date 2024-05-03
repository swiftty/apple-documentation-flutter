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
    @Default([]) List<TopicImage> images,
    @Default([]) List<InlineContent> abstract,
    @Default([]) List<Fragment> fragments,
    @Default(null) Conformance? conformance,
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
  link,
  symbol,
  dictionarySymbol,
  restRequestSymbol,
}

@Freezed(unionKey: 'type')
sealed class TopicImage with _$TopicImage {
  const factory TopicImage.card({
    required RefId identifier,
  }) = _TopicImage;

  factory TopicImage.fromJson(Map<String, dynamic> json) => _$TopicImageFromJson(json);
}

@freezed
class ImageVariant with _$ImageVariant {
  const factory ImageVariant({
    required String url,
    required List<String> traits,
  }) = _ImageVariant;

  factory ImageVariant.fromJson(Map<String, dynamic> json) => _$ImageVariantFromJson(json);
}

@Freezed(unionKey: 'kind')
class Fragment with _$Fragment {
  const factory Fragment.attribute({
    required String text,
  }) = _Attribute;

  const factory Fragment.keyword({
    required String text,
  }) = _Fragment;

  const factory Fragment.text({
    required String text,
  }) = _Text;

  const factory Fragment.label({
    required String text,
  }) = _Label;

  const factory Fragment.identifier({
    required String text,
  }) = _Identifier;

  const factory Fragment.typeIdentifier({
    required String text,
    required String? preciseIdentifier,
    required RefId? identifier,
  }) = _TypeIdentifier;

  const factory Fragment.genericParameter({
    required String text,
  }) = _GenericParameter;

  const factory Fragment.internalParam({
    required String text,
  }) = _InternalParam;

  const factory Fragment.externalParam({
    required String text,
  }) = _ExternalParam;

  factory Fragment.fromJson(Map<String, dynamic> json) => _$FragmentFromJson(json);
}

@freezed
class Conformance with _$Conformance {
  const factory Conformance({
    required List<InlineContent> availabilityPrefix,
    required List<InlineContent> conformancePrefix,
    required List<InlineContent> constraints,
  }) = _Conformance;

  factory Conformance.fromJson(Map<String, dynamic> json) => _$ConformanceFromJson(json);
}
