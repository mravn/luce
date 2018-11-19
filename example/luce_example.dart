import 'package:luce/luce.dart';
import 'dart:html' as html;

void main() {
  final HtmlState state = HtmlState();
  final Counter counter = Counter(state);
  final Widget widget = CounterWidget(counter);

  state.wireUp(widget, html.querySelector('#output'));

  html.window.onKeyPress.listen((html.KeyboardEvent event) {
    counter.up();
  });
}

class Counter {
  final State state;

  Counter(this.state);

  int _value = 0;

  void up() {
    state.update(() {
      _value += 1;
    });
  }

  int get value => _value;
}

class CounterWidget extends LazyWidget {
  final Counter counter;

  CounterWidget(this.counter);

  Widget build() {
    return Div(children: [
      Text('Your Dart app is running.'),
      Text('Counter value is ${counter.value}'),
    ]);
  }
}
