import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/constants/index.dart';
import 'package:lifelist/models/index.dart';
import 'package:lifelist/models/template.dart';
import 'package:lifelist/services/index.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/notify_listener_calls.dart';

class _MockFirebaseService extends Mock implements FirebaseService {}

void main() {
  late FirebaseService mockFirebaseService;
  late ExploreService exploreService;
  late NotifyListenerCalls notifyListenerCalls;

  setUp(() {
    firebaseService = mockFirebaseService = _MockFirebaseService();
    exploreService = ExploreService();
    notifyListenerCalls = NotifyListenerCalls(exploreService);
  });

  tearDown(() {
    dbService = DBService();
    firebaseService = FirebaseService();
    notifyListenerCalls.dispose();
    exploreService.dispose();
  });
  test(
    'instance of ChangeNotifier',
    () {
      expect(exploreService, isA<ChangeNotifier>());
    },
  );

  group(
    'initial values',
    () {
      test(
        'should return initial value for user service',
        () {
          expect(exploreService.templates, isEmpty);
          expect(exploreService.filteredTemplates, isEmpty);
          expect(exploreService.getData, equals(0));
        },
      );
    },
  );

  group(
    'setTemplates',
    () {
      test(
        'should set templates when get data is 0',
        () async {
          when(() => mockFirebaseService.getTemplates()).thenAnswer(
            (_) async => [
              BucketTemplate(
                title: 'title',
                category: 'category',
                description: 'description',
                cloneCount: 0,
                isCompleted: false,
              ),
            ],
          );
          final templates = await exploreService.setTemplates();
          expect(templates, isA<List<BucketTemplate>>());
          expect(templates.length, 1);
          expect(templates.first?.title, 'title');
          expect(templates.first?.category, 'category');
          expect(templates.first?.description, 'description');
          expect(templates.first?.cloneCount, 0);
          expect(templates.first?.isCompleted, false);
          expect(exploreService.templates.length, 1);
          expect(exploreService.filteredTemplates.length, 1);
          expect(exploreService.getData, 1);
          notifyListenerCalls.called(1);
          verify(() => mockFirebaseService.getTemplates()).called(1);
        },
      );

      test(
        'should remain the same when get data is not 0',
        () async {
          exploreService.getData = 1;
          final templates = await exploreService.setTemplates();
          expect(templates, isA<List<BucketTemplate>>());
          expect(templates, isEmpty);
          expect(exploreService.getData, 1);
          notifyListenerCalls.called(0);
          verifyNever(() => mockFirebaseService.getTemplates());
        },
      );
    },
  );

  group(
    'editCloneCountInTemplate',
    () {
      test(
        'should edit clone count in template',
        () async {
          final template = BucketTemplate(
            title: 'title',
            category: 'category',
            description: 'description',
            cloneCount: 0,
            isCompleted: false,
          );
          exploreService.templates = [template];
          exploreService.filteredTemplates = [template];
          await exploreService.editCloneCountInTemplate(template);
          expect(template.cloneCount, 1);
          expect(exploreService.templates.first.cloneCount, 1);
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should remain the same when template is null',
        () async {
          final template = BucketTemplate(
            title: 'title',
            category: 'category',
            description: 'description',
            cloneCount: 0,
            isCompleted: false,
          );
          exploreService.templates = [template];
          exploreService.filteredTemplates = [template];
          await exploreService.editCloneCountInTemplate(null);
          expect(template.cloneCount, 0);
          expect(exploreService.templates.first.cloneCount, 0);
          notifyListenerCalls.called(0);
        },
      );
    },
  );

  group(
    'filterBuckets',
    () {
      test(
        'should filter the list of templates by category',
        () {
          final allTemplates = [
            BucketTemplate()
              ..title = 'title1'
              ..category = 'Travel'
              ..isCompleted = false,
            BucketTemplate()
              ..title = 'title2'
              ..category = 'Finance'
              ..isCompleted = false,
          ];
          exploreService.templates = allTemplates;
          exploreService.filterBuckets([BucketCategory.travel], false);
          expect(exploreService.filteredTemplates, isNotEmpty);
          expect(exploreService.filteredTemplates.length, equals(1));
          expect(
              exploreService.filteredTemplates.first.title, equals('title1'));
          notifyListenerCalls.called(1);
        },
      );

      test(
        'should filter the list of templates by status',
        () {
          final allTemplates = [
            BucketTemplate()
              ..title = 'title1'
              ..isCompleted = false,
            BucketTemplate()
              ..title = 'title2'
              ..isCompleted = true,
          ];
          exploreService.templates = allTemplates;
          exploreService.filterBuckets([], true);
          expect(exploreService.filteredTemplates, isNotEmpty);
          expect(exploreService.filteredTemplates.length, equals(1));
          expect(
              exploreService.filteredTemplates.first.title, equals('title2'));
          notifyListenerCalls.called(1);
        },
      );
    },
  );

  group(
    'resetFilter',
    () {
      test(
        'should reset filter',
        () {
          exploreService.templates = [BucketTemplate(), BucketTemplate()];
          exploreService.filteredTemplates = [BucketTemplate()];
          exploreService.resetFilter();
          expect(exploreService.filteredTemplates.length, equals(2));
          notifyListenerCalls.called(1);
        },
      );
    },
  );
}
