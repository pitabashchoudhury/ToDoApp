import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_assignment/models/task_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<(List<TaskModel>, DocumentSnapshot?)>
  fetchAssignedTasksPaginatedWithCursor({
    required String uid,
    DocumentSnapshot? lastDoc,
    int limit = 10,
  }) async {
    Query query = _db
        .collection('tasks')
        .where('sharedWith', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snap = await query.get();

    final tasks = snap.docs
        .map(
          (doc) =>
              TaskModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();

    return (tasks, snap.docs.isNotEmpty ? snap.docs.last : null);
  }

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

  Future<void> shareTaskWithUserId(String taskId, String email) async {
    final uid = await getUidByEmail(email);
    if (uid != null) {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'sharedWith': FieldValue.arrayUnion([uid]),
      });
    }
    // await _db.collection('tasks').doc(taskId).update({
    //   'sharedWith': FieldValue.arrayUnion([userId]),
    // });
  }

  Future<void> unshareTaskWithUserId(String taskId, String userId) async {
    await _db.collection('tasks').doc(taskId).update({
      'sharedWith': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> saveUserToFirestore(User user) async {
    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'createdAt': DateTime.now(),
    });
  }

  Future<String?> getUidByEmail(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return query.docs.first.id; // UID is the document ID
  }

  Future<(List<TaskModel>, DocumentSnapshot?)>
  fetchYourTasksPaginatedWithCursor({
    required String uid,
    DocumentSnapshot? lastDoc,
    int limit = 10,
  }) async {
    Query query = _db
        .collection('tasks')
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snap = await query.get();

    final tasks = snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return TaskModel.fromMap(doc.id, data);
    }).toList();

    return (tasks, snap.docs.isNotEmpty ? snap.docs.last : null);
  }
}
