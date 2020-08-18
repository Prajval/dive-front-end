import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<AuthResult> signIn(String email, String password);

  Future<void> signUp(String email, String password, String name);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<String> getIdToken();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth;

  Auth(this._firebaseAuth);

  @override
  Future<FirebaseUser> getCurrentUser() {
    return _firebaseAuth.currentUser();
  }

  @override
  Future<bool> isEmailVerified() {
    return _firebaseAuth.currentUser().then((user) => user.isEmailVerified);
  }

  @override
  Future<void> sendEmailVerification() {
    return _firebaseAuth
        .currentUser()
        .then((user) => user.sendEmailVerification());
  }

  @override
  Future<AuthResult> signIn(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> signUp(String email, String password, String name) {
    UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
    userUpdateInfo.displayName = name;

    return _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((result) => result.user.updateProfile(userUpdateInfo));
  }

  @override
  Future<String> getIdToken() {
    return _firebaseAuth
        .currentUser()
        .then((user) => user.getIdToken())
        .then((value) => value.token)
        .catchError((onError) => onError);
  }
}
