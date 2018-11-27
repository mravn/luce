import 'vdom.dart';

abstract class BuildContext extends BuildRoot {
  void rebuildOn(AddListener addListener);
}

typedef Listener = void Function();
typedef RemoveListener = void Function();
typedef AddListener = RemoveListener Function(Listener listener);

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
