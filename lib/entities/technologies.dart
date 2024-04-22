import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:appledocumentationflutter/entities/value_object/language.dart';
import 'package:appledocumentationflutter/entities/value_object/ref_id.dart';
import 'package:appledocumentationflutter/entities/value_object/reference.dart';

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

  Reference? reference(RefId identifier) => rawReferences[identifier.value];
}

@Freezed(unionKey: 'kind')
sealed class Section with _$Section {
  const factory Section.technologies({
    required String kind,
    required List<SectionGroup> groups,
  }) = SectionTechnologies;

  const factory Section.hero({
    required String kind,
    required RefId image,
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
    required List<Language> languages,
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

/// Represents a technology destination.
@Freezed(unionKey: 'type')
sealed class Destination with _$Destination {
  const factory Destination.reference({
    required RefId identifier,
    required bool isActive,
  }) = DestinationReference;

  factory Destination.fromJson(Map<String, dynamic> json) => _$DestinationFromJson(json);
}
