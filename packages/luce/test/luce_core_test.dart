import 'package:luce_test/luce_test.dart';
import 'package:luce/luce_fake.dart';

void main() {
  group('wire', () {
    FakeDom dom;

    setUp(() {
      dom = FakeDom();
    });

    test('sets top-level text', () async {
      mount(const Text('hello'), dom);

      await rendering();

      expect(dom.root.children, hasLength(1));
      expect(dom.root.children[0], isFakeText(equals('hello')));
      expect(dom.nodesCreated, 1);
      expect(dom.domUpdates, 1);
    });

    test('sets top-level element', () async {
      mount(const Div(children: [Text('hello'), Text('world')]), dom);

      await rendering();

      expect(dom.root.children, hasLength(1));
      expect(
        dom.root.children[0],
        isFakeElement(
          'div',
          equals([
            isFakeText(equals('hello')),
            isFakeText(equals('world')),
          ]),
        ),
      );
      expect(dom.nodesCreated, 3);
      expect(dom.domUpdates, 3);
    });

    test('sets top-level component', () async {
      mount(CounterComponent(Counter()), dom);

      await rendering();

      expect(dom.root.children, hasLength(1));
      expect(
        dom.root.children[0],
        isFakeElement(
          'div',
          equals([
            isFakeText(equals('hello')),
            isFakeElement('br', isEmpty),
            isFakeText(equals('0')),
          ]),
        ),
      );
      expect(dom.nodesCreated, 4);
      expect(dom.domUpdates, 4);
    });

    test('updates top-level text on remount with other widget', () async {
      mount(const Text('hello'), dom);
      await rendering();
      dom.clearStats();

      mount(const Text('world'), dom);
      await rendering();

      expect(dom.root.children, hasLength(1));
      expect(dom.root.children[0], isFakeText(equals('world')));
      expect(dom.nodesCreated, 1);
      expect(dom.domUpdates, 1);
    });

    test('updates top-level element on remount', () async {
      mount(const Div(children: [Text('hello'), Text('world')]), dom);
      await rendering();
      dom.clearStats();

      mount(const Text('42'), dom);
      await rendering();

      expect(dom.root.children, hasLength(1));
      expect(dom.root.children[0], isFakeText(equals('42')));
      expect(dom.nodesCreated, 1);
      expect(dom.domUpdates, 1);
    });

    test('updates top-level component on state change', () async {
      final Counter counter = Counter();
      mount(CounterComponent(counter), dom);
      await rendering();
      dom.clearStats();

      counter.up();
      counter.up();
      await rendering();
      counter.up();
      await rendering();

      expect(dom.root.children, hasLength(1));
      expect(
        dom.root.children[0],
        isFakeElement(
          'div',
          equals([
            anything,
            anything,
            isFakeText(equals('3')),
          ]),
        ),
      );
      expect(dom.nodesCreated, 0);
      expect(dom.domUpdates, 2);
    });

    test('updates child appending', () async {
      final Counter counter = Counter();
      mount(UnaryCounterComponent(counter), dom);
      await rendering();
      dom.clearStats();

      counter.up();
      counter.up();
      await rendering();
      counter.up();
      await rendering();

      expect(dom.root.children, hasLength(1));
      expect(
        dom.root.children[0],
        isFakeElement(
          'div',
          equals([
            isFakeText(equals('|')),
            isFakeText(equals('|')),
            isFakeText(equals('|')),
          ]),
        ),
      );
      expect(dom.nodesCreated, 3);
      expect(dom.domUpdates, 2); // 2+1 nodes appended
    });

    test('updates child removal at end', () async {
      final Counter counter = Counter.startingAt(5);
      mount(UnaryCounterComponent(counter), dom);
      await rendering();
      dom.clearStats();

      counter.down();
      counter.down();
      await rendering();
      counter.down();
      await rendering();

      expect(dom.root.children, hasLength(1));
      expect(
        dom.root.children[0],
        isFakeElement(
          'div',
          equals([
            isFakeText(equals('|')),
            isFakeText(equals('|')),
          ]),
        ),
      );
      expect(dom.nodesCreated, 0);
      expect(dom.domUpdates, 3); // 3 nodes removed
    });
  });
}

class CounterComponent extends Component {
  final Counter counter;

  const CounterComponent(this.counter);

  @override
  Widget build(BuildContext context) {
    context.rebuildOn(counter.changes);
    return Div(children: [
      const Text('hello'),
      const Br(),
      Text('${counter.value}'),
    ]);
  }
}

class Counter with ChangeNotification {
  int _value = 0;

  Counter();

  Counter.startingAt(int value) : _value = value;

  void up() {
    _value += 1;
    notify();
  }

  void down() {
    _value -= 1;
    notify();
  }

  int get value => _value;
}

class UnaryCounterComponent extends Component {
  final Counter counter;

  const UnaryCounterComponent(this.counter);

  @override
  Widget build(BuildContext context) {
    context.rebuildOn(counter.changes);
    return Div(children: List.filled(counter.value, const Text('|')));
  }
}
