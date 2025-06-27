import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/task_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskViewModel extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  late Stream<List<TaskModel>> taskStream;

  List<TaskModel> cachedTasks = [];

  List<TaskModel> yourTasks = [];
  DocumentSnapshot? _lastYourTaskDoc;
  bool isLoadingMoreYourTasks = false;
  bool hasMoreYourTasks = true;

  Future<void> fetchMoreYourTasks({int limit = 10}) async {
    if (isLoadingMoreYourTasks || !hasMoreYourTasks) return;
    isLoadingMoreYourTasks = true;
    notifyListeners();

    final (newTasks, lastDoc) = await _fs.fetchAssignedTasksPaginatedWithCursor(
      uid: uid,
      lastDoc: _lastYourTaskDoc,
      limit: limit,
    );

    if (newTasks.isEmpty) {
      hasMoreYourTasks = false;
    } else {
      yourTasks.addAll(newTasks);
      _lastYourTaskDoc = lastDoc;
    }

    isLoadingMoreYourTasks = false;
    notifyListeners();
  }

  Future<void> refreshYourTasks() async {
    yourTasks.clear();
    _lastYourTaskDoc = null;
    hasMoreYourTasks = true;
    await fetchMoreYourTasks();
  }

  // For pagination (assigned to me)
  List<TaskModel> assignedToMeTasks = [];
  DocumentSnapshot? lastAssignedDoc;
  bool hasMoreAssignedTasks = true;
  bool isLoadingMoreAssignedTasks = false;

  final String uid;

  TaskViewModel(this.uid) {
    taskStream = _fs.streamTasks(uid).map((tasks) {
      cachedTasks = tasks; // Optional caching for all tasks
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
      await _fs.shareTaskWithUserId(taskId, email);
      notifyListeners();
    } catch (e) {
      debugPrint('Error sharing task: $e');
      rethrow;
    }
  }

  /// 🔁 Pagination: Fetch next page of "assigned to me" tasks
  Future<void> fetchMoreAssignedTasks({int limit = 10}) async {
    if (isLoadingMoreAssignedTasks || !hasMoreAssignedTasks) return;

    isLoadingMoreAssignedTasks = true;
    notifyListeners();

    try {
      final (newTasks, lastDoc) = await _fs
          .fetchAssignedTasksPaginatedWithCursor(
            uid: uid,
            lastDoc: lastAssignedDoc,
            limit: limit,
          );

      assignedToMeTasks.addAll(newTasks);
      lastAssignedDoc = lastDoc;
      hasMoreAssignedTasks = newTasks.length == limit;
    } catch (e) {
      debugPrint("Failed to fetch assigned tasks: $e");
    }

    isLoadingMoreAssignedTasks = false;
    notifyListeners();
  }

  /// 🔁 Optional: Refresh from scratch
  Future<void> refreshAssignedTasks({int limit = 10}) async {
    assignedToMeTasks.clear();
    lastAssignedDoc = null;
    hasMoreAssignedTasks = true;
    await fetchMoreAssignedTasks(limit: limit);
  }
}
