import 'package:luce/luce_core.dart' as luce;

void mount(luce.Widget widget, FakeDom dom) {
  luce.mount(widget, dom, dom.root);
}

class FakeDom implements luce.Dom<FakeNode, FakeElement, FakeText> {
  final FakeNode root = FakeNode();
  int _nodesCreated = 0;
  int _domUpdates = 0;

  @override
  FakeElement createElement(String tagName) {
    _nodesCreated += 1;
    return FakeElement(tagName);
  }

  @override
  FakeText createText(String text) {
    _nodesCreated += 1;
    return FakeText(text);
  }

  @override
  void append(FakeNode parent, FakeNode node) {
    _domUpdates += 1;
    parent.append(node);
  }

  @override
  Map<String, String> attributes(FakeElement element) {
    return element.attributes;
  }

  @override
  FakeNode firstChild(FakeNode node) {
    return node.firstChild;
  }

  @override
  bool hasChildNodes(FakeNode node) {
    return node.hasChildNodes();
  }

  @override
  void insertAllBefore(
      FakeNode parent, Iterable<FakeNode> newNodes, FakeNode refChild) {
    _domUpdates += 1;
    parent.insertAllBefore(newNodes, refChild);
  }

  @override
  FakeNode nextNode(FakeNode node) {
    return node.nextNode;
  }

  @override
  void remove(FakeNode node) {
    _domUpdates += 1;
    node.remove();
  }

  @override
  void replaceData(FakeText text, int offset, int count, String data) {
    _domUpdates += 1;
    text.replaceData(offset, count, data);
  }

  @override
  void replaceWith(FakeNode node, FakeNode otherNode) {
    _domUpdates += 1;
    node.replaceWith(otherNode);
  }
  
  void clearStats() {
    _nodesCreated = 0;
    _domUpdates = 0;
  }

  int get nodesCreated => _nodesCreated;
  int get domUpdates => _domUpdates;
}

class FakeNode {
  FakeNode();

  FakeNode parent;
  final List<FakeNode> children = <FakeNode>[];

  FakeNode get firstChild => children.isEmpty ? null : children.first;

  FakeNode get nextNode {
    if (parent == null) {
      return null;
    }
    final int nextIndex = parent.children.indexOf(this) + 1;
    return nextIndex == parent.children.length ? null : parent.children[nextIndex];
  }

  void append(FakeNode node) {
    children.add(node);
    node.parent = this;
  }

  bool hasChildNodes() => children.isNotEmpty;

  void insertAllBefore(Iterable<FakeNode> newNodes, FakeNode refChild) {
    if (refChild == null) {
      children.addAll(newNodes);
    } else {
      final int index = children.indexOf(refChild);
      children.insertAll(index, newNodes);
    }
    for (FakeNode newNode in newNodes) {
      newNode.parent = this;
    }
  }

  void remove() {
    if (parent != null) {
      parent.children.remove(this);
      parent = null;
    }
  }

  void replaceWith(FakeNode otherNode) {
    final int index = parent.children.indexOf(this);
    parent.children[index] = otherNode;
    parent = null;
    otherNode.parent = parent;
  }
}

class FakeText extends FakeNode {
  FakeText(this.text);

  String text;

  void replaceData(int offset, int count, String data) {
    text = text.replaceRange(offset, offset + count, data);
  }
}

class FakeElement extends FakeNode {
  FakeElement(this.tagName);

  final Map<String, String> attributes = <String, String>{};
  final String tagName;
}
