import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/constants/consts.dart';
import 'package:lifelist/models/bucket.dart';
import 'package:lifelist/services/dbservice.dart';
import 'package:lifelist/services/filterservice.dart';

import '../helpers/notify_listener_calls.dart';

void main() {
  late FilterService filterService;
  late NotifyListenerCalls notifyListenerCalls;

  setUp(() {
    filterService = FilterService();
    notifyListenerCalls = NotifyListenerCalls(filterService);
  });

  tearDown(() {
    dbService = DBService();
    notifyListenerCalls.dispose();
    filterService.dispose();
  });

  test(
    'instance of ChangeNotifier',
    () {
      expect(filterService, isA<ChangeNotifier>());
    },
  );

  group(
    'initial values',
    () {
      test(
        'should return initial value for filter service',
        () {
          expect(filterService.currentStatus, isFalse);
          expect(filterService.currentCategories, isEmpty);
        },
      );
    },
  );

  group(
    'toggleStatus',
    () {
      test(
        'should toggle status',
        () async {
          expect(filterService.currentStatus, isFalse);
          filterService.toggleStatus(true);
          expect(filterService.currentStatus, isTrue);
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'toggleCategory',
    () {
      test(
        'should add category',
        () async {
          expect(filterService.currentCategories, isEmpty);
          filterService.toggleCategory(BucketCategory.adventure);
          expect(filterService.currentCategories, isNotEmpty);
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should remove category',
        () async {
          filterService.currentCategories = [BucketCategory.adventure];
          filterService.toggleCategory(BucketCategory.adventure);
          expect(filterService.currentCategories, isEmpty);
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'resetFilters',
    () {
      test(
        'should reset filters',
        () async {
          filterService.currentStatus = true;
          filterService.currentCategories = [BucketCategory.adventure];
          filterService.resetFilters();
          expect(filterService.currentStatus, isFalse);
          expect(filterService.currentCategories, isEmpty);
          notifyListenerCalls.called(1);
        },
      );
    },
  );
}
