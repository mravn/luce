import 'package:test/test.dart';
import 'dart:html';

Matcher isText(Matcher textMatcher) => _IsText(textMatcher);
Matcher isElement(String expectedTag, [Matcher fieldMatcher = anything]) => _IsElement(expectedTag, fieldMatcher);
Matcher hasChildren(Matcher childrenMatcher) => _HasChildren(childrenMatcher);
Matcher hasAttributes(Matcher attributesMatcher) => _HasAttributes(attributesMatcher);
Matcher hasClasses(Matcher classesMatcher) => _HasClasses(classesMatcher);
Matcher hasDataset(Matcher datasetMatcher) => _HasDataset(datasetMatcher);

class _IsText extends FeatureMatcher<Text> {
  final Matcher _textMatcher;

  const _IsText(this._textMatcher);

  bool typedMatches(Text item, Map matchState) {
    bool b = _textMatcher.matches(item.text, matchState);
    print('text match: $b');
    return b;
  }

  Description describe(Description description) => description
      .add('a Text node with text ')
      .addDescriptionOf(_textMatcher);
}

class _IsElement extends FeatureMatcher<Element> {
  final String _expectedTag;
  final Matcher _fieldMatcher;

  const _IsElement(this._expectedTag, this._fieldMatcher);

  bool typedMatches(Element item, Map matchState) {
    bool b1 = item.tagName.toLowerCase() == _expectedTag;
    bool b2 = _fieldMatcher.matches(item, matchState);
    print('tag match $b1');
    print('field match $b2');
    return b1 && b2;
  }

  Description describe(Description description) => description
      .add('an Element with tag ')
      .addDescriptionOf(_expectedTag)
      .add(' and ')
      .addDescriptionOf(_fieldMatcher);
}

class _HasChildren extends FeatureMatcher<Element> {
  final Matcher _matcher;

  const _HasChildren(this._matcher);

  bool typedMatches(Element item, Map matchState) {
    bool b = _matcher.matches(item.childNodes, matchState);
    print('child match $b');
    return b;
  }

  Description describe(Description description) => description
      .add('children ')
      .addDescriptionOf(_matcher);
}

class _HasClasses extends FeatureMatcher<Element> {
  final Matcher _matcher;

  const _HasClasses(this._matcher);

  bool typedMatches(Element item, Map matchState) {
    return _matcher.matches(item.classes, matchState);
  }

  Description describe(Description description) => description
      .add('classes ')
      .addDescriptionOf(_matcher);
}

class _HasDataset extends FeatureMatcher<Element> {
  final Matcher _matcher;

  const _HasDataset(this._matcher);

  bool typedMatches(Element item, Map matchState) {
    return _matcher.matches(item.dataset, matchState);
  }

  Description describe(Description description) => description
      .add('dataset ')
      .addDescriptionOf(_matcher);
}

class _HasAttributes extends FeatureMatcher<Element> {
  final Matcher _matcher;

  const _HasAttributes(this._matcher);

  bool typedMatches(Element item, Map matchState) {
    return _matcher.matches(item.attributes, matchState);
  }

  Description describe(Description description) => description
      .add('has attributes ')
      .addDescriptionOf(_matcher);
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
