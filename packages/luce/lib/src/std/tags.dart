import 'package:luce/vdom.dart';

class Div extends Tag {
  const Div({
    this.attributes = const <String, String>{},
    this.classes = const <String>[],
    this.dataset = const <String, String>{},
    this.children = const <Widget>[],
  }) : super('div');

  @override
  final Map<String, String> attributes;
  @override
  final List<String> classes;
  @override
  final Map<String, String> dataset;
  @override
  final List<Widget> children;
}

class Span extends Tag {
  const Span({
    this.attributes = const <String, String>{},
    this.classes = const <String>[],
    this.dataset = const <String, String>{},
    this.children = const <Widget>[],
  }) : super('span');

  @override
  final Map<String, String> attributes;
  @override
  final List<String> classes;
  @override
  final Map<String, String> dataset;
  @override
  final List<Widget> children;
}

class Br extends Tag {
  const Br() : super('br');
}

class Hr extends Tag {
  const Hr() : super('hr');
}

class H1 extends Tag {
  const H1(this.text) : super('h1');

  final String text;

  @override
  List<Widget> get children => <Widget>[Txt(text)];
}

class H2 extends Tag {
  const H2(this.text) : super('h2');

  final String text;

  @override
  List<Widget> get children => <Widget>[Txt(text)];
}

class H3 extends Tag {
  const H3(this.text) : super('h3');

  final String text;

  @override
  List<Widget> get children => <Widget>[Txt(text)];
}

class P extends Tag {
  const P(this.text) : super('p');

  final String text;

  @override
  List<Widget> get children => <Widget>[Txt(text)];
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
  Map<String, String> get attributes => <String, String>{
        'src': src,
        'alt': alt,
        'width': width?.toString(),
        'height': height?.toString(),
      };
}
