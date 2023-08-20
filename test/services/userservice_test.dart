import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/constants/consts.dart';
import 'package:lifelist/models/user.dart';
import 'package:lifelist/services/dbservice.dart';
import 'package:lifelist/services/firebaseservice.dart';
import 'package:lifelist/services/userservice.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/notify_listener_calls.dart';

class _MockDBService extends Mock implements DBService {}

class _MockFirebaseService extends Mock implements FirebaseService {}

void main() {
  late DBService mockDBService;
  late FirebaseService mockFirebaseService;
  late UserService userService;
  late NotifyListenerCalls notifyListenerCalls;

  setUp(() {
    dbService = mockDBService = _MockDBService();
    firebaseService = mockFirebaseService = _MockFirebaseService();
    userService = UserService();
    notifyListenerCalls = NotifyListenerCalls(userService);
  });

  tearDown(() {
    dbService = DBService();
    notifyListenerCalls.dispose();
    userService.dispose();
  });

  test(
    'instance of ChangeNotifier',
    () {
      expect(userService, isA<ChangeNotifier>());
    },
  );

  group(
    'initial values',
    () {
      test(
        'should return initial value for user service',
        () {
          expect(userService.user, isA<User>());
          expect(userService.doNotShowSyncPopup, isTrue);
        },
      );
    },
  );

  group(
    'setUser',
    () {
      test(
        'should set user',
        () {
          final user = User()
            ..id = 1
            ..firstName = 'John'
            ..lastName = 'Doe'
            ..age = 30;
          userService.setUser(user);
          expect(userService.user.id, 1);
          expect(userService.user.firstName, 'John');
          expect(userService.user.lastName, 'Doe');
          expect(userService.user.age, 30);
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'getUser',
    () {
      test(
        'should get user from db and set doNotShowSyncPopup to true if user exists',
        () async {
          final user = User()
            ..id = 1
            ..firstName = 'John'
            ..lastName = 'Doe'
            ..age = 30;
          when(() => mockDBService.getUserFromDB())
              .thenAnswer((_) async => user);
          when(() => mockFirebaseService.checkIfUserExists(any()))
              .thenAnswer((_) async => true);
          await userService.getUser();
          expect(userService.user.id, 1);
          expect(userService.user.firstName, 'John');
          expect(userService.user.lastName, 'Doe');
          expect(userService.user.age, 30);
          expect(userService.doNotShowSyncPopup, isTrue);
          notifyListenerCalls.called(1);
          verify(() => mockDBService.getUserFromDB()).called(1);
          verify(() => mockFirebaseService.checkIfUserExists('JohnDoe30'))
              .called(1);
          verifyNoMoreInteractions(mockDBService);
          verifyNoMoreInteractions(mockFirebaseService);
        },
      );

      test(
        'should get user from db and set doNotShowSyncPopup to false if user does not exist',
        () async {
          final user = User()
            ..id = 1
            ..firstName = 'John'
            ..lastName = 'Doe'
            ..age = 30;
          when(() => mockDBService.getUserFromDB())
              .thenAnswer((_) async => user);
          when(() => mockFirebaseService.checkIfUserExists(any()))
              .thenAnswer((_) async => false);
          await userService.getUser();
          expect(userService.user.id, 1);
          expect(userService.user.firstName, 'John');
          expect(userService.user.lastName, 'Doe');
          expect(userService.user.age, 30);
          expect(userService.doNotShowSyncPopup, isFalse);
          notifyListenerCalls.called(1);
          verify(() => mockDBService.getUserFromDB()).called(1);
          verify(() => mockFirebaseService.checkIfUserExists('JohnDoe30'))
              .called(1);
          verifyNoMoreInteractions(mockDBService);
          verifyNoMoreInteractions(mockFirebaseService);
        },
      );

      test(
        'should same equals when not logged in',
        () async {
          final user = User()..id = -1;
          when(() => mockDBService.getUserFromDB())
              .thenAnswer((_) async => user);
          when(() => mockFirebaseService.checkIfUserExists(any()))
              .thenAnswer((_) async => false);
          await userService.getUser();
          expect(userService.user.id, -1);
          notifyListenerCalls.called(0);
          verify(() => mockDBService.getUserFromDB()).called(1);
          verifyNever(() => mockFirebaseService.checkIfUserExists(any()));
          verifyNoMoreInteractions(mockDBService);
          verifyNoMoreInteractions(mockFirebaseService);
        },
      );
    },
  );

  group(
    'syncAccount',
    () {
      test(
        'should toggle doNotShowSyncPopup',
        () {
          expect(userService.doNotShowSyncPopup, isTrue);
          userService.syncAccount();
          expect(userService.doNotShowSyncPopup, isFalse);
          userService.syncAccount();
          expect(userService.doNotShowSyncPopup, isTrue);
        },
      );
    },
  );
}
