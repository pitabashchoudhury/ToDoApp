// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../view_models/auth_view_model.dart';
// import '../view_models/task_view_model.dart';
// import '../models/task_model.dart';
// import '../widgets/task_tile.dart';

// class HomeView extends StatelessWidget {
//   const HomeView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authVM = Provider.of<AuthViewModel>(context, listen: false);
//     final taskVM = Provider.of<TaskViewModel>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tasks'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await authVM.signOut();
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<List<TaskModel>>(
//         stream: taskVM.taskStream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final tasks = snapshot.data;

//           if (tasks == null || tasks.isEmpty) {
//             return const Center(child: Text('No tasks available.'));
//           }

//           return ListView.builder(
//             itemCount: tasks.length,
//             itemBuilder: (_, i) => TaskTile(
//               task: tasks[i],
//               onTap: () => GoRouter.of(context).push('/edit', extra: tasks[i]),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => GoRouter.of(context).push('/edit'),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/task_view_model.dart';
import '../models/task_model.dart';
import '../widgets/task_tile.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: taskVM.taskStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data;

          if (tasks == null || tasks.isEmpty) {
            return const Center(child: Text('No tasks available.'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, i) => TaskTile(
              task: tasks[i],
              onTap: () => context.push('/edit/${tasks[i].id}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
