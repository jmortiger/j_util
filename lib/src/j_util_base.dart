final removeZerosFromTimeString = RegExp(
    r'(^0+:|^0+(?=[123456789]+:)|(?<=:)(?<!.*[123456789].*)0{2}:|(?<=:)(?<!.*[123456789].*)0{1}|(?<=\.\d*?[123456789]*?)(?<!\.)0+(?!\d+$))');
final matchSnakeCase = RegExp(
    r'((?:.*?[^_\u2028\n\r\u000B\f\u2029\u0085]))([A-Z])((?:.*?(?=.[A-Z]|[\u2028\n\r\u000B\f\u2029\u0085])))');

/// Matches \*THIS_STUFF\*, captures THIS_STUFF in group 1
final matchAsteriskBoundConstantName = RegExp(r'\*([A-Z_]+)\*');
const matchAsteriskBoundConstantNameString = r'\*([A-Z_]+)\*';

/// Matches \*THIS_STUFF\*, captures \*THIS_STUFF\* in group 1
final matchAsteriskBoundConstantNameAndAsterisks = RegExp(r'(\*(?:[A-Z_]+)\*)');

/// Matches the space between camel cased words.
final matchCamelCaseWordBorders = RegExp(r'(?<!^)(?=[A-Z])');

const defaultIndent = "  ";

// String findMostRelated(List<String> strings, String searchString) {}
// double findRelationValue(String str, String searchString) {
//   if (searchString.compareTo(str) == 0) return double.infinity;
// }
