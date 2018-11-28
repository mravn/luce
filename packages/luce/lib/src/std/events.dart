import 'dart:async';
import 'dart:html';

import 'package:meta/meta.dart';

import '../core/vdom.dart';

typedef MouseEventHandler = void Function(MouseEvent event);

class MouseEvents extends Widget {
  MouseEvents({@required this.child, this.onClick, this.onMove})
      : assert(child != null);

  final Widget child;
  final MouseEventHandler onClick;
  final MouseEventHandler onMove;

  @override
  VMouseEvents createVNode(BuildRoot parent) => VMouseEvents(this, parent);
}

class VMouseEvents extends VSingleChildElement<MouseEvents> {
  VMouseEvents(MouseEvents widget, BuildRoot parent) : super(widget, parent) {
    child = widget.child.createVNode(this);
    element = child.element;
    _renewSubscriptions(widget, element);
  }

  StreamSubscription<MouseEvent> _onClickSubscription;
  StreamSubscription<MouseEvent> _onMoveSubscription;

  @override
  VNode updateAndReturnNewChild(MouseEvents newWidget) {
    final VNode newChild = child.update(newWidget.child);
    _renewSubscriptions(newWidget, newChild.element);
    return newChild;
  }

  void _cancelSubscription() {
    _onClickSubscription?.cancel();
    _onMoveSubscription?.cancel();
  }

  void _renewSubscriptions(MouseEvents widget, Element node) {
    _cancelSubscription();
    if (widget.onClick != null) {
      _onClickSubscription = node.onClick.listen(widget.onClick);
    }
    if (widget.onMove != null) {
      _onMoveSubscription = node.onMouseMove.listen(widget.onMove);
    }
  }

  @override
  BuildRoot invalidate() {
    _cancelSubscription();
    return super.invalidate();
  }
}

typedef KeyboardEventHandler = void Function(KeyboardEvent event);

class KeyboardEvents extends Widget {
  KeyboardEvents({
    @required this.child,
    this.onKeyPress,
    this.onKeyDown,
    this.onKeyUp,
  }) : assert(child != null);

  final Widget child;
  final KeyboardEventHandler onKeyPress;
  final KeyboardEventHandler onKeyDown;
  final KeyboardEventHandler onKeyUp;

  @override
  VKeyboardEvents createVNode(BuildRoot parent) =>
      VKeyboardEvents(this, parent);
}

class VKeyboardEvents extends VSingleChildElement<KeyboardEvents> {
  VKeyboardEvents(KeyboardEvents widget, BuildRoot parent)
      : super(widget, parent) {
    child = widget.child.createVNode(this);
    element = child.element;
    _renewSubscriptions(widget, element);
  }

  StreamSubscription<KeyboardEvent> _onKeyPressSubscription;
  StreamSubscription<KeyboardEvent> _onKeyDownSubscription;
  StreamSubscription<KeyboardEvent> _onKeyUpSubscription;

  @override
  VNode updateAndReturnNewChild(KeyboardEvents newWidget) {
    final VNode newChild = child.update(newWidget.child);
    _renewSubscriptions(newWidget, newChild.element);
    return newChild;
  }

  void _cancelSubscription() {
    _onKeyPressSubscription?.cancel();
    _onKeyDownSubscription?.cancel();
    _onKeyUpSubscription?.cancel();
  }

  void _renewSubscriptions(KeyboardEvents widget, Element node) {
    _cancelSubscription();
    if (widget.onKeyPress != null) {
      _onKeyPressSubscription = node.onKeyPress.listen(widget.onKeyPress);
    }
    if (widget.onKeyDown != null) {
      _onKeyDownSubscription = node.onKeyDown.listen(widget.onKeyDown);
    }
    if (widget.onKeyUp != null) {
      _onKeyUpSubscription = node.onKeyUp.listen(widget.onKeyUp);
    }
  }

  @override
  BuildRoot invalidate() {
    _cancelSubscription();
    return super.invalidate();
  }
}
