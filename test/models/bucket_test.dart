import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/models/index.dart';

void main() {
  test('instance of Bucket', () {
    final bucket = Bucket();
    expect(bucket, isA<Bucket>());
  });

  group('compareTo', () {
    test('should return 0 if the deadlines are the same', () {
      final bucket1 = Bucket()..deadline = DateTime(2021, 1, 1);
      final bucket2 = Bucket()..deadline = DateTime(2021, 1, 1);
      final result = bucket1.compareTo(bucket2);
      expect(result, 0);
    });

    test('should return 1 if the first deadline is after the second', () {
      final bucket1 = Bucket()..deadline = DateTime(2021, 1, 2);
      final bucket2 = Bucket()..deadline = DateTime(2021, 1, 1);
      final result = bucket1.compareTo(bucket2);
      expect(result, 1);
    });

    test('should return -1 if the first deadline is before the second', () {
      final bucket1 = Bucket()..deadline = DateTime(2021, 1, 1);
      final bucket2 = Bucket()..deadline = DateTime(2021, 1, 2);
      final result = bucket1.compareTo(bucket2);
      expect(result, -1);
    });
  });
}
