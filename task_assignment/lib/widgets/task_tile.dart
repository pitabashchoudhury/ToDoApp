import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskTile({required this.task, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        task.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        task.description,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}
