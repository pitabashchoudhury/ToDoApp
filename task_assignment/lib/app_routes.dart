import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:task_assignment/models/task_model.dart';
import 'package:task_assignment/view_models/auth_view_model.dart';
import 'package:task_assignment/view_models/task_view_model.dart';
import 'package:task_assignment/views/edit_task_view.dart';
import 'package:task_assignment/views/home_view.dart';
import 'package:task_assignment/views/login_view.dart';

GoRouter createRouter(AuthViewModel authViewModel) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authViewModel,
    redirect: (context, state) {
      final loggedIn = authViewModel.user != null;
      final loggingIn = state.matchedLocation == '/login';
      if (!loggedIn) return loggingIn ? null : '/login';
      if (loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(path: '/', builder: (context, state) => const HomeView()),
      GoRoute(
        path: '/edit',
        builder: (context, state) {
          final task = state.extra as TaskModel?;
          return EditTaskView(task: task);
        },
      ),
    ],
  );
}
