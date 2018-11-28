import '../core/tag.dart';
import '../core/vdom.dart';

class Div extends Tag {
  const Div([List<Widget> children = const <Widget>[]])
      : super(
    tag: 'div',
    children: children,
  );
}

class FocusableDiv extends Tag {
  const FocusableDiv(this.tabIndex, [List<Widget> children = const <Widget>[]])
      : super(
    tag: 'div',
    children: children,
  );

  final int tabIndex;

  @override
  void applyAttributes(Map<String, String> attributes) {
    _setAttribute(attributes, 'tabIndex', tabIndex?.toString());
  }
}

class Br extends Tag {
  const Br() : super(tag: 'br');
}

class Hr extends Tag {
  const Hr() : super(tag: 'hr');
}

class Img extends Tag {
  const Img({
    this.src,
    this.alt,
    this.width,
    this.height,
  }) : super(tag: 'img');

  final String src;
  final String alt;
  final int width;
  final int height;

  @override
  void applyAttributes(Map<String, String> attributes) {
    _setAttribute(attributes, 'src', src);
    _setAttribute(attributes, 'alt', alt);
    _setAttribute(attributes, 'width', width?.toString());
    _setAttribute(attributes, 'height', height?.toString());
  }
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
