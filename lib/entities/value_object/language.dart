import 'package:freezed_annotation/freezed_annotation.dart';

part 'language.freezed.dart';

@Freezed(fromJson: false, toJson: false, copyWith: false)
sealed class Language with _$Language {
  const Language._();

  const factory Language.swift() = LanguageSwift;
  const factory Language.objectiveC() = LanguageObjectiveC;
  const factory Language.other() = LanguageOther;

  factory Language.fromJson(String json) =>
      const {
        'swift': Language.swift(),
        'occ': Language.objectiveC(),
        'other': Language.other(),
      }[json] ??
      const Language.other();

  String toJson() {
    switch (this) {
      case LanguageSwift():
        return 'swift';
      case LanguageObjectiveC():
        return 'occ';
      case LanguageOther():
        return 'other';
    }
  }
}
