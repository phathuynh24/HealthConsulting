import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;

  UserRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signUp(
      {required String email,
      required String password,
      required String displayName}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    var currentUser = _firebaseAuth.currentUser;

    //update info
    await currentUser!.updateDisplayName(displayName);
  }

  Future signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<String> getUser() async {
    return _firebaseAuth.currentUser!.displayName!;
  }
}