import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/models/user.dart';

void main() {
  test('instance of User', () {
    final user = User();
    expect(user, isA<User>());
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
  });
}
