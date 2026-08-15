class TextUtils {
  TextUtils._();

  static String initial(String value) {
    return value.trim().isEmpty ? '?' : value.trim()[0].toUpperCase();
  }

  static String counted(int count, String singular, [String? plural]) {
    final String word = count == 1 ? singular : (plural ?? '${singular}s');
    return '$count $word';
  }

  static bool matchesQuery(String query, Iterable<String> fields) {
    final String search = query.toLowerCase();
    if (search.isEmpty) {
      return true;
    }
    return fields.any((String field) => field.toLowerCase().contains(search));
  }
}
