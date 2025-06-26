import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:task_assignment/services/dynamic_link_service.dart';
import 'package:task_assignment/widgets/assign_modal.dart';
import '../models/task_model.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/task_view_model.dart';

class EditTaskView extends StatefulWidget {
  final String taskId;
  const EditTaskView({required this.taskId, super.key});

  @override
  State<EditTaskView> createState() => _EditTaskViewState();
}

class _EditTaskViewState extends State<EditTaskView> {
  final titleC = TextEditingController();
  final descC = TextEditingController();
  bool isEditing = false;
  bool isSynced = true;
  Timer? debounce;
  TaskModel? localTask;

  @override
  void initState() {
    super.initState();
    if (widget.taskId.isEmpty) isEditing = true;
    titleC.addListener(onChange);
    descC.addListener(onChange);
  }

  void onChange() {
    if (!isEditing || widget.taskId.isEmpty || localTask == null) return;

    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () async {
      final vm = Provider.of<TaskViewModel>(context, listen: false);

      final updated = TaskModel(
        id: localTask!.id,
        title: titleC.text,
        description: descC.text,
        ownerId: localTask!.ownerId,
        sharedWith: localTask!.sharedWith,
        createdAt: localTask!.createdAt,
      );

      await vm.update(updated);

      if (mounted) {
        setState(() => isSynced = true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => isSynced = false);
        });
      }
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    titleC.dispose();
    descC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUID = Provider.of<AuthViewModel>(
      context,
      listen: false,
    ).user!.uid;

    final String email = authUID;
    final vm = Provider.of<TaskViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.taskId.isEmpty
              ? 'Create Task'
              : isEditing
              ? 'Edit Task'
              : 'Task Details',
          style: const TextStyle(color: Colors.white),
        ),
        actions: widget.taskId.isNotEmpty
            ? [
                IconButton(
                  icon: Icon(Icons.share, color: Colors.white),
                  onPressed: () async {
                    final link = await DynamicLinksService.instance
                        .createDynamicLibks(widget.taskId);
                    SharePlus.instance.share(
                      ShareParams(
                        uri: link,
                        text: "Task assignment",
                        subject: "Check out ",
                      ),
                    );
                  },
                ),

                if (isSynced && isEditing)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.cloud_done, color: Colors.white),
                  ),
                if (!isEditing)
                  IconButton(
                    icon: const Icon(
                      Icons.person_add_alt_1,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (_) => ShareUserModal(taskId: widget.taskId),
                      );
                    },
                  ),
                IconButton(
                  icon: Icon(
                    isEditing ? Icons.close : Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() => isEditing = !isEditing);
                  },
                ),
              ]
            : null,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: widget.taskId.isEmpty
            ? _buildCreateForm(context, vm, authUID, email)
            : _buildEditView(vm),
      ),
    );
  }

  Widget _buildCreateForm(
    BuildContext context,
    TaskViewModel vm,
    String authUID,
    String email,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Title"),
        _styledTextField(titleC, 'Enter task title'),
        const SizedBox(height: 16),
        _sectionTitle("Description"),
        _styledTextField(descC, 'Write something...', maxLines: 5),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final newTask = TaskModel(
                id: '',
                title: titleC.text,
                description: descC.text,
                ownerId: authUID,
                sharedWith: [email],
                createdAt: DateTime.now(),
              );
              await vm.add(newTask);
              if (mounted) Navigator.of(context).pop();
            },
            label: const Text("Save"),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildEditView(TaskViewModel vm) {
    return StreamBuilder<TaskModel>(
      stream: vm.taskStreamById(widget.taskId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final task = snapshot.data!;
        localTask = task;

        if (!isEditing) {
          titleC.text = task.title;
          descC.text = task.description;
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Title"),
              isEditing
                  ? _styledTextField(titleC, 'Edit title')
                  : _readonlyText(task.title),
              const SizedBox(height: 16),
              _sectionTitle("Description"),
              isEditing
                  ? _styledTextField(descC, 'Edit description', maxLines: 5)
                  : _readonlyText(task.description),
              const SizedBox(height: 24),
              _sectionTitle("Shared With"),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: task.sharedWith
                    .map((uid) => Chip(label: Text(uid)))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
  );

  Widget _styledTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _readonlyText(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text.isEmpty ? "(empty)" : text,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
    ),
  );
}
