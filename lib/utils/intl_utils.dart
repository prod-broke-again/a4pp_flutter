/// Русская морфология числительных: универсальная функция склонения
/// Передавайте три формы слова: [one, few, many]
/// Примеры:
/// - pluralizeRu(1, ['занятие','занятия','занятий']) => 'занятие'
/// - pluralizeRu(2, ['занятие','занятия','занятий']) => 'занятия'
/// - pluralizeRu(5, ['занятие','занятия','занятий']) => 'занятий'
String pluralizeRu(int number, List<String> forms) {
  if (forms.length != 3) {
    throw ArgumentError('forms must contain exactly 3 items: [one, few, many]');
  }

  final n = number.abs();
  final n10 = n % 10;
  final n100 = n % 100;

  if (n10 == 1 && n100 != 11) {
    return forms[0]; // one
  }
  if (n10 >= 2 && n10 <= 4 && (n100 < 12 || n100 > 14)) {
    return forms[1]; // few
  }
  return forms[2]; // many
}

/// Удобный помощник для склейки числа и слова в нужной форме
String formatCountRu(int number, List<String> forms, {String separator = ' '}) {
  return '$number$separator${pluralizeRu(number, forms)}';
}


