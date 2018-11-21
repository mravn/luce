import 'dart:html' as html;
import 'dart:async';

typedef void Listener();
typedef void RemoveListener();
typedef RemoveListener AddListener(Listener listener);

mixin Notification {
  final List<Listener> _listeners = [];

  void notifyAll() {
    for (Listener listener in _listeners) {
      listener();
    }
  }

  RemoveListener notify(Listener listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }
}

abstract class Widget {
}

abstract class BuildParent {
  void markDirty();
}

abstract class BuildContext extends BuildParent {
  void rebuildOn(AddListener addListener);
}

void wire(Widget widget, html.Element element) {
  Root(widget, element).markDirty();
}

abstract class LazyWidget extends Widget {
  Widget build(BuildContext context);
}

class Text extends Widget {
  final String text;

  Text(this.text);

  @override
  String toString() {
    return "$runtimeType[$text]";
  }
}

class Element extends Widget {
  final String key;
  final String nodeName;
  final FixedMap attributes;
  final List<Widget> children;

  Element({
    this.nodeName,
    this.key = null,
    this.attributes = FixedMap.empty,
    this.children = const <Widget>[],
  });

  @override
  String toString() {
    return "$runtimeType[$nodeName, $key, $attributes, $children]";
  }
}

class Div extends Element {
  Div({
    FixedMap attributes = FixedMap.empty,
    List<Widget> children = const <Widget>[],
    String key,
  }) : super(
          nodeName: 'div',
          attributes: attributes,
          children: children,
          key: key,
        );
}

class Br extends Element {
  Br() : super(nodeName: 'br');
}

class FixedMap {
  static const empty = FixedMap._(<String, dynamic>{});

  const FixedMap._(this._map);

  final Map<String, dynamic> _map;

  Iterable<String> get keys => _map.keys;

  dynamic operator [](String key) => _map[key];

  bool containsKey(String key) => _map.containsKey(key);

  FixedMap operator +(FixedMap other) {
    final Map<String, dynamic> out = <String, dynamic>{};
    out.addAll(_map);
    for (final String key in other.keys) {
      out[key] = other[key];
    }
    return FixedMap._(out);
  }

  @override
  String toString() {
    return "$runtimeType[$_map]";
  }
}

class Root extends BuildParent {
  Root(this.widget, this.container);

  final Widget widget;
  final html.Element container;
  X _oldX;
  bool _renderPending = false;

  void _render() {
    if (container != null) {
      _oldX = (_oldX == null) ? createFor(widget, this) : _oldX.update(widget);
      if (container.hasChildNodes()) {
        final html.Node first = container.firstChild;
        if (first != _oldX.node) {
          first.replaceWith(_oldX.node);
        }
        while (first.nextNode != null) {
          first.nextNode.remove();
        }
      }
      else {
        container.append(_oldX.node);
      }
    }
  }

  @override
  void markDirty() {
    if (!_renderPending) {
      Timer.run(() { _render(); _renderPending = false; });
    }
  }
}

X createFor(Widget widget, BuildParent parent) {
  if (widget is Text) {
    return X0(parent)
      ..widget = widget
      ..node = html.Text(widget.text);
  } else if (widget is Element) {
    final html.Element node = html.document.createElement(widget.nodeName);
    for (final String key in widget.attributes.keys) {
      node.setAttribute(key, widget.attributes[key]);
    }
    final Xn xn = Xn(parent)
      ..widget = widget
      ..node = node;
    xn.children = widget.children.map((cw) => createFor(cw, xn)).toList();
    for (X x in xn.children) {
      node.append(x.node);
    }
    return xn;
  } else if (widget is LazyWidget) {
    final X1 x1 = X1(parent);
    x1.widget = widget;
    x1.child = createFor(widget.build(x1), x1);
    x1.node = x1.child.node;
    return x1;
  } else {
    throw 'Unknown widget type';
  }
}

abstract class X extends BuildParent {
  BuildParent parent;

  X(this.parent);

  html.Node get node;
  bool isDirty = false;

  X update(Widget newWidget);

  void markDirty() {
    if (!isDirty) {
      isDirty = true;
      if (parent != null) {
        parent.markDirty();
      }
    }
  }

  BuildParent invalidate() {
    final BuildParent oldParent = parent;
    parent = null;
    return oldParent;
  }
}

class X0 extends X {
  Text widget;
  html.Text node;

  X0(BuildParent parent): super(parent);

  X update(Widget newWidget) {
    if (!isDirty && newWidget == widget) return this;
    isDirty = false;
    if (newWidget is Text) {
      final String oldText = widget.text;
      final String newText = newWidget.text;
      if (newText != oldText) {
        int prefix = 0;
        while (prefix < newText.length && prefix < oldText.length && newText[prefix] == oldText[prefix]) {
          prefix += 1;
        }
        node.replaceData(prefix, oldText.length - prefix, newWidget.text.substring(prefix));
      }
      widget = newWidget;
      return this;
    } else {
      return createFor(newWidget, invalidate());
    }
  }

  @override
  BuildParent invalidate() {
    widget = null;
    node = null;
    return super.invalidate();
  }
}

class X1 extends X implements BuildContext {
  final List<RemoveListener> _removeListeners = <RemoveListener>[];
  LazyWidget widget;
  html.Node node;
  X child;

  X1(BuildParent parent): super(parent);

  @override
  X update(Widget newWidget) {
    if (!isDirty && newWidget == widget) return this;
    isDirty = false;
    removeListeners();
    if (newWidget is LazyWidget) {
      widget = newWidget;
      child = child.update(newWidget.build(this));
      child.parent = this;
      node = child.node;
      return this;
    } else {
      return createFor(newWidget, invalidate());
    }
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
  BuildParent invalidate() {
    removeListeners();
    widget = null;
    node = null;
    if (child != null) {
      child.invalidate();
      child = null;
    }
    return super.invalidate();
  }
}

class Xn extends X {
  Xn(BuildParent parent): super(parent);

  Element widget;
  html.Element node;
  List<X> children;

  @override
  X update(Widget newWidget) {
    if (!isDirty && newWidget == widget) return this;
    isDirty = false;
    if (newWidget is Element && newWidget.nodeName == widget.nodeName) {
      // TODO assuming new child count equals old child count
      for (int i = 0; i < children.length; i++) {
        final X oldChild = children[i];
        final html.Node oldNode = oldChild.node;
        final X newChild = oldChild.update(newWidget.children[i]);
        final html.Node newNode = newChild.node;
        if (newNode != oldNode) {
          oldNode.replaceWith(newNode);
        }
        children[i] = newChild;
      }
      for (final String key in (widget.attributes + newWidget.attributes).keys) {
        node.setAttribute(key, newWidget.attributes[key]);
      }
      widget = newWidget;
      return this;
    } else {
      return createFor(newWidget, invalidate());
    }
  }

  @override
  BuildParent invalidate() {
    widget = null;
    node = null;
    if (children != null) {
      for (final X child in children) {
        child.invalidate();
      }
      children = null;
    }
    return super.invalidate();
  }
}
