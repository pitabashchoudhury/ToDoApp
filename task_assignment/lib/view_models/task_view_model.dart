import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/task_model.dart';

class TaskViewModel extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  late Stream<List<TaskModel>> taskStream;

  TaskViewModel(String uid) {
    taskStream = _fs.streamTasks(uid);
  }

  Future<void> add(TaskModel t) => _fs.addTask(t);

  Future<void> update(TaskModel t) => _fs.updateTask(t);
}
