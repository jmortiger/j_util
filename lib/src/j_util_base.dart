@Deprecated("Use extensions.dart/RegExpExt.removeZerosFromTime")
final removeZerosFromTimeString = RegExp(
    r'(^0+:|^0+(?=[123456789]+:)|(?<=:)(?<!.*[123456789].*)0{2}:|(?<=:)(?<!.*[123456789].*)0{1}|(?<=\.\d*?[123456789]*?)(?<!\.)0+(?!\d+$))');

/// Matches camelCase to convert to snake_case.
@Deprecated("Use extensions.dart/RegExpExt.camelCase")
final matchSnakeCase = RegExp(
    r'((?:.*?[^_\u2028\n\r\u000B\f\u2029\u0085]))([A-Z])((?:.*?(?=.[A-Z]|[\u2028\n\r\u000B\f\u2029\u0085])))');

/// Matches \*THIS_STUFF\*, captures THIS_STUFF in group 1
@Deprecated("Use extensions.dart/RegExpExt.asteriskBoundConstant")
final matchAsteriskBoundConstantName = RegExp(r'\*([A-Z_]+)\*');
@Deprecated("Use extensions.dart/RegExpExt.asteriskBoundConstantString")
const matchAsteriskBoundConstantNameString =
    r'\*(' + matchConstantCaseString + r')\*';
@Deprecated("Use extensions.dart/RegExpExt.constantCaseString")
const matchConstantCaseString = r'[A-Z_]+';

/// Matches \*THIS_STUFF\*, captures \*THIS_STUFF\* in group 1
@Deprecated(
    "Use extensions.dart/RegExpExt.asteriskBoundConstantNameAndAsterisks")
final matchAsteriskBoundConstantNameAndAsterisks = RegExp(r'(\*(?:[A-Z_]+)\*)');

/// Matches the space between camel cased words.
@Deprecated(
    "Use extensions.dart/RegExpExt.asteriskBoundConstantNameAndAsterisks")
final matchCamelCaseWordBorders = RegExp(r'(?<!^)(?=[A-Z])');

final matchLowercase = RegExp(r'([a-z]+)');

const defaultIndent = "  ";

// String findMostRelated(List<String> strings, String searchString) {}
// double findRelationValue(String str, String searchString) {
//   if (searchString.compareTo(str) == 0) return double.infinity;
// }
