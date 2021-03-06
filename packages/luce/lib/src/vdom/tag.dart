import 'dart:html';
import 'package:luce/state.dart';
import 'vdom.dart';

abstract class Tag extends Widget {
  const Tag(this.tag) : assert(tag != null);

  final String tag;

  Map<String, String> get attributes => const <String, String>{};

  Iterable<String> get classes => const <String>[];

  Map<String, String> get dataset => const <String, String>{};

  List<Widget> get children => const <Widget>[];

  @override
  VTag createVNode(BuildRoot parent) => VTag(this, parent);

  @override
  String toString() => '$runtimeType[$tag, $children]';
}

class VTag extends VNode {
  VTag(this.widget, BuildRoot parent) : super(parent) {
    element = document.createElement(widget.tag);
    _reconcileAttributes(element.attributes, widget.attributes);
    _reconcileClasses(element.classes, widget.classes);
    _reconcileDatasets(element.dataset, widget.dataset);
    children = widget.children.map((w) => w.createVNode(this)).toList();
    if (children.isNotEmpty) {
      element.insertAllBefore(children.map((child) => child.node), null);
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
        final Node oldNode = oldChild.node;
        final VNode newChild = oldChild.update(newWidget.children[newIndex]);
        if (newChild != oldChild) {
          final Node newNode = newChild.node;
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
                (j) => newWidget.children[i + j].createVNode(this),
              ));
          element.insertAllBefore(
            children.sublist(i, newEnd).map((child) => child.node),
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

      if (widget.attributes != newWidget.attributes) {
        _reconcileAttributes(element.attributes, newWidget.attributes);
      }
      if (widget.classes != newWidget.classes) {
        _reconcileClasses(element.classes, newWidget.classes);
      }
      if (widget.dataset != newWidget.dataset) {
        _reconcileDatasets(element.dataset, newWidget.dataset);
      }
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

  void _reconcileAttributes(
    Map<String, String> current,
    Map<String, String> desired,
  ) {
    for (String key in desired.keys) {
      if (key == 'class' || key.startsWith('data-')) {
        continue;
      }
      final String value = desired[key];
      if (value != null) {
        current[key] = value;
      }
    }
    for (String key in current.keys) {
      if (key == 'class' || key.startsWith('data-')) {
        continue;
      }
      if (desired[key] == null) {
        current.remove(key);
      }
    }
  }

  void _reconcileClasses(Set<String> current, Iterable<String> desired) {
    if (desired.isEmpty) {
      current.clear();
    } else {
      current.addAll(desired);
      if (current.length != desired.length) {
        for (String className in current) {
          if (!desired.contains(className)) {
            current.remove(className);
          }
        }
      }
    }
  }

  void _reconcileDatasets(
    Map<String, String> current,
    Map<String, String> desired,
  ) {
    if (desired.isEmpty) {
      current.clear();
    } else {
      int desiredLength = 0;
      for (String key in desired.keys) {
        final String value = desired[key];
        if (value != null) {
          current[key] = value;
          desiredLength += 1;
        }
      }
      if (current.length != desiredLength) {
        for (String key in current.keys) {
          if (desired[key] == null) {
            current.remove(key);
          }
        }
      }
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

  @override
  String toString() => '$runtimeType[$widget]';
}
