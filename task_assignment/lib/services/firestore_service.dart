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
        .map((snap) =>
            snap.docs.map((doc) => TaskModel.fromMap(doc.id, doc.data())).toList());
  }

  /// Stream a single task by ID in real-time
  Stream<TaskModel> streamTaskById(String taskId) {
    return _db.collection('tasks').doc(taskId).snapshots().map((doc) {
      return TaskModel.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> addTask(TaskModel t) async {
    final docRef = await _db.collection('tasks').add(t.toMap());
    await docRef.update({'id': docRef.id});
  }

  Future<void> updateTask(TaskModel t) async {
    final updatedMap = t.toMap();
    updatedMap.remove('id');
    await _db.collection('tasks').doc(t.id).update(updatedMap);
  }

  Future<void> shareTaskWithUserId(String taskId, String userId) async {
    await _db.collection('tasks').doc(taskId).update({
      'sharedWith': FieldValue.arrayUnion([userId])
    });
  }


  Future<void> unshareTaskWithUserId(String taskId, String userId) async {
  await _db.collection('tasks').doc(taskId).update({
    'sharedWith': FieldValue.arrayRemove([userId])
  });
}





}
