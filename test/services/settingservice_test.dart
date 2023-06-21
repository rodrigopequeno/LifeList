import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/constants/consts.dart';
import 'package:lifelist/services/dbservice.dart';
import 'package:lifelist/services/settingservice.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/notify_listener_calls.dart';

class _MockDBService extends Mock implements DBService {}

void main() {
  late DBService mockDBService;
  late SettingsService settingsService;
  late NotifyListenerCalls notifyListenerCalls;

  setUp(() {
    dbService = mockDBService = _MockDBService();
    settingsService = SettingsService();
    notifyListenerCalls = NotifyListenerCalls(settingsService);
  });

  tearDown(() {
    dbService = DBService();
    notifyListenerCalls.dispose();
    settingsService.dispose();
  });

  test(
    'instance of ChangeNotifier',
    () {
      expect(settingsService, isA<ChangeNotifier>());
    },
  );

  group(
    'initial values',
    () {
      test(
        'should return initial value for settings service',
        () {
          expect(settingsService.loader, isFalse);
        },
      );
    },
  );

  group(
    'clearData',
    () {
      test(
        'should set loader to true, call clearGlobalData, set loader to false, and notify listeners',
        () async {
          when(() => mockDBService.clearGlobalData()).thenAnswer((_) async {});

          final future = settingsService.clearData();
          expect(settingsService.loader, isTrue);
          await future;
          expect(settingsService.loader, isFalse);
          verify(() => mockDBService.clearGlobalData()).called(1);
          notifyListenerCalls.called(1);
        },
      );
    },
  );
}
