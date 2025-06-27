import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:task_assignment/services/dynamic_link_service.dart';
import 'package:task_assignment/view_models/task_view_model.dart';
import 'app_routes.dart';
import 'view_models/auth_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authViewModel = AuthViewModel();
  final router = createRouter(authViewModel);

  DynamicLinksService.instance.setRouter(router);
  await DynamicLinksService.instance.handleDynamicLinks();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const RouterApp(),
    );
  }
}

class RouterApp extends StatelessWidget {
  const RouterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final uid = authVM.user?.uid;

    if (uid == null) {
      return MaterialApp.router(routerConfig: createRouter(authVM));
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authVM),
        ChangeNotifierProvider(create: (_) => TaskViewModel(uid)),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF4F6FA),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.teal.shade600,
            elevation: 2,
            centerTitle: false,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        routerConfig: createRouter(authVM),
      ),
    );
  }
}
