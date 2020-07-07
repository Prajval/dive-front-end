import 'package:dive/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

class MockAuthResult extends Mock implements AuthResult {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Get current user', () {
    test('should return current user', () async {
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      final firebaseUser = MockFirebaseUser();

      when(firebaseAuthClient.currentUser())
          .thenAnswer((_) async => firebaseUser);

      expectLater(await auth.getCurrentUser(), firebaseUser);

      verify(firebaseAuthClient.currentUser()).called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(firebaseUser);
    });

    test('should return null if there is no user', () async {
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser()).thenAnswer((_) async => null);

      expectLater(await auth.getCurrentUser(), null);

      verify(firebaseAuthClient.currentUser()).called(1);

      verifyNoMoreInteractions(firebaseAuthClient);
    });
  });

  group('Checking Email verification', () {
    test('should return true if email is verified', () async {
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser())
          .thenAnswer((_) async => firebaseUser);
      when(firebaseUser.isEmailVerified).thenReturn(true);

      expectLater(await auth.isEmailVerified(), true);

      verify(firebaseUser.isEmailVerified).called(1);
      verify(firebaseAuthClient.currentUser()).called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(firebaseUser);
    });

    test('should return false if email is not verified', () async {
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser())
          .thenAnswer((_) async => firebaseUser);
      when(firebaseUser.isEmailVerified).thenReturn(false);

      expectLater(await auth.isEmailVerified(), false);

      verify(firebaseUser.isEmailVerified).called(1);
      verify(firebaseAuthClient.currentUser()).called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(firebaseUser);
    });
  });

  group('Email verification', () {
    test('should be initiated', () async {
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser())
          .thenAnswer((_) async => firebaseUser);
      when(firebaseUser.sendEmailVerification()).thenAnswer((_) => null);

      await auth.sendEmailVerification();

      verify(firebaseUser.sendEmailVerification()).called(1);
      verify(firebaseAuthClient.currentUser()).called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(firebaseUser);
    });
  });

  group('Signin', () {
    test('should sign in user', () async {
      String _email = 'email';
      String _password = 'password';
      final authResult = MockAuthResult();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.signInWithEmailAndPassword(
              email: _email, password: _password))
          .thenAnswer((_) async => authResult);

      expectLater(await auth.signIn(_email, _password), authResult);

      verify(firebaseAuthClient.signInWithEmailAndPassword(
              email: _email, password: _password))
          .called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(authResult);
    });

    test('should fail', () async {
      String _email = 'email';
      String _password = 'password';
      final authResult = MockAuthResult();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);
      Exception exception = Exception("ERROR_INVALID_EMAIL");

      when(firebaseAuthClient.signInWithEmailAndPassword(
              email: _email, password: _password))
          .thenThrow((_) async => exception);

      try {
        await auth.signIn(_email, _password);
      } catch (e) {}

      verify(firebaseAuthClient.signInWithEmailAndPassword(
              email: _email, password: _password))
          .called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(authResult);
    });
  });

  group('Signout', () {
    test('should signout the user', () async {
      final authResult = MockAuthResult();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.signOut()).thenAnswer((_) async => null);

      await auth.signOut();

      verify(firebaseAuthClient.signOut()).called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(authResult);
    });

    test('should fail', () async {
      final authResult = MockAuthResult();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);
      Exception exception = Exception("ERROR_INVALID_EMAIL");

      when(firebaseAuthClient.signOut()).thenThrow((_) async => exception);

      try {
        await auth.signOut();
      } catch (e) {}

      verify(firebaseAuthClient.signOut()).called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(authResult);
    });
  });

  group('Signup', () {
    test('should register the user', () async {
      final authResult = MockAuthResult();
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      String _email = "email";
      String _password = "password";
      String _name = "name";

      when(firebaseAuthClient.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .thenAnswer((_) async => authResult);
      when(authResult.user).thenReturn(firebaseUser);
      when(firebaseUser.updateProfile(any)).thenAnswer((_) async => null);

      await auth.signUp(_email, _password, _name);

      verify(firebaseAuthClient.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .called(1);
      verify(authResult.user).called(1);
      verify(firebaseUser.updateProfile(any)).called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(authResult);
      verifyNoMoreInteractions(firebaseUser);
    });

    test('should fail to register the user when create user fails', () async {
      final authResult = MockAuthResult();
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      String _email = "email";
      String _password = "password";
      String _name = "name";

      when(firebaseAuthClient.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .thenThrow((_) async => new Exception("failed to create user"));

      try {
        await auth.signUp(_email, _password, _name);
      } catch (e) {}

      verify(firebaseAuthClient.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(authResult);
      verifyNoMoreInteractions(firebaseUser);
    });

    test('should fail to register the user when update profile fails',
        () async {
      final authResult = MockAuthResult();
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      String _email = "email";
      String _password = "password";
      String _name = "name";

      when(firebaseAuthClient.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .thenAnswer((_) async => authResult);
      when(authResult.user).thenReturn(firebaseUser);
      when(firebaseUser.updateProfile(any)).thenThrow((_) async => Exception());

      try {
        await auth.signUp(_email, _password, _name);
      } catch (e) {}

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
}
