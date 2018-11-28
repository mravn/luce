import 'package:luce/std.dart';

void main() {
  final Counter counter = Counter();
  final Widget widget = CounterComponent(counter);

  mount(widget, querySelector('#output'));

  window.onKeyPress.listen((KeyboardEvent event) {
    counter.up();
  });
}

class Counter with ChangeNotification {
  int _value = 0;

  void up() {
    _value += 1;
    notify();
  }

  int get value => _value;
}

class CounterComponent extends Component {
  CounterComponent(this.counter);

  final Counter counter;

  @override
  Widget build(BuildContext context) {
    context.rebuildOn(counter.changes);
    return MouseEvents(
      onClick: (MouseEvent e) => counter.up(),
      child: Div(<Widget>[
        const Txt('Your Luce app is running.'),
        const Br(),
        Flag(
          className: 'high',
          when: counter.value > 7,
          child: Txt('Counter value is ${counter.value}'),
        ),
      ]),
    );
  }
}
