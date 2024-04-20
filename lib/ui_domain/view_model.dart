mixin ViewModel<State, Action, Effect> {
  Future<void> mutate(Action action);
  Future<void> onException(Exception exception) async {}

  Future<void> send(Action action) async {
    try {
      await mutate(action);
    } on Exception catch (e) {
      await onException(e);
    }
  }
}
