/// Deterministic extractive starter summary; not a generative AI model.
String buildPreliminarySummary(String input) {
  final sentences = input.replaceAll('\\n', ' ').split(RegExp(r'(?<=[.!?؟])\\s+')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  if (sentences.isEmpty) return 'أضف نصًا أولًا لإنشاء ملخص أولي.';
  return 'ملخص أولي (غير مولّد بالذكاء الاصطناعي):\\n' + sentences.take(3).map((s) => '• $s').join('\\n');
}
String speechLocaleFor(String language) => switch (language) { 'ar' => 'ar', 'fr' => 'fr_FR', _ => 'en_US' };
