import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _auth = AuthService();
  User? user;
  bool busy = false;
  String? error;

  AuthViewModel() {
    _auth.authState.listen((u) {
      user = u;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String pass) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _auth.signIn(email, pass);
    } catch (e) {
      error = e.toString();
    }
    busy = false;
    notifyListeners();
  }

  Future<void> signUp(String email, String pass) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _auth.signUp(email, pass);
    } catch (e) {
      error = e.toString();
    }
    busy = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    user = null;
    notifyListeners();
  }
}
