import 'dart:html';

import 'vdom.dart';

class Attributes extends Widget {
  const Attributes(this.child) : assert(child != null);

  final Widget child;

  void applyAttributes(Map<String, String> attributes) {}

  @override
  VAttributes createVNode(BuildRoot parent) => VAttributes(this, parent);

  @override
  String toString() => '$runtimeType[$child]';
}

class VAttributes extends VSingleChildElement<Attributes> {
  VAttributes(Attributes widget, BuildRoot parent) : super(widget, parent) {
    child = widget.child.createVNode(this);
    element = child.element;
    _applyAttributes(widget, element);
  }

  @override
  VNode updateAndReturnNewChild(Attributes newWidget) {
    final VNode newChild = child.update(newWidget.child);
    if (newChild != child) {
      _applyAttributes(newWidget, newChild.element);
    }
    return newChild;
  }

  void _applyAttributes(Attributes widget, Element element) {
    widget.applyAttributes(element.dataset);
  }
}

class Dataset extends Widget {
  const Dataset(this.child) : assert(child != null);

  final Widget child;

  void applyDataset(Map<String, String> dataset) {}

  @override
  VDataset createVNode(BuildRoot parent) => VDataset(this, parent);

  @override
  String toString() => '$runtimeType[$child]';
}

class VDataset extends VSingleChildElement<Dataset> {
  VDataset(Dataset widget, BuildRoot parent) : super(widget, parent) {
    child = widget.child.createVNode(this);
    element = child.element;
    _applyDataset(widget, element);
  }

  @override
  VNode updateAndReturnNewChild(Dataset newWidget) {
    final VNode newChild = child.update(newWidget.child);
    if (newChild != child) {
      _applyDataset(newWidget, newChild.element);
    }
    return newChild;
  }

  void _applyDataset(Dataset widget, Element element) {
    widget.applyDataset(element.dataset);
  }
}

class Classes extends Widget {
  const Classes(this.child) : assert(child != null);

  final Widget child;

  void applyClasses(Set<String> classes) {}

  @override
  VClasses createVNode(BuildRoot parent) => VClasses(this, parent);

  @override
  String toString() => '$runtimeType[$child]';
}

class VClasses extends VSingleChildElement<Classes> {
  VClasses(Classes widget, BuildRoot parent) : super(widget, parent) {
    child = widget.child.createVNode(this);
    element = child.element;
    _applyClasses(widget, element);
  }

  @override
  VNode updateAndReturnNewChild(Classes newWidget) {
    final VNode newChild = child.update(newWidget.child);
    if (newChild != child) {
      _applyClasses(newWidget, newChild.element);
    }
    return newChild;
  }

  void _applyClasses(Classes widget, Element element) {
    widget.applyClasses(element.classes);
  }
}

class Flag extends Classes {
  const Flag({
    this.className,
    this.when = true,
    Widget child,
  }) : super(child);

  final String className;
  final bool when;

  @override
  void applyClasses(Set<String> classes) {
    if (when) {
      classes.add(className);
    } else {
      classes.remove(className);
    }
  }
}
