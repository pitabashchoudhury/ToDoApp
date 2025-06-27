import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_assignment/services/firestore_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String pass) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    );
    if (cred != null && cred.user != null) {
      await FirestoreService().saveUserToFirestore(cred.user!);
    }
    return cred.user;
  }

  Future<User?> signIn(String email, String pass) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: pass,
    );
    return cred.user;
  }

  Future<void> signOut() async => _auth.signOut();

  Stream<User?> get authState => _auth.authStateChanges();
}
