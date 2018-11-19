import 'dart:html' as html;
import 'dart:async';

typedef void Thunk();

abstract class State {
  void update(Thunk thunk);
}

class HtmlState implements State {
  Thunk _render;

  @override
  void update(Thunk thunk) {
    thunk();
    if (_render != null) _render();
  }

  void wireUp(Widget widget, html.Element element) {
    _render = App(widget, element).start();
  }
}

abstract class Widget {
}

abstract class LazyWidget extends Widget {
  Widget build();
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

class App {
  App(this.widget, this.container);

  Thunk start() {
    _scheduleRender();
    return _scheduleRender;
  }

  bool _skipRender = false;
  final Widget widget;
  final html.Element container;
  X _oldX;

  void _render() {
    _skipRender = !_skipRender;

    if (container != null && !_skipRender) {
      _oldX = (_oldX == null) ? createFor(widget) : _oldX.update(widget, true);
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

  void _scheduleRender() {
    if (!_skipRender) {
      _skipRender = true;
    }
    Timer.run(_render);
  }
}

X createFor(Widget widget) {
  if (widget is Text) {
    return X0()
      ..widget = widget
      ..node = html.Text(widget.text);
  } else if (widget is Element) {
    final html.Element node = html.document.createElement(widget.nodeName);
    for (final String key in widget.attributes.keys) {
      node.setAttribute(key, widget.attributes[key]);
    }
    final Xn xn = Xn()
      ..widget = widget
      ..node = node
      ..children = widget.children.map(createFor).toList();
    for (X x in xn.children) {
      node.append(x.node);
    }
    return xn;
  } else if (widget is LazyWidget) {
    final X1 x1 = X1()
        ..widget = widget
        ..child = createFor(widget.build());
    x1.node = x1.child.node;
    return x1;
  } else {
    throw 'Unknown widget type';
  }
}

abstract class X {
  html.Node get node;
  X update(Widget newWidget, bool mustBuild);
}

class X0 extends X {
  Text widget;
  html.Text node;

  X update(Widget newWidget, bool mustBuild) {
    if (newWidget == widget) return this;
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
      return createFor(newWidget);
    }
  }
}

class X1 extends X {
  LazyWidget widget;
  html.Node node;
  X child;

  @override
  X update(Widget newWidget, bool mustBuild) {
    if (!mustBuild && newWidget == widget) return this;
    if (newWidget is LazyWidget) {
      widget = newWidget;
      child = child.update(newWidget.build(), false);
      node = child.node;
      return this;
    } else {
      return createFor(newWidget);
    }
  }
}

class Xn extends X {
  Element widget;
  html.Element node;
  List<X> children;

  X update(Widget newWidget, bool mustBuild) {
    if (newWidget == widget) return this;
    if (newWidget is Element && newWidget.nodeName == widget.nodeName) {
      // TODO assuming new child count equals old child count
      for (int i = 0; i < children.length; i++) {
        final X oldChild = children[i];
        final html.Node oldNode = oldChild.node;
        final X newChild = oldChild.update(newWidget.children[i], false);
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
      return createFor(newWidget);
    }
  }
}

