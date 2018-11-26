import 'vdom.dart';
import 'state.dart';

abstract class Component extends Widget {
  const Component();

  Widget build(BuildContext context);

  @override
  VNode createVNode(BuildRoot parent) => VComponent(this, parent);
}

class VComponent extends VSingleChildNode<Component> implements BuildContext {
  final List<RemoveListener> _removeListeners = <RemoveListener>[];

  VComponent(Component widget, BuildRoot parent) : super(widget, parent) {
    child = widget.build(this).createVNode(parent);
    node = child.node;
  }

  @override
  VNode updateAndReturnChild(Component newWidget) {
    removeListeners();
    return child.update(newWidget.build(this));
  }

  void rebuildOn(AddListener addListener) {
    _removeListeners.add(addListener(markDirty));
  }

  void removeListeners() {
    for (RemoveListener removeListener in _removeListeners) {
      removeListener();
    }
    _removeListeners.clear();
  }

  @override
  BuildRoot invalidate() {
    removeListeners();
    return super.invalidate();
  }
}
