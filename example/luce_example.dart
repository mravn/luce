import 'package:luce/luce.dart';
import 'dart:html' as html;

void main() {
  final Counter counter = Counter();
  final Widget widget = CounterWidget(counter);

  wire(widget, html.querySelector('#output'));

  html.window.onKeyPress.listen((html.KeyboardEvent event) {
    counter.up();
  });
}

class Counter with Notification {
  int _value = 0;

  void up() {
    _value += 1;
    notifyAll();
  }

  int get value => _value;
}

class CounterWidget extends LazyWidget {
  final Counter counter;

  CounterWidget(this.counter);

  Widget build(BuildContext context) {
    context.rebuildOn(counter.notify);
    return Div(children: [
      Text('Your Dart app is running.'),
      Br(),
      Text('Counter value is ${counter.value}'),
    ]);
  }
}
