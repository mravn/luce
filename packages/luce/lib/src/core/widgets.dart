import 'state.dart';

abstract class Widget {
  const Widget();
}

abstract class Component extends Widget {
  const Component();

  Widget build(BuildContext context);
}

class Text extends Widget {
  final String text;

  const Text(this.text);

  @override
  String toString() {
    return "$runtimeType[$text]";
  }
}

class Element extends Widget {
  final String key;
  final String nodeName;
  final FixedMap attributes;
  final List<Widget> children;

  const Element({
    this.nodeName,
    this.key = null,
    this.attributes = FixedMap.empty,
    this.children = const <Widget>[],
  });

  @override
  String toString() {
    return "$runtimeType[$nodeName, $key, $attributes, $children]";
  }
}

class FixedMap {
  static const empty = FixedMap._(<String, dynamic>{});

  factory FixedMap(Map<String, dynamic> map) {
    return FixedMap._(Map.from(map));
  }

  const FixedMap._(this._map);

  final Map<String, dynamic> _map;

  Iterable<String> get keys => _map.keys;

  dynamic operator [](String key) => _map[key];

  bool containsKey(String key) => _map.containsKey(key);

  FixedMap operator +(FixedMap other) {
    final Map<String, dynamic> out = <String, dynamic>{};
    out.addAll(_map);
    for (final String key in other.keys) {
      out[key] = other[key];
    }
    return FixedMap._(out);
  }

  @override
  String toString() {
    return "$runtimeType[$_map]";
  }
}

class FixedMapBuilder {
  Map<String, dynamic> _map = {};

  void put(String key, dynamic value) {
    _map[key] = value;
  }

  FixedMap build() {
    final FixedMap result = FixedMap._(_map);
    _map = null;
    return result;
  }
}
