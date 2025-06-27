import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/task_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskViewModel extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  late Stream<List<TaskModel>> taskStream;

  List<TaskModel> cachedTasks = [];

  TaskViewModel(String uid) {
    taskStream = _fs.streamTasks(uid).map((tasks) {
      cachedTasks = tasks; // Cache the result for UI pagination
      return tasks;
    });
  }

  /// 🔁 Stream all tasks shared with current user
  Stream<List<TaskModel>> get allTasks => taskStream;

  /// 🔁 Stream a single task (for real-time edit view)
  Stream<TaskModel> taskStreamById(String taskId) {
    return _fs.streamTaskById(taskId);
  }

  /// ➕ Add a new task
  Future<void> add(TaskModel t) => _fs.addTask(t);

  /// ✏️ Update existing task
  Future<void> update(TaskModel t) => _fs.updateTask(t);

  /// 🔄 Share with user by their email
  Future<void> shareWithUserEmail(String taskId, String email) async {
    try {
      // final userSnap = await FirebaseFirestore.instance
      //     .collection('users')
      //     .where('email', isEqualTo: email)
      //     .limit(1)
      //     .get();

      // if (userSnap.docs.isEmpty) {
      //   throw Exception('User not found');
      // }

      // final userId = userSnap.docs.first.id;

      await _fs.shareTaskWithUserId(taskId, email);

      notifyListeners();
    } catch (e) {
      debugPrint('Error sharing task: $e');
      rethrow;
    }
  }
}
