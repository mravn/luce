abstract class BuildRoot {
  void markDirty();

  void markDirtyChild();
}

abstract class BuildContext extends BuildRoot {
  void rebuildOn(AddListener addListener);
}

typedef void Listener();
typedef void RemoveListener();
typedef RemoveListener AddListener(Listener listener);

mixin ChangeNotification {
  final List<Listener> _listeners = [];

  void notify() {
    for (Listener listener in _listeners) {
      listener();
    }
  }

  RemoveListener changes(Listener listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }
}
