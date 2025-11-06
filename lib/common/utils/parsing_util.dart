abstract class ParsingUtil {
  static const String _defaultSeparator = ', ';

  static List<String> parseStringToList(
    String string, {
    String separator = _defaultSeparator,
  }) => string.split(separator);

  static String parseListToString(
    List<String> list, {
    String separator = _defaultSeparator,
  }) => list.join(separator);
}
