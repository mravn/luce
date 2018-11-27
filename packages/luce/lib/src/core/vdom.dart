import 'dart:async';
import 'dart:html' as html;

void mount(Widget widget, html.Element container) {
  _BuildRoot(widget, container).markDirty();
}

abstract class Widget {
  const Widget();

  VNode createVNode(BuildRoot parent);
}

abstract class BuildRoot {
  void markDirty();

  void markDirtyChild();
}

class _BuildRoot extends BuildRoot {
  _BuildRoot(this.widget, this.container) : assert(widget != null);

  final Widget widget;
  final html.Element container;
  VNode _oldRootVNode;
  bool _renderPending = false;

  void _render() {
    if (container != null) {
      _oldRootVNode = (_oldRootVNode == null)
          ? widget.createVNode(this)
          : _oldRootVNode.update(widget);
      if (container.hasChildNodes()) {
        final html.Node first = container.firstChild;
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

  html.Node get node;

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

abstract class VSingleChildNode<W extends Widget> extends VNode {
  VSingleChildNode(this.widget, BuildRoot parent) : super(parent);

  @override
  W widget;
  @override
  html.Element node;
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
        widget = newWidget;
        child = updateAndReturnChild(newWidget)..parent = this;
        node = child.node;
      }
      return this;
    } else {
      return newWidget.createVNode(invalidate());
    }
  }

  VNode updateAndReturnChild(W newWidget);

  @override
  BuildRoot invalidate() {
    widget = null;
    node = null;
    if (child != null) {
      child.invalidate();
      child = null;
    }
    return super.invalidate();
  }
}
