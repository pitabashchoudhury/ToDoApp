import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_assignment/models/task_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Stream<List<TaskModel>> streamTasks(String uid) {
    return _db
        .collection('tasks')
        .where('sharedWith', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => TaskModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addTask(TaskModel t) => _db.collection('tasks').add(t.toMap());

  Future<void> updateTask(TaskModel t) =>
      _db.collection('tasks').doc(t.id).update(t.toMap());
}
