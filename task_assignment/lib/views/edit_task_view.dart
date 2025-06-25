import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/task_view_model.dart';
import 'package:go_router/go_router.dart';

class EditTaskView extends StatefulWidget {
  final TaskModel? task;
  const EditTaskView({this.task, super.key});
  @override
  _EditTaskViewState createState() => _EditTaskViewState();
}

class _EditTaskViewState extends State<EditTaskView> {
  final titleC = TextEditingController();
  final descC = TextEditingController();

  @override
  void initState() {
    if (widget.task != null) {
      titleC.text = widget.task!.title;
      descC.text = widget.task!.description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext c) {
    final authUID = Provider.of<AuthViewModel>(c, listen: false).user!.uid;
    final vm = Provider.of<TaskViewModel>(c, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descC,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final t = TaskModel(
                  id: widget.task?.id ?? '',
                  title: titleC.text,
                  description: descC.text,
                  ownerId: authUID,
                  sharedWith: [authUID],
                  createdAt: widget.task?.createdAt ?? DateTime.now(),
                );
                widget.task == null ? await vm.add(t) : await vm.update(t);
                GoRouter.of(c).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
