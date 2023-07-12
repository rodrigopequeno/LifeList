import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/services/bottombarservice.dart';

import '../helpers/notify_listener_calls.dart';

void main() {
  test(
    'instance of ChangeNotifier',
    () {
      final bottomBarService = BottomBarService();
      expect(bottomBarService, isA<ChangeNotifier>());
    },
  );

  group(
    'currentIndex',
    () {
      test(
        'should return 0 as initial value',
        () {
          final bottomBarService = BottomBarService();
          expect(bottomBarService.currentIndex, equals(0));
        },
      );
    },
  );

  group(
    'changeIndex',
    () {
      test(
        'should be keep the same when invoke changeIndex with negative parameter',
        () async {
          final bottomBarService = BottomBarService();
          final notifyListenerCalls = NotifyListenerCalls(bottomBarService);
          expect(bottomBarService.currentIndex, equals(0));
          bottomBarService.changeIndex(-1);
          expect(bottomBarService.currentIndex, equals(0));
          notifyListenerCalls.called(0);
        },
      );

      test(
        'should be keep the same when invoke changeIndex with parameter equals currentIndex',
        () async {
          final bottomBarService = BottomBarService();
          final notifyListenerCalls = NotifyListenerCalls(bottomBarService);
          expect(bottomBarService.currentIndex, equals(0));
          bottomBarService.changeIndex(0);
          expect(bottomBarService.currentIndex, equals(0));
          notifyListenerCalls.called(0);
        },
      );

      test(
        'should change index to 1 when invoke changeIndex',
        () async {
          final bottomBarService = BottomBarService();
          final notifyListenerCalls = NotifyListenerCalls(bottomBarService);
          expect(bottomBarService.currentIndex, equals(0));
          bottomBarService.changeIndex(1);
          expect(bottomBarService.currentIndex, equals(1));
          notifyListenerCalls.called(1);
        },
      );
    },
  );
}
