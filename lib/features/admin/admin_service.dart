import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  static final _auth = FirebaseAuth.instance;

  static bool get isSignedIn => _auth.currentUser != null;

  static Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  static Future<void> signOut() => _auth.signOut();
}
