import 'widgets.dart';

class Div extends Element {
  const Div({
    List<Widget> children = const <Widget>[],
    String key,
  }) : super(
          nodeName: 'div',
          children: children,
          key: key,
        );
}

class Br extends Element {
  const Br() : super(nodeName: 'br');
}
