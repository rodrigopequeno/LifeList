import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/models/template.dart';

void main() {
  test('instance of BucketTemplate', () {
    final template = BucketTemplate();
    expect(template, isA<BucketTemplate>());
  });

  group(
    'fromJson',
    () {
      test(
        'should return a BucketTemplate from a valid json',
        () {
          final json = {
            'cloneCount': 0,
            'description': 'description',
            'scope': 'scope',
            'category': 'category',
            'title': 'title',
            'deadline': Timestamp.now(),
            'tasks': [
              'task1',
              'task2',
            ],
            'isCompleted': true,
          };
          final template = BucketTemplate.fromJson(json);
          expect(template, isA<BucketTemplate>());
          expect(template.cloneCount, isNotNull);
          expect(template.description, isNotNull);
          expect(template.scope, isNotNull);
          expect(template.category, isNotNull);
          expect(template.title, isNotNull);
          expect(template.deadline, isNotNull);
          expect(template.tasks, isNotNull);
          expect(template.isCompleted, isNotNull);
        },
      );

      test(
        'should return a BucketTemplate with a null values when json invalid',
        () {
          final json = <String, dynamic>{};
          final template = BucketTemplate.fromJson(json);
          expect(template, isA<BucketTemplate>());
          expect(template.cloneCount, isNull);
          expect(template.description, isNull);
          expect(template.scope, isNull);
          expect(template.category, isNull);
          expect(template.title, isNull);
          expect(template.deadline, isNull);
          expect(template.tasks, isNull);
          expect(template.isCompleted, isNull);
        },
      );
    },
  );

  group(
    'toJson',
    () {
      test(
        'should return a json from a valid BucketTemplate',
        () {
          final date = DateTime(2023);

          final template = BucketTemplate(
            cloneCount: 0,
            description: 'description',
            scope: 'scope',
            category: 'category',
            title: 'title',
            deadline: date.toString(),
            tasks: [
              'task1',
              'task2',
            ],
            isCompleted: true,
          );
          final json = template.toJson();
          final expected = {
            'cloneCount': 0,
            'description': 'description',
            'scope': 'scope',
            'category': 'category',
            'title': 'title',
            'deadline': date.toString(),
            'tasks': [
              'task1',
              'task2',
            ],
            'isCompleted': true,
          };
          expect(json, expected);
        },
      );

      test(
        'should return a json from a valid BucketTemplate when is empty',
        () {
          final template = BucketTemplate();
          final json = template.toJson();
          final expected = {
            'cloneCount': null,
            'description': null,
            'scope': null,
            'category': null,
            'title': null,
            'deadline': null,
            'tasks': null,
            'isCompleted': null
          };
          expect(json, expected);
        },
      );
    },
  );
}
