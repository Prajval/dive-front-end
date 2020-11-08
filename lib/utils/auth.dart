import 'package:dive/errors/generic_http_error.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'constants.dart';

abstract class BaseAuth {
  User getCurrentUser();

  bool isEmailVerified();

  Future<void> sendEmailVerification();

  Future<UserCredential> signIn(String email, String password);

  Future<void> signOut();

  Future<void> signUp(String email, String password, String name);

  Future<String> getIdToken();

  Future<void> resetPassword(String email);

  Future<void> updateEmail(String newEmail);

  Future<void> updateName(String newName);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth;

  Auth(this._firebaseAuth);

  @override
  User getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  bool isEmailVerified() {
    User user = getCurrentUser();
    if (user != null)
      return user.emailVerified;
    else
      return false;
  }

  @override
  Future<void> sendEmailVerification() {
    return getCurrentUser().sendEmailVerification().catchError((error) {
      throw error;
    });
  }

  @override
  Future<UserCredential> signIn(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> signUp(String email, String password, String name) {
    return _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((userCredential) =>
            userCredential.user.updateProfile(displayName: name));
  }

  @override
  Future<String> getIdToken() {
    User user = _firebaseAuth.currentUser;
    if (user != null) {
      return Future.value(user.getIdToken());
    } else {
      return Future.error(GenericError(userIsNullCode));
    }
  }

  @override
  Future<void> resetPassword(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updateEmail(String newEmail) {
    if (_firebaseAuth.currentUser.email != newEmail)
      return _firebaseAuth.currentUser.updateEmail(newEmail);
    else
      return Future.value();
  }

  @override
  Future<void> updateName(String newName) {
    if (_firebaseAuth.currentUser.displayName != newName)
      return _firebaseAuth.currentUser.updateProfile(displayName: newName);
    else
      return Future.value();
  }
}
