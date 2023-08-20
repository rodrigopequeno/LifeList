import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/services/index.dart';

void main() {
  late FirebaseService firebaseService;
  late FirebaseFirestore mockFirestore;

  setUp(() {
    mockFirestore = FakeFirebaseFirestore();
    firebaseService = FirebaseService(
      firestore: mockFirestore,
    );
  });

  group('getTemplates', () {
    test(
      'should return empty when search for templates in empty firestore',
      () async {
        final result = await firebaseService.getTemplates();

        expect(result, isEmpty);
      },
    );

    test(
      'should return a list of templates when search for templates in firestore',
      () async {
        final date = Timestamp.now();
        await mockFirestore.collection('template').add({
          'cloneCount': 0,
          'description': 'description',
          'scope': 'scope',
          'category': 'category',
          'title': 'title',
          'deadline': date,
          'tasks': [
            'task1',
            'task2',
          ],
          'isCompleted': true,
        });

        final result = await firebaseService.getTemplates();

        expect(result, isNotEmpty);
      },
    );
  });
  group('editCloneCountInDB', () {
    test(
      'should increment cloneCount by 1 when editCloneCountInDB is called',
      () async {
        final date = Timestamp.now();
        await mockFirestore.collection('template').add({
          'cloneCount': 0,
          'description': 'description',
          'scope': 'scope',
          'category': 'category',
          'title': 'title',
          'deadline': date,
          'tasks': [
            'task1',
            'task2',
          ],
          'isCompleted': true,
        });

        await firebaseService.editCloneCountInDB('title');

        final result = await mockFirestore
            .collection('template')
            .where('title', isEqualTo: 'title')
            .get();

        expect(result.docs.first.data()['cloneCount'], 1);
      },
    );

    test(
      'should not increment cloneCount when editCloneCountInDB is called with non-existing title',
      () async {
        final date = Timestamp.now();
        await mockFirestore.collection('template').add({
          'cloneCount': 0,
          'description': 'description',
          'scope': 'scope',
          'category': 'category',
          'title': 'title',
          'deadline': date,
          'tasks': [
            'task1',
            'task2',
          ],
          'isCompleted': true,
        });

        await firebaseService.editCloneCountInDB('title2');

        final result = await mockFirestore
            .collection('template')
            .where('title', isEqualTo: 'title')
            .get();

        expect(result.docs.first.data()['cloneCount'], 0);
      },
    );
  });

  group('checkIfUserExists', () {
    test(
      'should return true when checkIfUserExists is called with existing docId',
      () async {
        await mockFirestore.collection('user').doc('docId').set({
          'name': 'name',
          'email': 'email',
          'avatar': 'avatar',
        });

        final result = await firebaseService.checkIfUserExists('docId');

        expect(result, true);
      },
    );

    test(
      'should return false when checkIfUserExists is called with non-existing docId',
      () async {
        await mockFirestore.collection('user').doc('docId').set({
          'name': 'name',
          'email': 'email',
          'avatar': 'avatar',
        });

        final result = await firebaseService.checkIfUserExists('docId2');

        expect(result, false);
      },
    );
  });
}
