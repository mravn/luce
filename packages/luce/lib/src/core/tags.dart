import 'dart:html';
import 'package:meta/meta.dart';

import 'vdom.dart';

class Tag extends Widget {
  const Tag({
    @required this.tag,
    this.children = const <Widget>[],
  })  : assert(tag != null),
        assert(children != null);

  final String tag;
  final List<Widget> children;

  void applyClasses(Set<String> classes) {}

  void applyData(Map<String, String> data) {}

  void applyAttributes(Map<String, String> attributes) {}

  @override
  VTag createVNode(BuildRoot parent) => VTag(this, parent);

  @override
  String toString() => '$runtimeType[$tag, $children]';
}

class VTag extends VNode {
  VTag(this.widget, BuildRoot parent) : super(parent) {
    element = document.createElement(widget.tag);
    widget
      ..applyAttributes(element.attributes)
      ..applyClasses(element.classes)
      ..applyData(element.dataset);
    children = widget.children.map((Widget w) => w.createVNode(this)).toList();
    if (children.isNotEmpty) {
      element.insertAllBefore(
          children.map((VNode child) => child.node), null);
    }
  }

  @override
  Tag widget;
  @override
  Element element;
  List<VNode> children;

  @override
  VNode update(Widget newWidget) {
    if (!hasDirtyChild && newWidget == widget) {
      return this;
    }
    hasDirtyChild = false;
    if (newWidget is Tag && newWidget.tag == widget.tag) {
      void updateChild(int oldIndex, int newIndex) {
        final VNode oldChild = children[oldIndex];
        final VNode newChild = oldChild.update(newWidget.children[newIndex]);
        if (newChild != oldChild) {
          final Node newNode = newChild.node;
          final Node oldNode = oldChild.node;
          if (newNode != oldNode) {
            oldNode.replaceWith(newNode);
          }
          children[oldIndex] = newChild;
        }
      }

      void replaceRange(int start, int oldEnd, int newEnd) {
        int i = start;
        while (i < oldEnd && i < newEnd) {
          // Reuse as many slots as possible.
          updateChild(i, i);
          i += 1;
        }
        if (i < newEnd) {
          final Node refChild =
              (i == children.length) ? null : children[i].node;
          // Insert necessary new nodes.
          children.insertAll(
              i,
              Iterable<VNode>.generate(
                newEnd - i,
                (int j) => newWidget.children[i + j].createVNode(this),
              ));
          element.insertAllBefore(
            children.sublist(i, newEnd).map((VNode child) => child.node),
            refChild,
          );
        } else if (i < oldEnd) {
          // Delete superfluous old nodes.
          for (final VNode child in children.sublist(i, oldEnd)) {
            child.node.remove();
            child.invalidate();
          }
          children.removeRange(i, oldEnd);
        }
      }

      newWidget
        ..applyAttributes(element.attributes)
        ..applyClasses(element.classes)
        ..applyData(element.dataset);
      if (newWidget == widget) {
        final int n = children.length;
        for (int i = 0; i < n; i++) {
          if (children[i].hasDirtyChild) {
            updateChild(i, i);
          }
        }
      } else {
        final int m = newWidget.children.length;
        final int n = children.length;

        // Preserve prefix with unchanged widgets.
        int i = 0;
        while (i < m && i < n && newWidget.children[i] == children[i].widget) {
          if (children[i].hasDirtyChild) {
            updateChild(i, i);
          }
          i += 1;
        }
        // Preserve suffix with unchanged widgets.
        int k = 0;
        while (i + k < m &&
            i + k < n &&
            newWidget.children[m - 1 - k] == children[n - 1 - k].widget) {
          k += 1;
          if (children[n - k].hasDirtyChild) {
            updateChild(n - k, m - k);
          }
        }
        // Replace old children i..n-k with new children i..m-k.
        replaceRange(i, n - k, m - k);

        widget = newWidget;
      }
      return this;
    } else {
      return newWidget.createVNode(invalidate());
    }
  }

  @override
  BuildRoot invalidate() {
    widget = null;
    element = null;
    if (children != null) {
      for (final VNode child in children) {
        child.invalidate();
      }
      children = null;
    }
    return super.invalidate();
  }
}

class Img extends Tag {
  const Img({
    this.src,
    this.alt,
    this.width,
    this.height,
  }) : super(tag: 'img');

  final String src;
  final String alt;
  final int width;
  final int height;

  @override
  void applyAttributes(Map<String, String> attributes) {
    _setAttribute(attributes, 'src', src);
    _setAttribute(attributes, 'alt', alt);
    _setAttribute(attributes, 'width', width?.toString());
    _setAttribute(attributes, 'height', height?.toString());
  }
}

class Div extends Tag {
  const Div([List<Widget> children = const <Widget>[]])
      : super(
          tag: 'div',
          children: children,
        );
}

class FocusableDiv extends Tag {
  const FocusableDiv(this.tabIndex, [List<Widget> children = const <Widget>[]])
      : super(
          tag: 'div',
          children: children,
        );

  final int tabIndex;

  @override
  void applyAttributes(Map<String, String> attributes) {
    _setAttribute(attributes, 'tabIndex', tabIndex?.toString());
  }
}

class Br extends Tag {
  const Br() : super(tag: 'br');
}

class Hr extends Tag {
  const Hr() : super(tag: 'hr');
}

void _setAttribute(Map<String, String> attributes, String key, String value) {
  assert(!key.startsWith('data-'));
  assert(key != 'class');
  if (value == null) {
    attributes.remove(key);
  } else {
    attributes[key] = value;
  }
}
