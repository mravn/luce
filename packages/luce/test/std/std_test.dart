import 'package:luce_test/luce_test.dart';

void main() {
  group('wire', () {
    setUp(() {
      document.body.innerHtml = '';
    });

    test('sets top-level text', () async {
      mount(const Txt('hello'), document.body);

      await rendering();

      expect(document.body.childNodes, hasLength(1));
      expect(document.body.childNodes[0], isText(equals('hello')));
    });

    test('sets top-level element', () async {
      mount(
        const Div(<Widget>[Txt('hello'), Txt('world')]),
        document.body,
      );

      await rendering();

      expect(document.body.children, hasLength(1));
      expect(
        document.body.children[0],
        isElement(
          'div',
          hasChildren(equals(<Matcher>[
            isText(equals('hello')),
            isText(equals('world')),
          ])),
        ),
      );
    });

    test('sets top-level element with intrinsic attributes', () async {
      mount(const Img(src: 'hello.png'), document.body);

      await rendering();

      expect(document.body.children, hasLength(1));
      expect(
        document.body.children[0],
        isElement(
          'img',
          hasAttributes(equals(<String, String>{'src': 'hello.png'})),
        ),
      );
    });

    test('sets top-level element with supplied attributes', () async {
      mount(
        const Flag(className: 'hello', child: Div()),
        document.body,
      );

      await rendering();

      expect(document.body.children, hasLength(1));
      expect(
        document.body.children[0],
        isElement('div', hasClasses(equals(<String>['hello']))),
      );
    });

    test('sets top-level text with supplied attributes, wrap', () async {
      mount(
        const Flag(className: 'hello', child: Txt('world')),
        document.body,
      );

      await rendering();

      expect(document.body.children, hasLength(1));
      expect(
        document.body.children[0],
        isElement(
          'span',
          allOf(
            hasClasses(contains('hello')),
            hasChildren(contains(isText(equals('world')))),
          ),
        ),
      );
    });

    test('sets top-level component with element child', () async {
      mount(CounterComponent(Counter.startingAt(42)), document.body);

      await rendering();

      expect(document.body.children, hasLength(1));
      expect(
        document.body.children[0],
        isElement(
          'div',
          hasChildren(equals(<Matcher>[
            isText(equals('hello')),
            isElement('br'),
            isText(equals('42')),
          ])),
        ),
      );
    });

    test('sets top-level component with text child', () async {
      mount(TextCounterComponent(Counter.startingAt(7)), document.body);

      await rendering();

      expect(document.body.childNodes, hasLength(1));
      expect(document.body.childNodes[0], isText(equals('7')));
    });

    test('updates top-level text on remount with other widget', () async {
      mount(const Txt('hello'), document.body);
      await rendering();

      mount(const Txt('world'), document.body);
      await rendering();

      expect(document.body.childNodes, hasLength(1));
      expect(document.body.childNodes[0], isText(equals('world')));
    });

    test('updates top-level element on remount', () async {
      mount(
        const Div(<Widget>[Txt('hello'), Txt('world')]),
        document.body,
      );

      mount(const Txt('42'), document.body);
      await rendering();

      expect(document.body.childNodes, hasLength(1));
      expect(document.body.childNodes[0], isText(equals('42')));
    });

    test('updates top-level component on state change', () async {
      final Counter counter = Counter();
      mount(CounterComponent(counter), document.body);
      await rendering();

      counter..up()..up();
      await rendering();
      counter.up();
      await rendering();

      expect(document.body.children, hasLength(1));
      expect(
        document.body.children[0],
        isElement(
          'div',
          hasChildren(equals(<Matcher>[
            anything,
            anything,
            isText(equals('3')),
          ])),
        ),
      );
    });

    test('updates child being appended', () async {
      final Counter counter = Counter();
      mount(ListCounterComponent(Counter(), counter), document.body);
      await rendering();

      counter..up()..up();
      await rendering();
      counter.up();
      await rendering();

      expect(document.body.children, hasLength(1));
      expect(
        document.body.children[0],
        isElement(
          'div',
          hasChildren(equals(<Matcher>[
            isText(equals('0')),
            isText(equals('1')),
            isText(equals('2')),
          ])),
        ),
      );
    });

    test('updates child removal at end', () async {
      final Counter counter = Counter.startingAt(5);
      mount(ListCounterComponent(Counter(), counter), document.body);
      await rendering();

      counter..down()..down();
      await rendering();
      counter.down();
      await rendering();

      expect(document.body.children, hasLength(1));
      expect(
        document.body.children[0],
        isElement(
          'div',
          hasChildren(equals(<Matcher>[
            isText(equals('0')),
            isText(equals('1')),
          ])),
        ),
      );
    });

    test('updates child insertion at start', () async {
      final Counter counter = Counter.startingAt(5);
      mount(
          ListCounterComponent(counter, Counter.startingAt(6)), document.body);
      await rendering();

      counter..down()..down();
      await rendering();
      counter.down();
      await rendering();

      expect(document.body.children, hasLength(1));
      expect(
        document.body.children[0],
        isElement(
          'div',
          hasChildren(equals(<Matcher>[
            isText(equals('2')),
            isText(equals('3')),
            isText(equals('4')),
            isText(equals('5')),
          ])),
        ),
      );
    });

    test('updates child removal at start', () async {
      final Counter counter = Counter();
      mount(
          ListCounterComponent(counter, Counter.startingAt(5)), document.body);
      await rendering();

      counter..up()..up();
      await rendering();
      counter.up();
      await rendering();

      expect(document.body.children, hasLength(1));
      expect(
        document.body.children[0],
        isElement(
          'div',
          hasChildren(equals(<Matcher>[
            isText(equals('3')),
            isText(equals('4')),
          ])),
        ),
      );
    });
  });
}

class CounterComponent extends Component {
  const CounterComponent(this.counter);

  final Counter counter;

  @override
  Widget build(BuildContext context) {
    context.rebuildOn(counter.changes);
    return Div(<Widget>[
      const Txt('hello'),
      const Br(),
      Txt('${counter.value}'),
    ]);
  }
}

class Counter with ChangeNotification {
  Counter();

  Counter.startingAt(int value) : _value = value;

  int _value = 0;

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

const Txt zero = Txt('0');
const Txt one = Txt('1');
const Txt two = Txt('2');
const Txt three = Txt('3');
const Txt four = Txt('4');
const Txt five = Txt('5');
const Txt six = Txt('6');
const Txt seven = Txt('7');
const Txt eight = Txt('8');
const Txt nine = Txt('9');
const List<Txt> numbers = <Txt>[
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
];

class ListCounterComponent extends Component {
  const ListCounterComponent(this.startCounter, this.endCounter);

  final Counter startCounter;
  final Counter endCounter;

  @override
  Widget build(BuildContext context) {
    context..rebuildOn(startCounter.changes)..rebuildOn(endCounter.changes);
    return Div(numbers.sublist(startCounter.value, endCounter.value));
  }
}

class TextCounterComponent extends Component {
  TextCounterComponent(this.counter);

  final Counter counter;

  @override
  Widget build(BuildContext context) => Txt('${counter.value}');
}
