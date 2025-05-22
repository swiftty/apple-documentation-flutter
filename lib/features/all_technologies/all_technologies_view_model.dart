import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:appledocumentationflutter/data/api_client.dart';
import 'package:appledocumentationflutter/entities/technologies.dart';
import 'package:appledocumentationflutter/ui_domain/view_model.dart';

part 'all_technologies_view_model.freezed.dart';
part 'all_technologies_view_model.g.dart';

@freezed
sealed class State with _$State {
  const factory State.pending() = Pending;
  const factory State.loading() = Loading;
  const factory State.loaded({
    required Technologies technologies,
    required String query,
  }) = Loaded;
  const factory State.failed() = Failed;
}

extension StateLoadedEx on Loaded {
  SectionHero? get heroSection {
    final section = technologies.sections.firstWhere((s) => s is SectionHero);
    return section as SectionHero?;
  }

  Iterable<Technology> get filteredTechnologies {
    final query = this.query.toLowerCase();
    final hasQuery = query.isNotEmpty;

    return [
      for (final section in technologies.sections)
        if (section is SectionTechnologies)
          for (final group in section.groups)
            for (final tech in group.technologies)
              if (!hasQuery || tech.title.toLowerCase().contains(query)) tech,
    ];
  }
}

@freezed
sealed class Action with _$Action {
  const factory Action.onAppear() = OnAppear;
  const factory Action.filterQuery(String query) = FilterQuery;
}

/// ViewModel
@riverpod
class AllTechnologiesViewModel extends _$AllTechnologiesViewModel
    with ViewModel<State, Action, Never> {
  @override
  State build() => const State.pending();

  @override
  Future<void> mutate(Action action) async {
    switch (action) {
      case OnAppear():
        state = const State.loading();

        final technologies = await ref.read(apiClientProvider).fetchAllTechnologies();

        state = State.loaded(
          technologies: technologies,
          query: '',
        );

      case FilterQuery(:final query):
        state = switch (state) {
          Loaded loaded => loaded.copyWith(query: query),
          _ => state,
        };
    }
  }
}
