import 'package:dive/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

class MockAuthResult extends Mock implements AuthResult {}

class MockIdTokenResult extends Mock implements IdTokenResult {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Get current user', () {
    test('should return current user', () {
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      final firebaseUser = MockFirebaseUser();

      when(firebaseAuthClient.currentUser())
          .thenAnswer((_) => Future.value(firebaseUser));

      auth.getCurrentUser().then((user) {
        expect(user, firebaseUser);
        verify(firebaseAuthClient.currentUser()).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(firebaseUser);
      });
    });

    test('should return null if there is no user', () {
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser())
          .thenAnswer((_) => Future.value(null));

      auth.getCurrentUser().then((user) {
        expect(user, null);
        verify(firebaseAuthClient.currentUser()).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
      });
    });
  });

  group('Checking Email verification', () {
    test('should return true if email is verified', () {
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser())
          .thenAnswer((_) => Future.value(firebaseUser));
      when(firebaseUser.isEmailVerified).thenReturn(true);

      auth.isEmailVerified().then((isEmailVerified) {
        expect(isEmailVerified, true);
        verify(firebaseUser.isEmailVerified).called(1);
        verify(firebaseAuthClient.currentUser()).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(firebaseUser);
      });
    });

    test('should return false if email is not verified', () {
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser())
          .thenAnswer((_) => Future.value(firebaseUser));
      when(firebaseUser.isEmailVerified).thenReturn(false);

      auth.isEmailVerified().then((isEmailVerified) {
        expect(isEmailVerified, false);
        verify(firebaseUser.isEmailVerified).called(1);
        verify(firebaseAuthClient.currentUser()).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(firebaseUser);
      });
    });
  });

  group('Email verification', () {
    test('should be initiated', () {
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser())
          .thenAnswer((_) => Future.value(firebaseUser));
      when(firebaseUser.sendEmailVerification())
          .thenAnswer((_) => Future.value());

      auth.sendEmailVerification().then((value) {
        verify(firebaseUser.sendEmailVerification()).called(1);
        verify(firebaseAuthClient.currentUser()).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(firebaseUser);
      });
    });
  });

  group('Signin', () {
    test('should sign in user', () {
      String _email = 'email';
      String _password = 'password';
      final authResult = MockAuthResult();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.signInWithEmailAndPassword(
              email: _email, password: _password))
          .thenAnswer((_) => Future.value(authResult));

      auth.signIn(_email, _password).then((result) {
        expect(result, authResult);
        verify(firebaseAuthClient.signInWithEmailAndPassword(
                email: _email, password: _password))
            .called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(authResult);
      });
    });

    test('should fail', () {
      String _email = 'email';
      String _password = 'password';
      final authResult = MockAuthResult();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.signInWithEmailAndPassword(
              email: _email, password: _password))
          .thenAnswer((_) => Future.error('error'));

      auth.signIn(_email, _password).catchError((onError) {
        expect(onError, 'error');
        verify(firebaseAuthClient.signInWithEmailAndPassword(
                email: _email, password: _password))
            .called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(authResult);
      });
    });
  });

  group('Signout', () {
    test('should signout the user', () {
      final authResult = MockAuthResult();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.signOut()).thenAnswer((_) => Future.value());

      auth.signOut().then((value) {
        verify(firebaseAuthClient.signOut()).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(authResult);
      });
    });

    test('should fail', () {
      final authResult = MockAuthResult();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.signOut())
          .thenAnswer((_) => Future.error('error'));

      auth.signOut().catchError((onError) {
        verify(firebaseAuthClient.signOut()).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(authResult);
      });
    });
  });

  group('Signup', () {
    test('should register the user', () {
      final authResult = MockAuthResult();
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      String _email = "email";
      String _password = "password";
      String _name = "name";

      when(firebaseAuthClient.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .thenAnswer((_) => Future.value(authResult));
      when(authResult.user).thenReturn(firebaseUser);
      when(firebaseUser.updateProfile(any)).thenAnswer((_) => Future.value());

      auth.signUp(_email, _password, _name).then((value) {
        verify(firebaseAuthClient.createUserWithEmailAndPassword(
                email: _email, password: _password))
            .called(1);
        verify(authResult.user).called(1);
        verify(firebaseUser.updateProfile(any)).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(authResult);
        verifyNoMoreInteractions(firebaseUser);
      });
    });

    test('should fail to register the user when create user fails', () {
      final authResult = MockAuthResult();
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      String _email = "email";
      String _password = "password";
      String _name = "name";

      when(firebaseAuthClient.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .thenAnswer((_) => Future.error("failed to create user"));

      auth.signUp(_email, _password, _name).catchError((onError) {
        expect(onError.toString(), "failed to create user");
        verify(firebaseAuthClient.createUserWithEmailAndPassword(
                email: _email, password: _password))
            .called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(authResult);
        verifyNoMoreInteractions(firebaseUser);
      });
    });

    test('should fail to register the user when update profile fails', () {
      final authResult = MockAuthResult();
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      String _email = "email";
      String _password = "password";
      String _name = "name";

      when(firebaseAuthClient.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .thenAnswer((_) => Future.value(authResult));
      when(authResult.user).thenReturn(firebaseUser);
      when(firebaseUser.updateProfile(any))
          .thenAnswer((_) => Future.error('error'));

      auth.signUp(_email, _password, _name).catchError((onError) {
        expect(onError.toString(), 'error');
        verify(firebaseAuthClient.createUserWithEmailAndPassword(
                email: _email, password: _password))
            .called(1);
        verify(authResult.user).called(1);
        verify(firebaseUser.updateProfile(any)).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(authResult);
        verifyNoMoreInteractions(firebaseUser);
      });
    });
  });

  group('Get id token', () {
    test('should return the id token', () {
      final authResult = MockAuthResult();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      MockFirebaseUser firebaseUser = MockFirebaseUser();
      Auth auth = Auth(firebaseAuthClient);
      MockIdTokenResult idTokenResult = MockIdTokenResult();
      String id = 'id';

      when(firebaseAuthClient.currentUser())
          .thenAnswer((_) => Future.value(firebaseUser));
      when(firebaseUser.getIdToken())
          .thenAnswer((_) => Future.value(idTokenResult));
      when(idTokenResult.token).thenReturn(id);

      auth.getIdToken().then((value) {
        expect(value, id);

        verify(firebaseUser.getIdToken()).called(1);
        verify(idTokenResult.token).called(1);
        verify(firebaseAuthClient.currentUser()).called(1);
        verifyNoMoreInteractions(firebaseUser);
        verifyNoMoreInteractions(idTokenResult);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(authResult);
      });
    });

    test('should return empty id token if firebase user is null', () {
      final authResult = MockAuthResult();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);
      String id = '';

      when(firebaseAuthClient.currentUser())
          .thenAnswer((_) => Future.value(null));

      auth.getIdToken().then((value) {
        expect(value, id);

        verify(firebaseAuthClient.currentUser()).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(authResult);
      });
    });
  });
}
