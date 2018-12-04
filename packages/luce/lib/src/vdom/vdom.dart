import 'dart:async';
import 'dart:html';
import 'package:luce/state.dart';

void mount(Widget widget, Element container) {
  _BuildRoot(widget, container).markDirty();
}

abstract class Widget {
  const Widget();

  VNode createVNode(BuildRoot parent);
}

class _BuildRoot extends BuildRoot {
  _BuildRoot(this.widget, this.container) : assert(widget != null);

  final Widget widget;
  final Element container;
  VNode _oldRootVNode;
  bool _renderPending = false;

  void _render() {
    if (container != null) {
      _oldRootVNode = (_oldRootVNode == null)
          ? widget.createVNode(this)
          : _oldRootVNode.update(widget);
      if (container.hasChildNodes()) {
        final Node first = container.firstChild;
        if (first != _oldRootVNode.node) {
          first.replaceWith(_oldRootVNode.node);
        }
        while (first.nextNode != null) {
          first.nextNode.remove();
        }
      } else {
        container.append(_oldRootVNode.node);
      }
    }
  }

  @override
  void markDirty() {
    if (!_renderPending) {
      Timer.run(() {
        _render();
        _renderPending = false;
      });
    }
  }

  @override
  void markDirtyChild() {
    markDirty();
  }
}

abstract class VNode extends BuildRoot {
  VNode(this.parent);

  BuildRoot parent;

  Element get element;
  Node get node => element;
  Widget get widget;

  bool isDirty = false;
  bool hasDirtyChild = false;

  VNode update(Widget newWidget);

  @override
  void markDirty() {
    if (!isDirty) {
      isDirty = true;
      hasDirtyChild = true;
      if (parent != null) {
        parent.markDirtyChild();
      }
    }
  }

  @override
  void markDirtyChild() {
    if (!hasDirtyChild) {
      hasDirtyChild = true;
      if (parent != null) {
        parent.markDirtyChild();
      }
    }
  }

  BuildRoot invalidate() {
    final BuildRoot oldParent = parent;
    parent = null;
    return oldParent;
  }
}

abstract class VSingleChildElement<W extends Widget> extends VNode {
  VSingleChildElement(this.widget, BuildRoot parent) : super(parent);

  @override
  W widget;
  @override
  Element element;
  VNode child;

  @override
  VNode update(Widget newWidget) {
    if (!hasDirtyChild && newWidget == widget) {
      return this;
    }
    hasDirtyChild = false;
    if (newWidget is W) {
      if (!isDirty && newWidget == widget) {
        child.update(child.widget);
      } else {
        isDirty = false;
        child = updateAndReturnNewChild(newWidget)..parent = this;
        widget = newWidget;
        element = child.element;
      }
      return this;
    } else {
      return newWidget.createVNode(invalidate());
    }
  }

  VNode updateAndReturnNewChild(W newWidget);

  @override
  BuildRoot invalidate() {
    widget = null;
    element = null;
    if (child != null) {
      child.invalidate();
      child = null;
    }
    return super.invalidate();
  }
}
