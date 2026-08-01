extension DigitsExtension on String {
  String normalizeDigits() {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const english = '0123456789';

    var result = this;

    for (var i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }

    return result;
  }
}
