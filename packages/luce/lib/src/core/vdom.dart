import 'dart:async';
import 'state.dart';
import 'widgets.dart';

abstract class Dom<N, E extends N, T extends N> {
  E createElement(String tag);

  T createText(String text);

  bool hasChildNodes(N node);

  N firstChild(N node);

  void replaceWith(N node, N otherNode);

  N nextNode(N node);

  void remove(N node);

  void append(N parent, N node);

  Map<String, String> attributes(E element);

  void replaceData(T text, int offset, int count, String data);

  void insertAllBefore(N parent, Iterable<N> newNodes, N refChild);
}

void mount<N, E extends N, T extends N, D extends Dom<N, E, T>>(
    Widget widget, Dom<N, E, T> dom, N node) {
  _BuildRoot<N, E, T, D>(widget, dom, node)..markDirty();
}

class _BuildRoot<N, E extends N, T extends N, D extends Dom<N, E, T>>
    extends BuildRoot {
  _BuildRoot(this.widget, this.dom, this.container)
      : assert(widget != null),
        assert(dom != null);

  final Dom<N, E, T> dom;
  final Widget widget;
  final N container;
  _X<N, E, T, D> _oldX;
  bool _renderPending = false;

  void _render() {
    if (container != null) {
      _oldX = (_oldX == null)
          ? createFor<N, E, T, D>(widget, dom, this)
          : _oldX.update(widget);
      if (dom.hasChildNodes(container)) {
        final N first = dom.firstChild(container);
        if (first != _oldX.node) {
          dom.replaceWith(first, _oldX.node);
        }
        while (dom.nextNode(first) != null) {
          dom.remove(dom.nextNode(first));
        }
      } else {
        dom.append(container, _oldX.node);
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

_X<N, E, T, D> createFor<N, E extends N, T extends N, D extends Dom<N, E, T>>(
    Widget widget, Dom<N, E, T> dom, BuildRoot parent) {
  if (widget is Text) {
    return _X0<N, E, T, D>(dom, parent)
      ..widget = widget
      ..node = dom.createText(widget.text);
  } else if (widget is Element) {
    final E node = dom.createElement(widget.nodeName);
    final Map<String, String> nodeAttributes = dom.attributes(node);
    for (final String key in widget.attributes.keys) {
      final dynamic value = widget.attributes[key];
      if (value is String) {
        // TODO handle lifecycle methods and css
        nodeAttributes[key] = value;
      }
    }
    final Xn<N, E, T, D> xn = Xn<N, E, T, D>(dom, parent)
      ..widget = widget
      ..node = node;
    xn.children = widget.children
        .map((cw) => createFor<N, E, T, D>(cw, dom, xn))
        .toList();
    for (_X x in xn.children) {
      dom.append(node, x.node);
    }
    return xn;
  } else if (widget is Component) {
    final _X1<N, E, T, D> x1 = _X1<N, E, T, D>(dom, parent);
    return x1
      ..widget = widget
      ..child = createFor<N, E, T, D>(widget.build(x1), dom, x1)
      ..node = x1.child.node;
  } else {
    throw 'Unknown widget type';
  }
}

abstract class _X<N, E extends N, T extends N, D extends Dom<N, E, T>>
    extends BuildRoot {
  final Dom<N, E, T> dom;
  BuildRoot parent;

  _X(this.dom, this.parent);

  N get node;

  Widget get widget;

  bool isDirty = false;
  bool hasDirtyChild = false;

  _X update(Widget newWidget);

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

class _X0<N, E extends N, T extends N, D extends Dom<N, E, T>>
    extends _X<N, E, T, D> {
  Text widget;
  T node;

  _X0(Dom<N, E, T> dom, BuildRoot parent) : super(dom, parent);

  _X update(Widget newWidget) {
    if (newWidget == widget) return this;
    if (newWidget is Text) {
      final String oldText = widget.text;
      final String newText = newWidget.text;
      if (newText != oldText) {
        dom.replaceData(node, 0, oldText.length, newWidget.text);
      }
      widget = newWidget;
      return this;
    } else {
      return createFor<N, E, T, D>(newWidget, dom, invalidate());
    }
  }

  @override
  BuildRoot invalidate() {
    widget = null;
    node = null;
    return super.invalidate();
  }
}

class _X1<N, E extends N, T extends N, D extends Dom<N, E, T>>
    extends _X<N, E, T, D> implements BuildContext {
  final List<RemoveListener> _removeListeners = <RemoveListener>[];
  Component widget;
  N node;
  _X child;

  _X1(Dom<N, E, T> dom, BuildRoot parent) : super(dom, parent);

  @override
  _X update(Widget newWidget) {
    if (!hasDirtyChild && newWidget == widget) return this;
    hasDirtyChild = false;
    if (newWidget is Component) {
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
      return createFor<N, E, T, D>(newWidget, dom, invalidate());
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
  BuildRoot invalidate() {
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

class Xn<N, E extends N, T extends N, D extends Dom<N, E, T>>
    extends _X<N, E, T, D> {
  Xn(Dom<N, E, T> dom, BuildRoot parent) : super(dom, parent);

  Element widget;
  E node;
  List<_X> children;

  @override
  _X update(Widget newWidget) {
    if (!hasDirtyChild && newWidget == widget) return this;
    hasDirtyChild = false;
    if (newWidget is Element && newWidget.nodeName == widget.nodeName) {
      void updateChild(int oldIndex, int newIndex) {
        final _X oldChild = children[oldIndex];
        final _X newChild = oldChild.update(newWidget.children[newIndex]);
        if (newChild != oldChild) {
          final N newNode = newChild.node;
          final N oldNode = oldChild.node;
          if (newNode != oldNode) {
            dom.replaceWith(oldNode, newNode);
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
          final N nodeAfterNewNodes =
              (i == children.length) ? null : children[i].node;
          children.insertAll(
              i,
              Iterable<_X<N, E, T, D>>.generate(
                newEnd - i,
                (j) =>
                    createFor<N, E, T, D>(newWidget.children[i + j], dom, this),
              ));
          dom.insertAllBefore(
            node,
            children.sublist(i, newEnd).map((x) => x.node),
            nodeAfterNewNodes,
          );
        } else if (i < oldEnd) {
          // delete old nodes
          for (final child in children.sublist(i, oldEnd)) {
            dom.remove(child.node);
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
          final Map<String, String> nodeAttributes = dom.attributes(node);
          for (final String key
              in Set.from(newAttributes.keys.followedBy(oldAttributes.keys))) {
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
      return createFor<N, E, T, D>(newWidget, dom, invalidate());
    }
  }

  @override
  BuildRoot invalidate() {
    widget = null;
    node = null;
    if (children != null) {
      for (final _X child in children) {
        child.invalidate();
      }
      children = null;
    }
    return super.invalidate();
  }
}
