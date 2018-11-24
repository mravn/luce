import 'package:test/test.dart';
import 'package:luce/luce_fake.dart';

Matcher isText(Matcher textMatcher) => _IsText(textMatcher);

Matcher isElement(String expectedTag) => _IsElement(expectedTag);

Matcher isFakeText(Matcher textMatcher) => _IsFakeText(textMatcher);

Matcher isFakeElement(String expectedTag, Matcher childrenMatcher) =>
    _IsFakeElement(expectedTag, childrenMatcher);

class _IsText extends FeatureMatcher<Text> {
  final Matcher _textMatcher;

  const _IsText(this._textMatcher);

  bool typedMatches(Text item, Map matchState) {
    return _textMatcher.matches(item.text, matchState);
  }

  Description describe(Description description) => description
      .add('a Text widget with text that ')
      .addDescriptionOf(_textMatcher);
}

class _IsFakeText extends FeatureMatcher<FakeText> {
  final Matcher _textMatcher;

  const _IsFakeText(this._textMatcher);

  bool typedMatches(FakeText item, Map matchState) {
    return _textMatcher.matches(item.text, matchState);
  }

  Description describe(Description description) => description
      .add('a fake Text node with text ')
      .addDescriptionOf(_textMatcher);
}

class _IsElement extends FeatureMatcher<Element> {
  final String _expectedTag;

  const _IsElement(this._expectedTag);

  bool typedMatches(Element item, Map matchState) {
    return item.nodeName == _expectedTag;
  }

  Description describe(Description description) => description
      .add('an Element widget with tag ')
      .addDescriptionOf(_expectedTag);
}

class _IsFakeElement extends FeatureMatcher<FakeElement> {
  final String _expectedTag;
  final Matcher _childrenMatcher;

  const _IsFakeElement(this._expectedTag, this._childrenMatcher);

  bool typedMatches(FakeElement item, Map matchState) {
    return item.tagName == _expectedTag &&
        _childrenMatcher.matches(item.children, matchState);
  }

  Description describe(Description description) => description
      .add('an fake Element node with tag ')
      .addDescriptionOf(_expectedTag)
      .add('and children ')
      .addDescriptionOf(_childrenMatcher);
}

abstract class FeatureMatcher<T> extends TypeMatcher<T> {
  const FeatureMatcher();

  bool matches(item, Map matchState) =>
      super.matches(item, matchState) && typedMatches(item, matchState);

  bool typedMatches(T item, Map matchState);

  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is T) {
      return describeTypedMismatch(
          item, mismatchDescription, matchState, verbose);
    }

    return super.describe(mismatchDescription.add('not an '));
  }

  Description describeTypedMismatch(T item, Description mismatchDescription,
          Map matchState, bool verbose) =>
      mismatchDescription;
}
