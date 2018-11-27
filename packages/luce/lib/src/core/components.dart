import 'state.dart';
import 'vdom.dart';

abstract class Component extends Widget {
  const Component();

  Widget build(BuildContext context);

  @override
  VNode createVNode(BuildRoot parent) => VComponent(this, parent);
}

class VComponent extends VSingleChildNode<Component> implements BuildContext {
  VComponent(Component widget, BuildRoot parent) : super(widget, parent) {
    child = widget.build(this).createVNode(parent);
    node = child.node;
  }

  final List<RemoveListener> _removeListeners = <RemoveListener>[];

  @override
  VNode updateAndReturnChild(Component newWidget) {
    removeListeners();
    return child.update(newWidget.build(this));
  }

  @override
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
