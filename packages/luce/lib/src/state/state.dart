abstract class BuildRoot {
  void markDirty();

  void markDirtyChild();
}

abstract class BuildContext extends BuildRoot {
  void rebuildOn(AddListener addListener);
}

typedef Listener = void Function();
typedef RemoveListener = void Function();
typedef AddListener = RemoveListener Function(Listener listener);

abstract class Source<E> {
  E get current;
  RemoveListener changes(Listener listener);
}

class State<E> with ChangeNotification implements Source<E> {
  @override
  E get current => _current;
  E _current;
  set current(E value) {
    if (!identical(value, _current)) {
      _current = value;
      notify();
    }
  }

  @override
  String toString() => '$runtimeType[$current]';
}

mixin ChangeNotification {
  final List<Listener> _listeners = <Listener>[];

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

class LatestEvent<E> with ChangeNotification {
  LatestEvent();
  LatestEvent.startingWith(E event) : _latest = event;

  E _latest;
  E get latest => _latest;

  void call(E event) {
    if (!identical(_latest, event)) {
      _latest = event;
      notify();
    }
  }
}
