import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/extensions/string_extensions.dart';

void main() {
  group('capitalize', () {
    test(
      'should capitalize the first letter of a string',
      () {
        const testString = 'hello';
        const expectedString = 'Hello';
        final actualString = testString.capitalize();
        expect(actualString, expectedString);
      },
    );

    test(
      'should return the same string if it is empty',
      () {
        const testString = '';
        final actualString = testString.capitalize();
        expect(actualString, isEmpty);
      },
    );

    test(
      'should return the same string if it is null',
      () {
        const String? testString = null;
        final actualString = testString?.capitalize();
        expect(actualString, isNull);
      },
    );

    test(
      'should return the same string if it is a single character',
      () {
        const testString = 'a';
        const expectedString = 'A';
        final actualString = testString.capitalize();
        expect(actualString, expectedString);
      },
    );
  });
}
