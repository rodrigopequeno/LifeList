import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/constants/index.dart';
import 'package:lifelist/models/bucket.dart';
import 'package:lifelist/services/bucketlistservice.dart';
import 'package:lifelist/services/dbservice.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/notify_listener_calls.dart';

class _MockDBService extends Mock implements DBService {}

void main() {
  late DBService mockDBService;
  late BucketListService bucketListService;
  late NotifyListenerCalls notifyListenerCalls;

  setUp(() {
    dbService = mockDBService = _MockDBService();
    bucketListService = BucketListService();
    notifyListenerCalls = NotifyListenerCalls(bucketListService);
  });

  tearDown(() {
    dbService = DBService();
    notifyListenerCalls.dispose();
    bucketListService.dispose();
  });

  test(
    'instance of ChangeNotifier',
    () {
      expect(bucketListService, isA<ChangeNotifier>());
    },
  );

  group(
    'initial values',
    () {
      test(
        'should return initial value for buckets list service',
        () {
          expect(bucketListService.buckets, isEmpty);
          expect(bucketListService.filteredBuckets, isEmpty);
          expect(bucketListService.currentAction, equals(0));
          expect(bucketListService.selectedScope, equals(BucketScope.all));
          expect(bucketListService.isScopeSelected, isFalse);
        },
      );
    },
  );

  group(
    'getAllBuckets',
    () {
      test(
        'should assign the list of buckets when contains value in database',
        () async {
          when(() => mockDBService.getBuckets()).thenAnswer(
            (_) async => [
              Bucket(),
            ],
          );

          await bucketListService.getAllBuckets();
          expect(bucketListService.buckets, isNotEmpty);
          expect(bucketListService.filteredBuckets, isNotEmpty);
          verify(() => mockDBService.getBuckets()).called(1);
          verifyNoMoreInteractions(mockDBService);
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should only measure time left and sort list when currentAction different than 0',
        () async {
          when(() => mockDBService.getBuckets()).thenAnswer(
            (_) async => [Bucket()],
          );

          bucketListService.currentAction = 1;
          await bucketListService.getAllBuckets();
          expect(bucketListService.buckets, isEmpty);
          expect(bucketListService.filteredBuckets, isEmpty);
          verifyNever(() => mockDBService.getBuckets());
          verifyZeroInteractions(mockDBService);
          notifyListenerCalls.called(0);
        },
      );
    },
  );

  group(
    'sortBuckets',
    () {
      test(
        'should sort the list of buckets',
        () {
          final bucket1 = Bucket()
            ..id = 1
            ..bucketScope = BucketScope.daily
            ..isCompleted = false;
          final bucket2 = Bucket()
            ..id = 2
            ..bucketScope = BucketScope.onetime
            ..isCompleted = false;
          final bucket3 = Bucket()
            ..id = 3
            ..bucketScope = BucketScope.daily
            ..isCompleted = true;
          final bucket4 = Bucket()
            ..id = 4
            ..bucketScope = BucketScope.onetime
            ..isCompleted = true;
          bucketListService.filteredBuckets = [
            bucket1,
            bucket2,
            bucket3,
            bucket4,
          ];

          bucketListService.sortBuckets(bucketListService.filteredBuckets);
          expect(bucketListService.filteredBuckets[0]?.id, bucket1.id);
          expect(bucketListService.filteredBuckets[1]?.id, bucket2.id);
          expect(bucketListService.filteredBuckets[2]?.id, bucket4.id);
          expect(bucketListService.filteredBuckets[3]?.id, bucket3.id);
        },
      );
    },
  );

  group(
    'measureTimeLeft',
    () {
      test(
        'should update time left',
        () async {
          final allBucket = [
            Bucket()
              ..id = 1
              ..bucketScope = BucketScope.daily
              ..isCompleted = true
              ..timeLeft = '',
            Bucket()
              ..id = 2
              ..bucketScope = BucketScope.onetime
              ..deadline = DateTime.now().subtract(const Duration(days: 1))
              ..isCompleted = false
              ..timeLeft = '',
            Bucket()
              ..id = 3
              ..bucketScope = BucketScope.onetime
              ..deadline = DateTime.now().add(const Duration(days: 1))
              ..isCompleted = false
              ..timeLeft = '',
            Bucket()
              ..id = 4
              ..bucketScope = BucketScope.daily
              ..deadline = DateTime.now().add(const Duration(days: 2))
              ..isCompleted = false
              ..timeLeft = '',
            Bucket()
              ..id = 5
              ..bucketScope = BucketScope.daily
              ..deadline = DateTime.now().add(const Duration(hours: 10))
              ..isCompleted = false
              ..timeLeft = '',
          ];
          bucketListService.filteredBuckets = allBucket;

          await bucketListService.measureTimeLeft();
          for (final bucket in bucketListService.filteredBuckets) {
            expect(bucket?.timeLeft, isNotEmpty);
          }
        },
      );
    },
  );

  group(
    'deleteBucket',
    () {
      test(
        'should delete the bucket from the list of buckets',
        () async {
          when(() => mockDBService.deleteSingleBucket(any())).thenAnswer(
            (_) async {},
          );

          final bucket1 = Bucket()
            ..id = 1
            ..bucketScope = BucketScope.daily
            ..isCompleted = false;
          final bucket2 = Bucket()
            ..id = 2
            ..bucketScope = BucketScope.onetime
            ..isCompleted = false;

          bucketListService.filteredBuckets = [
            bucket1,
            bucket2,
          ];

          await bucketListService.deleteBucket(bucket1);
          expect(bucketListService.buckets, isNot(contains(bucket1)));
          verify(() => mockDBService.deleteSingleBucket(bucket1.id)).called(1);
          verifyNoMoreInteractions(mockDBService);
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'toggleAction',
    () {
      test(
        'should toggle the action to 1 when current action is 0',
        () {
          bucketListService.toggleAction();
          expect(bucketListService.currentAction, equals(1));
        },
      );

      test(
        'should toggle the action to 0 when current action is 1',
        () {
          bucketListService.currentAction = 1;
          bucketListService.toggleAction();
          expect(bucketListService.currentAction, equals(0));
        },
      );
    },
  );

  group(
    'resetFilter',
    () {
      test(
        'should reset the filter',
        () {
          final allBucket = [
            Bucket()
              ..id = 1
              ..bucketScope = BucketScope.daily
              ..isCompleted = false,
            Bucket()
              ..id = 2
              ..bucketScope = BucketScope.onetime
              ..isCompleted = false,
          ];
          bucketListService.buckets = allBucket;
          bucketListService.resetFilter();
          expect(bucketListService.filteredBuckets, isNotEmpty);
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'filterBuckets',
    () {
      test(
        'should filter the list of buckets by category',
        () {
          final allBucket = [
            Bucket()
              ..id = 1
              ..bucketScope = BucketScope.daily
              ..bucketCategory = BucketCategory.adventure
              ..isCompleted = false,
            Bucket()
              ..id = 2
              ..bucketScope = BucketScope.onetime
              ..bucketCategory = BucketCategory.career
              ..isCompleted = false,
          ];
          bucketListService.buckets = allBucket;
          bucketListService.filterBuckets([BucketCategory.adventure], false);
          expect(bucketListService.filteredBuckets, isNotEmpty);
          expect(bucketListService.filteredBuckets.length, equals(1));
          expect(bucketListService.filteredBuckets.first?.id, equals(1));
          expect(bucketListService.currentAction, equals(1));
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should filter the list of buckets by status',
        () {
          final allBucket = [
            Bucket()
              ..id = 1
              ..bucketScope = BucketScope.daily
              ..bucketCategory = BucketCategory.adventure
              ..isCompleted = false,
            Bucket()
              ..id = 2
              ..bucketScope = BucketScope.onetime
              ..bucketCategory = BucketCategory.career
              ..isCompleted = true,
          ];
          bucketListService.buckets = allBucket;
          bucketListService.filterBuckets([], true);
          expect(bucketListService.filteredBuckets, isNotEmpty);
          expect(bucketListService.filteredBuckets.length, equals(1));
          expect(bucketListService.filteredBuckets.first?.id, equals(2));
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'toggleScope',
    () {
      test(
        'should same scope when parameter is null',
        () {
          expect(bucketListService.selectedScope, equals(BucketScope.all));
          bucketListService.toggleScope(null);
          expect(bucketListService.selectedScope, equals(BucketScope.all));
          expect(bucketListService.isScopeSelected, isFalse);
          notifyListenerCalls.called(0);
        },
      );

      test(
        'should toggle the scope to daily when current scope is all',
        () {
          expect(bucketListService.selectedScope, equals(BucketScope.all));
          bucketListService.toggleScope(BucketScope.daily);
          expect(bucketListService.selectedScope, equals(BucketScope.daily));
          expect(bucketListService.isScopeSelected, isTrue);
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should toggle the scope to onetime when current scope is all',
        () {
          expect(bucketListService.selectedScope, equals(BucketScope.all));
          bucketListService.toggleScope(BucketScope.onetime);
          expect(bucketListService.selectedScope, equals(BucketScope.onetime));
          expect(bucketListService.isScopeSelected, isTrue);
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should toggle the scope to all when current scope is daily',
        () {
          bucketListService.selectedScope = BucketScope.daily;
          bucketListService.toggleScope(BucketScope.all);
          expect(bucketListService.selectedScope, equals(BucketScope.all));
          expect(bucketListService.isScopeSelected, isFalse);
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'fetchBucketsByScope',
    () {
      test(
        'should fetch the list of buckets by scope when scope not selected',
        () async {
          final allBucket = [
            Bucket()
              ..id = 1
              ..bucketScope = BucketScope.daily
              ..bucketCategory = BucketCategory.adventure
              ..isCompleted = false,
            Bucket()
              ..id = 2
              ..bucketScope = BucketScope.onetime
              ..bucketCategory = BucketCategory.career
              ..isCompleted = true,
          ];
          bucketListService.buckets = allBucket;
          expect(bucketListService.buckets, isNotEmpty);
          expect(bucketListService.filteredBuckets, isEmpty);
          await bucketListService.fetchBucketsByScope();
          expect(bucketListService.filteredBuckets, isNotEmpty);
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should fetch the list of buckets by scope when scope selected',
        () async {
          final allBucket = [
            Bucket()
              ..id = 1
              ..bucketScope = BucketScope.daily
              ..bucketCategory = BucketCategory.adventure
              ..isCompleted = false,
            Bucket()
              ..id = 2
              ..bucketScope = BucketScope.onetime
              ..bucketCategory = BucketCategory.career
              ..isCompleted = true,
          ];
          bucketListService.buckets = allBucket;
          bucketListService.selectedScope = BucketScope.daily;
          bucketListService.isScopeSelected = true;
          await bucketListService.fetchBucketsByScope();
          expect(bucketListService.filteredBuckets, isNotEmpty);
          expect(bucketListService.filteredBuckets.length, equals(1));
          expect(bucketListService.filteredBuckets.first?.id, equals(1));
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'resetScopeFilter',
    () {
      test(
        'should reset the scope filter',
        () {
          final allBucket = [
            Bucket()
              ..id = 1
              ..bucketScope = BucketScope.daily
              ..bucketCategory = BucketCategory.adventure
              ..isCompleted = false,
            Bucket()
              ..id = 2
              ..bucketScope = BucketScope.onetime
              ..bucketCategory = BucketCategory.career
              ..isCompleted = true,
          ];
          bucketListService.buckets = allBucket;
          bucketListService.selectedScope = BucketScope.daily;
          bucketListService.isScopeSelected = true;
          bucketListService.resetScopeFilter();
          expect(bucketListService.selectedScope, BucketScope.all);
          expect(bucketListService.isScopeSelected, isFalse);
          expect(bucketListService.filteredBuckets, isNotEmpty);
          expect(bucketListService.filteredBuckets.length, equals(2));
          notifyListenerCalls.called(1);
        },
      );
    },
  );
}
