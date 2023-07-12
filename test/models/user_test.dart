import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/models/user.dart';

void main() {
  test('instance of User', () {
    final user = User();
    expect(user, isA<User>());
  });

  test('should return null values in initial instance', () {
    final user = User();
    expect(user.firstName, isNull);
    expect(user.lastName, isNull);
    expect(user.age, isNull);
  });

  group('createUser', () {
    test(
      'should set firstName, lastName, and age',
      () {
        final user = User();
        user.createUser('firstName', 'lastName', 1);
        expect(user.firstName, 'firstName');
        expect(user.lastName, 'lastName');
        expect(user.age, 1);
      },
    );

    test(
      'should set empty parameters to null',
      () {
        final user = User();
        user.createUser('', '', 0);
        expect(user.firstName, '');
        expect(user.lastName, '');
        expect(user.age, 0);
      },
    );
  });
}
