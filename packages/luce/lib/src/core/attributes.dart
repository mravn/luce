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

class VAttributes extends VSingleChildNode<Attributes> {
  VAttributes(Attributes widget, BuildRoot parent) : super(widget, parent) {
    child = widget.child.createVNode(parent);
    node = child.node;
    widget.applyAttributes(node.attributes);
  }

  @override
  VNode updateAndReturnChild(Attributes newWidget) {
    newWidget.applyAttributes(node.attributes);
    return child.update(newWidget.child);
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

class VDataset extends VSingleChildNode<Dataset> {
  VDataset(Dataset widget, BuildRoot parent) : super(widget, parent) {
    child = widget.child.createVNode(parent);
    node = child.node;
    widget.applyDataset(node.dataset);
  }

  @override
  VNode updateAndReturnChild(Dataset newWidget) {
    newWidget.applyDataset(node.dataset);
    return child.update(newWidget.child);
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

class VClasses extends VSingleChildNode<Classes> {
  VClasses(Classes widget, BuildRoot parent) : super(widget, parent) {
    child = widget.child.createVNode(parent);
    node = child.node;
    widget.applyClasses(node.classes);
  }

  @override
  VNode updateAndReturnChild(Classes newWidget) {
    newWidget.applyClasses(node.classes);
    return child.update(newWidget.child);
  }
}

class Flag extends Classes {
  Flag({
    this.className,
    this.when,
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
