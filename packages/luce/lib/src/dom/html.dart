import 'dart:html' as h;
import 'package:luce/luce_core.dart' as luce;

void mount(luce.Widget widget, h.Element container) {
  luce.mount(widget, realDom, container);
}

const realDom = RealDom();

class RealDom implements luce.Dom<h.Node, h.Element, h.Text> {
  const RealDom();

  @override
  void append(h.Node parent, h.Node node) {
    parent.append(node);
  }

  @override
  Map<String, String> attributes(h.Element element) {
    return element.attributes;
  }

  @override
  h.Element createElement(String tagName) {
    return h.document.createElement(tagName);
  }

  @override
  h.Text createText(String text) {
    return h.Text(text);
  }

  @override
  h.Node firstChild(h.Node node) {
    return node.firstChild;
  }

  @override
  bool hasChildNodes(h.Node node) {
    return node.hasChildNodes();
  }

  @override
  void insertAllBefore(h.Node parent, Iterable<h.Node> newNodes, h.Node refChild) {
    parent.insertAllBefore(newNodes, refChild);
  }

  @override
  h.Node nextNode(h.Node node) {
    return node.nextNode;
  }

  @override
  void remove(h.Node node) {
    node.remove();
  }

  @override
  void replaceData(h.Text text, int offset, int count, String data) {
    text.replaceData(offset, count, data);
  }

  @override
  void replaceWith(h.Node node, h.Node otherNode) {
    node.replaceWith(otherNode);
  }
}