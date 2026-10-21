import 'package:flutter_test/flutter_test.dart';
import 'package:diwwan/src/summary.dart';
void main() {
 test('empty text returns prompt', () => expect(buildPreliminarySummary(''), contains('أضف نصًا')));
 test('summary keeps at most three sentences', () { final s=buildPreliminarySummary('One. Two. Three. Four.'); expect(s, contains('Three.')); expect(s, isNot(contains('Four.'))); });
 test('speech locale mapping', () { expect(speechLocaleFor('ar'),'ar'); expect(speechLocaleFor('fr'),'fr_FR'); expect(speechLocaleFor('en'),'en_US'); });
}
