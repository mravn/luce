import 'package:luce/vdom.dart';

class Div extends Tag {
  const Div([this.children = const <Widget>[]])
      : super('div');

  @override
  final List<Widget> children;
}

class Span extends Tag {
  const Span([this.children = const <Widget>[]])
      : super('span');

  @override
  final List<Widget> children;
}

class P extends Tag {
  const P([this.children = const <Widget>[]])
      : super('p');

  @override
  final List<Widget> children;
}

class Br extends Tag {
  const Br() : super('br');

  @override
  List<Widget> get children => const <Widget>[];
}

class Hr extends Tag {
  const Hr() : super('hr');

  @override
  List<Widget> get children => const <Widget>[];
}

class Img extends Tag {
  const Img({
    this.src,
    this.alt,
    this.width,
    this.height,
  }) : super('img');

  final String src;
  final String alt;
  final int width;
  final int height;

  @override
  List<Widget> get children => const <Widget>[];

  @override
  void applyAttributes(Map<String, String> attributes) {
    _setAttribute(attributes, 'src', src);
    _setAttribute(attributes, 'alt', alt);
    _setAttribute(attributes, 'width', width?.toString());
    _setAttribute(attributes, 'height', height?.toString());
  }
}

typedef Builder = Widget Function();

Widget toWidget(dynamic x) {
  if (x is Widget) {
    return x;
  }
  if (x is Builder) {
    return x();
  }
  return Txt('$x');
}

void _setAttribute(Map<String, String> attributes, String key, String value) {
  assert(!key.startsWith('data-'));
  assert(key != 'class');
  if (value == null) {
    attributes.remove(key);
  } else {
    attributes[key] = value;
  }
}
