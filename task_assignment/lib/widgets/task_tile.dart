import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskTile({required this.task, required this.onTap, super.key});

  @override
  Widget build(BuildContext c) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text(task.description),
      onTap: onTap,
    );
  }
}
