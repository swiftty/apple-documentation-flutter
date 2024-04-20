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
  }) = Loaded;
  const factory State.failed() = Failed;
}

@freezed
sealed class Action with _$Action {
  const factory Action.onAppear() = OnAppear;
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
        );
    }
  }
}
