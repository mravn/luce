import 'package:luce/vdom.dart';

class Verbatim extends Widget {
  const Verbatim(this.html);

  final String html;

  @override
  VNode createVNode(BuildRoot parent) => VVerbatim(this, parent);

  @override
  String toString() => '$runtimeType[$html]';
}

class VVerbatim extends VNode {
  VVerbatim(this.widget, BuildRoot parent) : super(parent) {
    node = document.createElement('div')..setInnerHtml(widget.html);
  }

  @override
  Verbatim widget;

  @override
  Element node;

  @override
  Element get element => node;

  @override
  VNode update(Widget newWidget) {
    if (newWidget == widget) {
      return this;
    }
    if (newWidget is Verbatim) {
      final String newHtml = newWidget.html;
      final String oldHtml = widget.html;
      if (newHtml != oldHtml) {
        node.setInnerHtml(newHtml);
      }
      widget = newWidget;
      return this;
    } else {
      return newWidget.createVNode(invalidate());
    }
  }

  @override
  BuildRoot invalidate() {
    widget = null;
    node = null;
    return super.invalidate();
  }

  @override
  String toString() => '$runtimeType[$widget]';
}
