import 'package:luce/state.dart';
import 'package:test/test.dart';

void main() {
  group('group', () {
    test('test', () {
      final State<String> state = State<String>();
      expect(state.current, isNull);
    });
  });
}
