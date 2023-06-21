import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/constants/consts.dart';
import 'package:lifelist/models/index.dart';
import 'package:lifelist/services/index.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/notify_listener_calls.dart';

class _MockDBService extends Mock implements DBService {}

class _FakeTask extends Fake implements Task {}

void main() {
  late DBService mockDBService;
  late TaskService taskService;
  late NotifyListenerCalls notifyListenerCalls;

  setUp(() {
    dbService = mockDBService = _MockDBService();
    taskService = TaskService();
    notifyListenerCalls = NotifyListenerCalls(taskService);
  });

  setUpAll(() {
    registerFallbackValue(_FakeTask());
  });

  tearDown(() {
    dbService = DBService();
    firebaseService = FirebaseService();
    notifyListenerCalls.dispose();
    taskService.dispose();
  });

  test(
    'instance of ChangeNotifier',
    () {
      expect(taskService, isA<ChangeNotifier>());
    },
  );

  group(
    'initial values',
    () {
      test(
        'should return initial value for task service',
        () {
          expect(taskService.tasks, isEmpty);
          expect(taskService.temporaryTasks, isEmpty);
          expect(taskService.completionPercentage, equals(0));
          expect(taskService.fetchStatus, equals(0));
        },
      );
    },
  );

  group(
    'addTaskstoDB',
    () {
      test(
        'should add tasks to db and return ids',
        () async {
          when(() => mockDBService.addTasks(any()))
              .thenAnswer((_) async => [1]);

          final tasks = [
            Task()
              ..name = 'name'
              ..priority = Priority.high
              ..description = 'description'
              ..deadline = DateTime.utc(2023)
              ..isComplete = false
              ..bucketId = -1
          ];
          final result = await taskService.addTaskstoDB(tasks);
          expect(result, equals([1]));
        },
      );
    },
  );

  group(
    'transferTemporaryTasks',
    () {
      test(
        'should add tasks to db and return ids',
        () async {
          final tasks = [
            Task()
              ..name = 'name'
              ..priority = Priority.high
              ..description = 'description'
              ..deadline = DateTime.utc(2023)
              ..isComplete = false
              ..bucketId = -1
          ];

          taskService.temporaryTasks = tasks;
          await taskService.transferTemporaryTasks();
          expect(taskService.tasks, isNotEmpty);
          expect(taskService.temporaryTasks, isEmpty);
          expect(taskService.fetchStatus, 1);
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'fetchActiveBucketTaskDetails',
    () {
      test(
        'should fetch tasks activated',
        () async {
          final tasks = [
            Task()
              ..id = 1
              ..name = 'name'
              ..priority = Priority.high
              ..description = 'description'
              ..deadline = DateTime.utc(2023)
              ..isComplete = false
              ..bucketId = -1,
            Task()
              ..id = 2
              ..name = 'name'
              ..priority = Priority.medium
              ..description = 'description'
              ..deadline = DateTime.utc(2023)
              ..isComplete = true
              ..bucketId = -1
          ];
          when(() => mockDBService.getTasks(any()))
              .thenAnswer((_) async => tasks);

          await taskService.fetchActiveBucketTaskDetails([1], Bucket());
          expect(taskService.tasks, isNotEmpty);
          expect(taskService.completionPercentage, equals(50));
        },
      );
    },
  );

  group(
    'deleteSingleTask',
    () {
      test(
        'should delete task by taskId',
        () async {
          final tasks = [
            Task()
              ..id = 1
              ..name = 'name'
              ..priority = Priority.high
              ..description = 'description'
              ..deadline = DateTime.utc(2023)
              ..isComplete = false
              ..bucketId = -1,
            Task()
              ..id = 2
              ..name = 'name2'
              ..priority = Priority.medium
              ..description = 'description2'
              ..deadline = DateTime.utc(2023)
              ..isComplete = true
              ..bucketId = -1
          ];
          when(() => mockDBService.deleteSingleTask(any()))
              .thenAnswer((_) async {});
          taskService.tasks = tasks;
          await taskService.deleteSingleTask(2, 'name');
          expect(taskService.tasks, isNotEmpty);
          expect(taskService.completionPercentage, equals(50));
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should delete task by only name',
        () async {
          final tasks = [
            Task()
              ..name = 'name'
              ..priority = Priority.high
              ..description = 'description'
              ..deadline = DateTime.utc(2023)
              ..isComplete = false
              ..bucketId = -1,
            Task()
              ..id = 2
              ..name = 'name2'
              ..priority = Priority.medium
              ..description = 'description2'
              ..deadline = DateTime.utc(2023)
              ..isComplete = true
              ..bucketId = -1
          ];
          when(() => mockDBService.deleteSingleTask(any()))
              .thenAnswer((_) async {});
          taskService.tasks = tasks;
          await taskService.deleteSingleTask(null, 'name');
          expect(taskService.tasks, isNotEmpty);
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'deleteSingleTemporaryTask',
    () {
      test(
        'should delete temporary task',
        () async {
          final tasks = [
            Task()
              ..id = 1
              ..name = 'name'
              ..priority = Priority.high
              ..description = 'description'
              ..deadline = DateTime.utc(2023)
              ..isComplete = false
              ..bucketId = -1,
            Task()
              ..id = 2
              ..name = 'name2'
              ..priority = Priority.medium
              ..description = 'description2'
              ..deadline = DateTime.utc(2023)
              ..isComplete = true
              ..bucketId = -1
          ];
          taskService.tasks = tasks;
          taskService.deleteSingleTemporaryTask(2);
          expect(taskService.tasks, isNotEmpty);
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should remain the same when taskId is null',
        () async {
          final tasks = [
            Task()
              ..name = 'name'
              ..priority = Priority.high
              ..description = 'description'
              ..deadline = DateTime.utc(2023)
              ..isComplete = false
              ..bucketId = -1,
            Task()
              ..id = 2
              ..name = 'name2'
              ..priority = Priority.medium
              ..description = 'description2'
              ..deadline = DateTime.utc(2023)
              ..isComplete = true
              ..bucketId = -1
          ];

          taskService.tasks = tasks;
          taskService.deleteSingleTemporaryTask(null);
          expect(taskService.tasks, isNotEmpty);
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should remain the same when taskId not found',
        () async {
          final tasks = [
            Task()
              ..name = 'name'
              ..priority = Priority.high
              ..description = 'description'
              ..deadline = DateTime.utc(2023)
              ..isComplete = false
              ..bucketId = -1,
            Task()
              ..id = 2
              ..name = 'name2'
              ..priority = Priority.medium
              ..description = 'description2'
              ..deadline = DateTime.utc(2023)
              ..isComplete = true
              ..bucketId = -1
          ];

          taskService.tasks = tasks;
          taskService.deleteSingleTemporaryTask(-1);
          expect(taskService.tasks, isNotEmpty);
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'addSingleTemporaryTask',
    () {
      test(
        'should add single temporary task',
        () async {
          taskService.addSingleTemporaryTask('title task');
          expect(taskService.temporaryTasks, isNotEmpty);
          expect(taskService.temporaryTasks.first.name, equals('title task'));
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should add single temporary task when title is empty',
        () async {
          taskService.addSingleTemporaryTask('');
          expect(taskService.temporaryTasks, isNotEmpty);
          expect(taskService.temporaryTasks.first.name, equals(''));
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'updateSingleTask',
    () {
      test(
        'should update single task when task id is null',
        () async {
          final tasks = [
            Task()
              ..name = 'name'
              ..priority = Priority.high
              ..description = 'description'
              ..deadline = DateTime.utc(2023)
              ..isComplete = false
              ..bucketId = -1
          ];
          taskService.tasks = tasks;
          expect(taskService.tasks.first?.isComplete, isFalse);
          await taskService.updateSingleTask(Task()..name = 'name');
          expect(taskService.tasks.first?.isComplete, isTrue);
          expect(taskService.completionPercentage, equals(100));
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should update single task when task id is not null',
        () async {
          when(() => mockDBService.updateTaskInDB(any()))
              .thenAnswer((_) async {});
          final tasks = [
            Task()
              ..id = 1
              ..name = 'name'
              ..priority = Priority.high
              ..description = 'description'
              ..deadline = DateTime.utc(2023)
              ..isComplete = false
              ..bucketId = -1
          ];
          taskService.tasks = tasks;
          expect(taskService.tasks.first?.isComplete, isFalse);
          await taskService.updateSingleTask(Task()..id = 1);
          expect(taskService.tasks.first?.isComplete, isTrue);
          expect(taskService.completionPercentage, equals(100));
          notifyListenerCalls.called(1);
          verify(() => mockDBService.updateTaskInDB(any())).called(1);
        },
      );
    },
  );

  group(
    'toggleFetchStatus',
    () {
      test(
        'should toggle fetch status to 0',
        () async {
          taskService.fetchStatus = 1;
          taskService.toggleFetchStatus();
          expect(taskService.fetchStatus, equals(0));
        },
      );
    },
  );
}
