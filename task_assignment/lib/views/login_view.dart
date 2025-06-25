import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool signup = false;

  @override
  Widget build(BuildContext c) {
    final vm = Provider.of<AuthViewModel>(c);
    return Scaffold(
      appBar: AppBar(title: Text(signup ? 'Sign Up' : 'Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailC,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passC,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (vm.error != null)
              Text(vm.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: vm.busy
                  ? null
                  : () async {
                      if (signup) {
                        await vm.signUp(emailC.text, passC.text);
                      } else {
                        await vm.signIn(emailC.text, passC.text);
                      }
                      if (vm.user != null) GoRouter.of(c).go('/');
                    },
              child: vm.busy
                  ? const CircularProgressIndicator()
                  : Text(signup ? 'Sign Up' : 'Login'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => signup = !signup),
              child: Text(
                signup ? 'Have an account? Login' : 'No account? Sign Up',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
