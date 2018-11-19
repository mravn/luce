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

abstract class Widget {}

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

class NodeAndWidget {
  final html.Node node;
  final Widget widget;

  NodeAndWidget(this.node, this.widget);
}

class App {
  App(this.widget, this.container) {
    if (container != null &&
        container.children.isNotEmpty &&
        container.children[0] != null) {
      _rootElement = container.children[0];
      _oldNode = _recycleElement(_rootElement);
    } else {
      _rootElement = null;
      _oldNode = null;
    }
  }

  Thunk start() {
    _scheduleRender();
    return _scheduleRender;
  }

  final Widget widget;
  final html.Element container;
  final List<Thunk> _lifecycle = [];

  html.Node _rootElement;
  Widget _oldNode;

  bool _isRecycling = true;
  bool _skipRender = false;

  Element _recycleElement(html.Element element) {
    return Element(
      nodeName: element.nodeName.toLowerCase(),
      attributes: FixedMap.empty,
      children: element.childNodes.map((element) {
        return element.nodeType == html.Node.TEXT_NODE
            ? Text(element.nodeValue)
            : _recycleElement(element);
      }).toList(),
    );
  }

  Widget _resolveWidget(Widget widget) {
    if (widget is LazyWidget) {
      return _resolveWidget(widget.build());
    } else {
      return widget;
    }
  }

  void _render() {
    _skipRender = !_skipRender;

    final Widget node = _resolveWidget(widget);

    if (container != null && !_skipRender) {
      _rootElement = _patch(container, _rootElement, _oldNode, node);
      _oldNode = node;
    }

    _isRecycling = false;

    while (_lifecycle.isNotEmpty) {
      _lifecycle.removeLast()();
    }
  }

  void _scheduleRender() {
    if (!_skipRender) {
      _skipRender = true;
    }
    Timer.run(_render);
  }

  void _updateAttribute(
      html.Element element, String name, String value, String oldValue) {
    if (name == "key") {
      // do nothing
    } else {
      element.setAttribute(name, value);
    }
  }

  html.Element _createElement(Element widget) {
    final html.Element element = html.document.createElement(widget.nodeName);
    final FixedMap attributes = widget.attributes;
    if (attributes != null) {
      if (attributes.containsKey("oncreate")) {
        _lifecycle.add(() {
          attributes["oncreate"](element);
        });
      }

      for (var i = 0; i < widget.children.length; i++) {
        final Widget resolved = _resolveWidget(widget.children[i]);
        widget.children[i] = resolved;
        if (resolved is Element) {
          element.append(_createElement(resolved));
        } else if (resolved is Text) {
          element.appendText(resolved.text);
        } else {
          throw 'Unexpected Widget type ${resolved.runtimeType}';
        }
      }
      for (var key in attributes.keys) {
        _updateAttribute(element, key, attributes[key], null);
      }
    }
    return element;
  }

  void _updateElement(
      html.Element element, FixedMap oldAttributes, FixedMap newAttributes) {
    for (final key in (oldAttributes + newAttributes).keys) {
      if (newAttributes[key] !=
          (key == "value" || key == "checked"
              ? element.getAttribute(key)
              : oldAttributes[key])) {
        _updateAttribute(
          element,
          key,
          newAttributes[key],
          oldAttributes[key],
        );
      }
    }

    var cb =
        _isRecycling ? newAttributes["oncreate"] : newAttributes["onupdate"];
    if (cb != null) {
      _lifecycle.add(() {
        cb(element, oldAttributes);
      });
    }
  }

  void _removeChildren(html.Node node, Widget widget) {
    if (widget is Element) {
      var attributes = widget.attributes;
      for (var i = 0; i < widget.children.length; i++) {
        _removeChildren(node.childNodes[i], widget.children[i]);
      }

      if (attributes.containsKey("ondestroy")) {
        attributes["ondestroy"](node);
      }
    }
  }

  void _removeElement(html.Node parent, html.Node node, Widget widget) {
    void done() {
      _removeChildren(node, widget);
      node.remove();
    }

    Function cb = (widget is Element) ? widget.attributes["onremove"] : null;
    if (cb != null) {
      cb(node, done);
    } else {
      done();
    }
  }

  String _getKey(Widget widget) {
    return widget is Element ? widget.key : null;
  }

  html.Node _patch(
    html.Node parent,
    html.Node node,
    Widget oldWidget,
    Widget newWidget,
  ) {
    if (newWidget == oldWidget) {
      // no patching needed
      return node;
    } else if (newWidget is Text) {
      if (node is html.Element) {
        node.insertAdjacentText("beforeBegin", newWidget.text);
        node.remove();
      } else if (node is html.Text) {
        node.replaceData(0, node.length, newWidget.text);
      }
      return null;
    } else if (newWidget is Element) {
      return _patchToNewElementWidget(parent, node, oldWidget, newWidget);
    }
    throw "Unexpected Widget type ${newWidget.runtimeType}";
  }

  html.Node _patchToNewElementWidget(
      html.Node parent, html.Node node, Element oldWidget, Element newWidget) {
    if (oldWidget == null || oldWidget.nodeName != newWidget.nodeName) {
      final html.Element newElement = _createElement(newWidget);
      parent.insertBefore(newElement, node);

      if (oldWidget != null) {
        _removeElement(parent, node, oldWidget);
      }

      node = newElement;
    } else {
      _updateElement(
        node,
        oldWidget.attributes,
        newWidget.attributes,
      );

      final oldKeyed = <String, NodeAndWidget>{};
      final newKeyed = <String, Widget>{};
      final oldChildWidgets = oldWidget.children;
      final oldChildNodes = <html.Node>[]..length = oldWidget.children.length;
      final newChildWidgets = newWidget.children;

      for (var i = 0; i < oldChildWidgets.length; i++) {
        oldChildNodes[i] = node.childNodes[i];

        final String oldKey = _getKey(oldChildWidgets[i]);
        if (oldKey != null) {
          oldKeyed[oldKey] =
              NodeAndWidget(oldChildNodes[i], oldChildWidgets[i]);
        }
      }

      int i = 0;
      int k = 0;

      while (k < newChildWidgets.length) {
        final String oldKey = _getKey(oldChildWidgets[i]);
        final String newKey =
            _getKey((newChildWidgets[k] = _resolveWidget(newChildWidgets[k])));

        if (newKeyed[oldKey] != null) {
          i++;
          continue;
        }

        if (newKey != null && newKey == _getKey(oldChildWidgets[i + 1])) {
          if (oldKey == null) {
            _removeElement(node, oldChildNodes[i], oldChildWidgets[i]);
          }
          i++;
          continue;
        }

        if (newKey == null || _isRecycling) {
          if (oldKey == null) {
            _patch(
                node, oldChildNodes[i], oldChildWidgets[i], newChildWidgets[k]);
            k++;
          }
          i++;
        } else {
          List keyedNode = oldKeyed[newKey] ?? [];

          if (oldKey == newKey) {
            _patch(node, keyedNode[0], keyedNode[1], newChildWidgets[k]);
            i++;
          } else if (keyedNode[0] != null) {
            _patch(
              node,
              node.insertBefore(keyedNode[0], oldChildNodes[i]),
              keyedNode[1],
              newChildWidgets[k],
            );
          } else {
            _patch(node, oldChildNodes[i], null, newChildWidgets[k]);
          }

          newKeyed[newKey] = newChildWidgets[k];
          k++;
        }
      }

      while (i < oldChildWidgets.length) {
        if (_getKey(oldChildWidgets[i]) == null) {
          _removeElement(node, oldChildNodes[i], oldChildWidgets[i]);
        }
        i++;
      }

      for (var i in oldKeyed.keys) {
        if (newKeyed[i] != null) {
          _removeElement(node, oldKeyed[i].node, oldKeyed[i].widget);
        }
      }
    }
    return node;
  }
}
