import 'dart:html';
import 'package:luce/state.dart';
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
    text = Text(widget.text);
  }

  @override
  Txt widget;
  @override
  Element get element {
    if (_span == null) {
      _span = document.createElement('span');
      final Element parent = text.parent;
      if (parent != null) {
        text.replaceWith(_span);
      }
      _span.append(text);
    }
    return _span;
  }
  Element _span;

  @override
  Node get node => _span ?? text;

  Text text;

  @override
  VNode update(Widget newWidget) {
    if (newWidget == widget) {
      return this;
    }
    if (newWidget is Txt) {
      final String newText = newWidget.text;
      final String oldText = widget.text;
      if (newText != oldText) {
        text.replaceData(0, oldText.length, newWidget.text);
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
    _span = null;
    text = null;
    return super.invalidate();
  }

  @override
  String toString() => '$runtimeType[$widget, $text, $_span]';
}
