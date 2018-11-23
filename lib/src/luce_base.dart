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

abstract class Widget {}

abstract class BuildParent {
  void markDirty();

  void markDirtyChild();
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
    Map<String, dynamic> attributes = const <String, dynamic>{},
    List<Widget> children = const <Widget>[],
    String key,
  }) : super(
          nodeName: 'div',
          attributes: FixedMap(attributes),
          children: children,
          key: key,
        );
}

class Br extends Element {
  Br() : super(nodeName: 'br');
}

class FixedMap {
  static const empty = FixedMap._(<String, dynamic>{});

  factory FixedMap(Map<String, dynamic> map) {
    return FixedMap._(Map.from(map));
  }

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

class FixedMapBuilder {
  Map<String, dynamic> _map = {};

  void put(String key, dynamic value) {
    _map[key] = value;
  }

  FixedMap build() {
    final FixedMap result = FixedMap._(_map);
    _map = null;
    return result;
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
      } else {
        container.append(_oldX.node);
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
    if (!_renderPending) {
      Timer.run(() {
        _render();
        _renderPending = false;
      });
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
    final Map<String, String> nodeAttributes = node.attributes;
    for (final String key in widget.attributes.keys) {
      final dynamic value = widget.attributes[key];
      if (value is String) { // TODO handle lifecycle methods and css
        nodeAttributes[key] = value;
      }
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
    return x1
      ..widget = widget
      ..child = createFor(widget.build(x1), x1)
      ..node = x1.child.node;
  } else {
    throw 'Unknown widget type';
  }
}

abstract class X extends BuildParent {
  BuildParent parent;

  X(this.parent);

  html.Node get node;

  Widget get widget;

  bool isDirty = false;
  bool hasDirtyChild = false;

  X update(Widget newWidget);

  void markDirty() {
    if (!isDirty) {
      isDirty = true;
      hasDirtyChild = true;
      if (parent != null) {
        parent.markDirtyChild();
      }
    }
  }

  void markDirtyChild() {
    if (!hasDirtyChild) {
      hasDirtyChild = true;
      if (parent != null) {
        parent.markDirtyChild();
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

  X0(BuildParent parent) : super(parent);

  X update(Widget newWidget) {
    if (newWidget == widget) return this;
    if (newWidget is Text) {
      final String oldText = widget.text;
      final String newText = newWidget.text;
      if (newText != oldText) {
        node.replaceData(0, oldText.length, newWidget.text);
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

  X1(BuildParent parent) : super(parent);

  @override
  X update(Widget newWidget) {
    if (!hasDirtyChild && newWidget == widget) return this;
    hasDirtyChild = false;
    if (newWidget is LazyWidget) {
      if (!isDirty && newWidget == widget) {
        child.update(child.widget);
      } else {
        isDirty = false;
        widget = newWidget;
        removeListeners();
        child = child.update(newWidget.build(this));
        child.parent = this;
        node = child.node;
      }
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
  Xn(BuildParent parent) : super(parent);

  Element widget;
  html.Element node;
  List<X> children;

  @override
  X update(Widget newWidget) {
    if (!hasDirtyChild && newWidget == widget) return this;
    hasDirtyChild = false;
    if (newWidget is Element && newWidget.nodeName == widget.nodeName) {
      void updateChild(int oldIndex, int newIndex) {
        final X oldChild = children[oldIndex];
        final X newChild = oldChild.update(newWidget.children[newIndex]);
        if (newChild != oldChild) {
          final html.Node newNode = newChild.node;
          final html.Node oldNode = oldChild.node;
          if (newNode != oldNode) {
            oldNode.replaceWith(newNode);
          }
          children[oldIndex] = newChild;
        }
      }

      void replaceRange(int start, int oldEnd, int newEnd) {
        int i = start;
        while (i < oldEnd && i < newEnd) {
          // reuse as many slots as possible
          updateChild(i, i);
          i += 1;
        }
        if (i < newEnd) {
          // insert new nodes
          final html.Node nodeAfterNewNodes =
              (i == children.length) ? null : children[i].node;
          children.insertAll(
              i,
              Iterable.generate(
                newEnd - i,
                (j) => createFor(newWidget.children[i + j], this),
              ));
          node.insertAllBefore(
            children.sublist(i, newEnd).map((x) => x.node),
            nodeAfterNewNodes,
          );
        } else if (i < oldEnd) {
          // delete old nodes
          for (X child in children.sublist(i, oldEnd)) {
            child.node.remove();
            child.invalidate();
          }
          children.removeRange(i, oldEnd);
        }
      }

      if (newWidget == widget) {
        for (int i = 0, n = children.length; i < n; i++) {
          if (children[i].hasDirtyChild) updateChild(i, i);
        }
      } else {
        final int m = newWidget.children.length;
        final int n = children.length;
        // preserve prefix with unchanged widgets
        int i = 0;
        while (i < m && i < n && newWidget.children[i] == children[i].widget) {
          if (children[i].hasDirtyChild) updateChild(i, i);
          i += 1;
        }
        // preserve suffix with unchanged widgets
        int k = 0;
        while (i < m - 1 - k &&
            i < n - 1 - k &&
            newWidget.children[m - 1 - k] == children[n - 1 - k].widget) {
          k += 1;
          if (children[n - k].hasDirtyChild) updateChild(n - k, m - k);
        }
        // replace old children i..n-k with new children i..m-k
        replaceRange(i, n - k, m - k);
        // update attributes and widget
        final FixedMap oldAttributes = widget.attributes;
        final FixedMap newAttributes = newWidget.attributes;
        if (newAttributes != oldAttributes) {
          final Map<String, String> nodeAttributes = node.attributes;
          for (final String key in Set.from(newAttributes.keys.followedBy(oldAttributes.keys))) {
            final dynamic newValue = newAttributes[key];
            if (oldAttributes[key] != newValue) {
              if (newValue is! String) {
                nodeAttributes.remove(key);
              } else {
                nodeAttributes[key] = newValue;
              }
            }
          }
        }
        widget = newWidget;
      }
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
