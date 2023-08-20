import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:lifelist/models/index.dart';
import 'package:lifelist/services/dbservice.dart';

void main() {
  const libFileNames = ['libisar.dylib', 'libisar.so'];
  final methodCallLog = <MethodCall>[];
  late DBService dBService;
  late User mockUser;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  tearDownAll(() {
    for (final libFileName in libFileNames) {
      final file = File(libFileName);
      if (file.existsSync()) file.deleteSync();
    }
  });

  tearDown(() {
    methodCallLog.clear();
    dBService.isar.close(deleteFromDisk: true);
  });

  void mockPathProvider() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      methodCallLog.add(methodCall);
      return '';
    });
  }

  setUp(() async {
    dBService = DBService();
    mockPathProvider();
    await dBService.initIsar();
    mockUser = User()
      ..firstName = 'first name'
      ..lastName = 'last name'
      ..age = 1;
  });

  group('init', () {
    test('should initialize isar', () async {
      expect(dBService.isar, isA<Isar>());
      expect(methodCallLog, isNotEmpty);
    });
  });

  group('addUser', () {
    test('should return user id when add user', () async {
      final result = await dBService.addUser(mockUser);
      expect(result, isA<int>());
      expect(result, 1);
    });

    test('should return user id when add user with id', () async {
      mockUser.id = 2;

      final result = await dBService.addUser(mockUser);
      expect(result, isA<int>());
      expect(result, 2);
    });
  });

  group('isUserCreated', () {
    test('should return true when user is created', () async {
      await dBService.addUser(mockUser);
      final result = await dBService.isUserCreated();
      expect(result, isA<bool>());
      expect(result, true);
    });

    test('should return false when user is not created', () async {
      final result = await dBService.isUserCreated();
      expect(result, isA<bool>());
      expect(result, false);
    });
  });

  group('getBuckets', () {
    test('should return empty list when no buckets', () async {
      final result = await dBService.getBuckets();
      expect(result, isA<List<Bucket?>>());
      expect(result.length, 0);
    });

    test('should return list of buckets', () async {
      final bucket = Bucket()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isCompleted = false
        ..streak = 0;
      await dBService.addBucket(bucket);
      final result = await dBService.getBuckets();
      expect(result, isA<List<Bucket?>>());
      expect(result.length, 1);
      expect(result[0], isA<Bucket>());
      expect(result[0]!.name, 'name');
      expect(result[0]!.deadline, isA<DateTime>());
      expect(result[0]!.isCompleted, false);
      expect(result[0]!.streak, 0);
    });
  });

  group('addBucket', () {
    test('should return bucket id when add bucket', () async {
      final bucket = Bucket()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isCompleted = false
        ..streak = 0;
      final result = await dBService.addBucket(bucket);
      expect(result, isA<int>());
      expect(result, 1);
    });

    test('should return bucket id when add bucket with id', () async {
      final bucket = Bucket()
        ..id = 2
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isCompleted = false
        ..streak = 0;
      final result = await dBService.addBucket(bucket);
      expect(result, isA<int>());
      expect(result, 2);
    });
  });

  group('addTasks', () {
    test('should return task id when add task', () async {
      final task = Task()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isComplete = false;
      final result = await dBService.addTasks([task]);
      expect(result, isA<List<int>>());
      expect(result.first, 1);
    });

    test('should return tasks ids when add tasks', () async {
      final task1 = Task()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isComplete = false;
      final task2 = Task()
        ..id = 2
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isComplete = false;
      final result = await dBService.addTasks([task1, task2]);
      expect(result, isA<List<int>>());
      expect(result.first, 1);
      expect(result.last, 2);
    });
  });

  group('getTasks', () {
    test('should return list of tasks empty', () async {
      final result = await dBService.getTasks([1]);
      expect(result, isA<List<Task?>>());
      expect(result, [null]);
    });

    test('should return list of tasks', () async {
      final task = Task()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isComplete = false;
      await dBService.addTasks([task]);
      final result = await dBService.getTasks([1]);
      expect(result, isA<List<Task?>>());
      expect(result.length, 1);
      expect(result[0], isA<Task>());
      expect(result[0]!.name, 'name');
      expect(result[0]!.deadline, isA<DateTime>());
      expect(result[0]!.isComplete, false);
    });
  });

  group('deleteTasks', () {
    test('should return true when delete tasks', () async {
      final task = Task()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isComplete = false;
      final taskId = (await dBService.addTasks([task])).first;
      expect(taskId, 1);
      await dBService.deleteTasks([taskId]);
      final result = await dBService.getTasks([taskId]);
      expect(result.first, null);
    });

    test('should return false when delete tasks', () async {
      await dBService.deleteTasks([1]);
      final result = await dBService.getTasks([1]);
      expect(result, [null]);
    });
  });

  group('deleteSingleTask', () {
    test('should return true when delete task', () async {
      final task = Task()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isComplete = false;
      final taskId = (await dBService.addTasks([task])).first;
      expect(taskId, 1);
      await dBService.deleteSingleTask(taskId);
      final result = await dBService.getTasks([taskId]);
      expect(result.first, null);
    });

    test('should return false when delete task', () async {
      await dBService.deleteSingleTask(1);
      final result = await dBService.getTasks([1]);
      expect(result, [null]);
    });
  });

  group('deleteTasksfromDB', () {
    test('should return true when delete tasks', () async {
      final task = Task()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isComplete = false;
      final taskId = (await dBService.addTasks([task])).first;
      final bucket = Bucket()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isCompleted = false
        ..streak = 0
        ..tasks = [1];
      final bucketId = await dBService.addBucket(bucket);
      await dBService.deleteTasksfromDB(bucketId, taskId);
      final resultBuckets = await dBService.getBuckets();
      expect(resultBuckets.first?.tasks, isEmpty);
    });

    test('should return false when delete tasks', () async {
      await dBService.deleteTasksfromDB(1, 1);
      final result = await dBService.getTasks([1]);
      expect(result, [null]);
    });
  });

  group('deleteSingleBucket', () {
    test('should return true when delete bucket', () async {
      final bucket = Bucket()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isCompleted = false
        ..streak = 0;
      final bucketId = await dBService.addBucket(bucket);
      await dBService.deleteSingleBucket(bucketId);
      final result = await dBService.getBuckets();
      expect(result, isEmpty);
    });

    test('should return false when delete bucket', () async {
      await dBService.deleteSingleBucket(1);
      final result = await dBService.getBuckets();
      expect(result, isEmpty);
    });
  });

  group('editBucketInDB', () {
    test('should change name when edit bucket', () async {
      final bucket = Bucket()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isCompleted = false
        ..streak = 0;
      final bucketId = await dBService.addBucket(bucket);
      final bucket2 = Bucket()
        ..id = bucketId
        ..name = 'name2'
        ..deadline = DateTime.now()
        ..isCompleted = false
        ..streak = 0;
      await dBService.editBucketInDB(bucket2);
      final result = await dBService.getBuckets();
      expect(result.first?.name, 'name2');
    });

    test('should return isEmpty when no bucket in db', () async {
      final bucket = Bucket()
        ..id = 1
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isCompleted = false
        ..streak = 0;
      await dBService.editBucketInDB(bucket);
      final result = await dBService.getBuckets();
      expect(result, isEmpty);
    });
  });

  group('getUserFromDB', () {
    test('should return user when user in db', () async {
      final user = User()..firstName = 'name';
      await dBService.addUser(user);
      final result = await dBService.getUserFromDB();
      expect(result, isA<User>());
      expect(result.firstName, 'name');
    });

    test('should return null when no user in db', () async {
      final result = await dBService.getUserFromDB();
      expect(
        result,
        isA<User>()
            .having((user) => user.firstName, 'First Name is null', isNull)
            .having(
              (user) => user.lastName,
              'Last Name is null',
              isNull,
            )
            .having(
              (user) => user.age,
              'Age is null',
              isNull,
            ),
      );
    });
  });

  group('clearGlobalData', () {
    test('should clear global data', () async {
      final bucket = Bucket()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isCompleted = false
        ..streak = 0;
      await dBService.addBucket(bucket);
      final task = Task()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isComplete = false;
      final taskId = (await dBService.addTasks([task])).first;
      await dBService.clearGlobalData();
      final resultBuckets = await dBService.getBuckets();
      final resultTasks = await dBService.getTasks([taskId]);
      expect(resultBuckets, isEmpty);
      expect(resultTasks.first, null);
    });
  });

  group('updateTaskInDB', () {
    test('should update task', () async {
      final task = Task()
        ..name = 'name'
        ..deadline = DateTime.now()
        ..isComplete = false;
      final taskId = (await dBService.addTasks([task])).first;
      final task2 = Task()
        ..id = taskId
        ..name = 'name2'
        ..deadline = DateTime.now()
        ..isComplete = false;
      await dBService.updateTaskInDB(task2);
      final result = await dBService.getTasks([taskId]);
      expect(result.first?.name, 'name2');
    });
  });
}
