class StringUtils {
  const StringUtils._();

  static String initials(String displayName) {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first.substring(0, 1);
    if (parts.length > 1 && parts.last.isNotEmpty) {
      return (first + parts.last.substring(0, 1)).toUpperCase();
    }
    return first.toUpperCase();
  }
}
