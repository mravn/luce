import 'dart:html';
import 'vdom.dart';

class Tag extends Widget {
  final String tag;
  final List<Widget> children;

  const Tag({
    this.tag,
    this.children = const <Widget>[],
  })  : assert(tag != null),
        assert(children != null);

  void applyClasses(Set<String> classes) {}

  void applyData(Map<String, String> data) {}

  void applyAttributes(Map<String, String> attributes) {}

  @override
  VTag createVNode(BuildRoot parent) => VTag(this, parent);

  @override
  String toString() => '$runtimeType[$tag, $children]';
}

class VTag extends VNode {
  Tag widget;
  Element node;
  List<VNode> children;

  VTag(this.widget, BuildRoot parent) : super(parent) {
    node = document.createElement(widget.tag);
    widget.applyAttributes(node.attributes);
    widget.applyClasses(node.classes);
    widget.applyData(node.dataset);
    children = widget.children.map((w) => w.createVNode(this)).toList();
    if (!children.isEmpty) {
      node.insertAllBefore(children.map((child) => child.node), null);
    }
  }

  @override
  VNode update(Widget newWidget) {
    if (!hasDirtyChild && newWidget == widget) return this;
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
          // reuse as many slots as possible
          updateChild(i, i);
          i += 1;
        }
        if (i < newEnd) {
          final Node refChild = (i == children.length) ? null : children[i].node;
          // insert new nodes
          children.insertAll(
              i,
              Iterable<VNode>.generate(
                newEnd - i,
                (j) => newWidget.children[i + j].createVNode(this),
              ));
          node.insertAllBefore(children.sublist(i, newEnd).map((x) => x.node), refChild);
        } else if (i < oldEnd) {
          // delete old nodes
          for (final child in children.sublist(i, oldEnd)) {
            child.node.remove();
            child.invalidate();
          }
          children.removeRange(i, oldEnd);
        }
      }

      newWidget.applyAttributes(node.attributes);
      newWidget.applyClasses(node.classes);
      newWidget.applyData(node.dataset);
      if (newWidget == widget) {
        for (int i = 0, n = children.length; i < n; i++) {
          if (children[i].hasDirtyChild) updateChild(i, i);
        }
      } else {
        final int m = newWidget.children.length;
        final int n = children.length;
        print('new child count $m');
        print('old child count $n');

        // preserve prefix with unchanged widgets
        int i = 0;
        while (i < m && i < n && newWidget.children[i] == children[i].widget) {
          if (children[i].hasDirtyChild) updateChild(i, i);
          i += 1;
        }
        print('preserved prefix length: $i');

        // preserve suffix with unchanged widgets
        int k = 0;
        while (i + k < m &&
            i + k < n &&
            newWidget.children[m - 1 - k] == children[n - 1 - k].widget) {
          k += 1;
          if (children[n - k].hasDirtyChild) updateChild(n - k, m - k);
        }
        print('preserved suffix length: $k');

        // replace old children i..n-k with new children i..m-k
        replaceRange(i, n - k, m - k);

        // update attributes and widget
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
    node = null;
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
  final String src;
  final String alt;
  final int width;
  final int height;

  const Img({
    this.src,
    this.alt,
    this.width,
    this.height,
  }) : super(tag: 'img');

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
