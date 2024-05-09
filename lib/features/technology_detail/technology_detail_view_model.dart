import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:appledocumentationflutter/data/api_client.dart';
import 'package:appledocumentationflutter/domain/domain_errors.dart';
import 'package:appledocumentationflutter/entities/technology_detail.dart';
import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';
import 'package:appledocumentationflutter/ui_domain/view_model.dart';

part 'technology_detail_view_model.freezed.dart';
part 'technology_detail_view_model.g.dart';

@freezed
sealed class State with _$State {
  const factory State.pending() = Pending;
  const factory State.loading() = Loading;
  const factory State.loaded({
    required TechnologyDetail technologyDetail,
  }) = Loaded;
  const factory State.failed({
    required DomainException exception,
  }) = Failed;
}

@freezed
sealed class Action with _$Action {
  const factory Action.onAppear() = OnAppear;
}

@riverpod
class TechnologyDetailViewModel extends _$TechnologyDetailViewModel
    with ViewModel<State, Action, Never> {
  @override
  State build({required TechnologyId id}) => const State.pending();

  @override
  Future<void> mutate(action) async {
    switch (action) {
      case OnAppear():
        state = const State.loading();

        try {
          final technologyDetail = await ref.read(apiClientProvider).fetchTechnology(id: id);
          state = State.loaded(
            technologyDetail: technologyDetail,
          );
        } on DomainException catch (e) {
          state = State.failed(exception: e);
        }
    }
  }
}
