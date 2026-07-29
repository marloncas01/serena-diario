import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

class AuthServiceFirebase implements AuthService {
  AuthServiceFirebase._();
  static final AuthServiceFirebase _instance = AuthServiceFirebase._();
  factory AuthServiceFirebase() => _instance;

  final _auth = FirebaseAuth.instance;
  final _google = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  Future<CloudUser> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) {
      throw Exception('El usuario canceló el inicio de sesión.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) {
      throw Exception('No se pudo autenticar con Google.');
    }

    return CloudUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _google.signOut(),
    ]);
  }

  @override
  CloudUser? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return CloudUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL,
    );
  }

  @override
  bool isSignedIn() => _auth.currentUser != null;

  Stream<CloudUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return CloudUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL,
      );
    });
  }
}
