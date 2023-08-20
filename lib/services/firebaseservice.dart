import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifelist/models/template.dart';

class FirebaseService {
  FirebaseService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<List<BucketTemplate>> getTemplates() async {
    final collectionReference = _firestore.collection('template');

    QuerySnapshot querySnapshot = await collectionReference.get();

    List<BucketTemplate> buckets = [];
    for (var element in querySnapshot.docs) {
      buckets
          .add(BucketTemplate.fromJson(element.data() as Map<String, dynamic>));
    }

    return buckets;
  }

  Future<void> editCloneCountInDB(name) async {
    final collectionReference = _firestore.collection('template');

    QuerySnapshot<Object?> template =
        await collectionReference.where('title', isEqualTo: name).get();
    BucketTemplate? bucket;
    String id = '';
    for (final docs in template.docs) {
      id = docs.id;
      bucket = BucketTemplate.fromJson(docs.data() as Map<String, dynamic>);
    }
    if (bucket == null) return;
    bucket.cloneCount = (bucket.cloneCount ?? 0) + 1;
    debugger(when: bucket.cloneCount == 0);
    await collectionReference.doc(id).update({'cloneCount': bucket.cloneCount});
  }

  Future<bool> checkIfUserExists(String docId) async {
    final collectionReference = _firestore.collection('user');

    DocumentSnapshot user = await collectionReference.doc(docId).get();
    return user.exists;
  }
}
