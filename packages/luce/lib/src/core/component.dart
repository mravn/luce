import 'dart:html';
import 'state.dart';
import 'vdom.dart';

abstract class Component extends Widget {
  const Component();

  Widget build(BuildContext context);

  @override
  VComponent createVNode(BuildRoot parent) => VComponent(this, parent);
}

class VComponent extends VNode implements BuildContext {
  VComponent(this.widget, BuildRoot parent) : super(parent) {
    child = widget.build(this).createVNode(this);
    _childNode = child.node;
  }

  @override
  Component widget;
  @override
  Element get element => _childElement ??= child.element;
  @override
  Node get node => _childElement ?? _childNode;

  Element _childElement;
  Node _childNode;
  VNode child;
  final List<RemoveListener> _removeListeners = <RemoveListener>[];

  @override
  VNode update(Widget newWidget) {
    if (!hasDirtyChild && newWidget == widget) {
      return this;
    }
    hasDirtyChild = false;
    if (newWidget is Component) {
      if (!isDirty && newWidget == widget) {
        child.update(child.widget);
        _refreshChildNode();
      } else {
        isDirty = false;
        widget = newWidget;
        removeListeners();
        child = child.update(newWidget.build(this))..parent = this;
        _refreshChildNode();
      }
      return this;
    } else {
      return newWidget.createVNode(invalidate());
    }
  }

  void _refreshChildNode() {
    if (_childNode != child.node) {
      _childNode = child.node;
      _childElement = null;
    }
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
    widget = null;
    _childNode = null;
    _childElement = null;
    if (child != null) {
      child.invalidate();
      child = null;
    }
    return super.invalidate();
  }
}
