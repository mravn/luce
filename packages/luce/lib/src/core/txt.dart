import 'dart:html';
import 'vdom.dart';

class Txt extends Widget {
  const Txt(this.text) : assert(text != null);

  final String text;

  @override
  VText createVNode(BuildRoot parent) => VText(this, parent);

  @override
  String toString() => '$runtimeType[$text]';
}

class VText extends VNode {
  VText(this.widget, BuildRoot parent) : super(parent) {
    node = Text(widget.text);
  }

  @override
  Txt widget;
  @override
  Text node;

  @override
  VNode update(Widget newWidget) {
    if (newWidget == widget) {
      return this;
    }
    if (newWidget is Txt) {
      final String newText = newWidget.text;
      final String oldText = widget.text;
      if (newText != oldText) {
        node.replaceData(0, oldText.length, newWidget.text);
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
}
