import 'dart:html';
import 'package:test/test.dart';

Matcher isText(Matcher textMatcher) => _IsText(textMatcher);

Matcher isElement(String expectedTag, [Matcher fieldMatcher = anything]) =>
    _IsElement(expectedTag, fieldMatcher);

Matcher hasChildren(Matcher childrenMatcher) => _HasChildren(childrenMatcher);

Matcher hasAttributes(Matcher attributesMatcher) =>
    _HasAttributes(attributesMatcher);

Matcher hasClasses(Matcher classesMatcher) => _HasClasses(classesMatcher);

Matcher hasDataset(Matcher datasetMatcher) => _HasDataset(datasetMatcher);

class _IsText extends FeatureMatcher<Text> {
  const _IsText(this._textMatcher);

  final Matcher _textMatcher;

  @override
  bool typedMatches(Text item, Map<dynamic, dynamic> matchState) =>
      _textMatcher.matches(item.text, matchState);

  @override
  Description describe(Description description) =>
      description.add('a Text node with text ').addDescriptionOf(_textMatcher);
}

class _IsElement extends FeatureMatcher<Element> {
  const _IsElement(this._expectedTag, this._fieldMatcher);

  final String _expectedTag;
  final Matcher _fieldMatcher;

  @override
  bool typedMatches(Element item, Map<dynamic, dynamic> matchState) =>
      item.tagName.toLowerCase() == _expectedTag &&
      _fieldMatcher.matches(item, matchState);

  @override
  Description describe(Description description) => description
      .add('an Element with tag ')
      .addDescriptionOf(_expectedTag)
      .add(' and ')
      .addDescriptionOf(_fieldMatcher);
}

class _HasChildren extends FeatureMatcher<Element> {
  const _HasChildren(this._matcher);

  final Matcher _matcher;

  @override
  bool typedMatches(Element item, Map<dynamic, dynamic> matchState) =>
      _matcher.matches(item.childNodes, matchState);

  @override
  Description describe(Description description) =>
      description.add('children ').addDescriptionOf(_matcher);
}

class _HasClasses extends FeatureMatcher<Element> {
  const _HasClasses(this._matcher);

  final Matcher _matcher;

  @override
  bool typedMatches(Element item, Map<dynamic, dynamic> matchState) =>
      _matcher.matches(item.classes, matchState);

  @override
  Description describe(Description description) =>
      description.add('classes ').addDescriptionOf(_matcher);
}

class _HasDataset extends FeatureMatcher<Element> {
  const _HasDataset(this._matcher);

  final Matcher _matcher;

  @override
  bool typedMatches(Element item, Map<dynamic, dynamic> matchState) =>
      _matcher.matches(item.dataset, matchState);

  @override
  Description describe(Description description) =>
      description.add('dataset ').addDescriptionOf(_matcher);
}

class _HasAttributes extends FeatureMatcher<Element> {
  const _HasAttributes(this._matcher);

  final Matcher _matcher;

  @override
  bool typedMatches(Element item, Map<dynamic, dynamic> matchState) =>
      _matcher.matches(item.attributes, matchState);

  @override
  Description describe(Description description) =>
      description.add('has attributes ').addDescriptionOf(_matcher);
}

abstract class FeatureMatcher<T> extends TypeMatcher<T> {
  const FeatureMatcher();

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) =>
      super.matches(item, matchState) && typedMatches(item, matchState);

  bool typedMatches(T item, Map<dynamic, dynamic> matchState);

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription,
      Map<dynamic, dynamic> matchState, bool verbose) {
    if (item is T) {
      return describeTypedMismatch(item, mismatchDescription, matchState,
          verbose: verbose);
    }

    return super.describe(mismatchDescription.add('not an '));
  }

  Description describeTypedMismatch(T item, Description mismatchDescription,
          Map<dynamic, dynamic> matchState,
          {bool verbose}) =>
      mismatchDescription;
}
