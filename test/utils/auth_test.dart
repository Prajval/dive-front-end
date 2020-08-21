import 'package:dive/utils/auth.dart';
import 'package:dive/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Get current user', () {
    test('should return current user', () {
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      final firebaseUser = MockFirebaseUser();

      when(firebaseAuthClient.currentUser).thenReturn(firebaseUser);

      User user = auth.getCurrentUser();

      expect(user, firebaseUser);
      verify(firebaseAuthClient.currentUser).called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(firebaseUser);
    });

    test('should return null if there is no user', () {
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser).thenReturn(null);

      User user = auth.getCurrentUser();

      expect(user, null);
      verify(firebaseAuthClient.currentUser).called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
    });
  });

  group('Checking Email verification', () {
    test('should return true if email is verified', () {
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser).thenReturn(firebaseUser);
      when(firebaseUser.emailVerified).thenReturn(true);

      bool isEmailVerified = auth.isEmailVerified();

      expect(isEmailVerified, true);
      verify(firebaseUser.emailVerified).called(1);
      verify(firebaseAuthClient.currentUser).called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(firebaseUser);
    });

    test('should return false if email is not verified', () {
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser).thenReturn(firebaseUser);
      when(firebaseUser.emailVerified).thenReturn(false);

      bool isEmailVerified = auth.isEmailVerified();

      expect(isEmailVerified, false);
      verify(firebaseUser.emailVerified).called(1);
      verify(firebaseAuthClient.currentUser).called(1);
      verifyNoMoreInteractions(firebaseAuthClient);
      verifyNoMoreInteractions(firebaseUser);
    });
  });

  group('Email verification', () {
    test('should be initiated', () {
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser).thenReturn(firebaseUser);
      when(firebaseUser.sendEmailVerification())
          .thenAnswer((_) => Future.value());

      auth.sendEmailVerification().then((value) {
        verify(firebaseUser.sendEmailVerification()).called(1);
        verify(firebaseAuthClient.currentUser).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(firebaseUser);
      });
    });
  });

  group('Signin', () {
    test('should sign in user', () {
      String _email = 'email';
      String _password = 'password';
      final mockUserCredential = MockUserCredential();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.signInWithEmailAndPassword(
              email: _email, password: _password))
          .thenAnswer((_) => Future.value(mockUserCredential));

      auth.signIn(_email, _password).then((result) {
        expect(result, mockUserCredential);
        verify(firebaseAuthClient.signInWithEmailAndPassword(
                email: _email, password: _password))
            .called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(mockUserCredential);
      });
    });

    test('should fail', () {
      String _email = 'email';
      String _password = 'password';
      final mockUserCredential = MockUserCredential();
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
        verifyNoMoreInteractions(mockUserCredential);
      });
    });
  });

  group('Signout', () {
    test('should signout the user', () {
      final mockUserCredential = MockUserCredential();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.signOut()).thenAnswer((_) => Future.value());

      auth.signOut().then((value) {
        verify(firebaseAuthClient.signOut()).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(mockUserCredential);
      });
    });

    test('should fail', () {
      final mockUserCredential = MockUserCredential();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.signOut())
          .thenAnswer((_) => Future.error('error'));

      auth.signOut().catchError((onError) {
        verify(firebaseAuthClient.signOut()).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(mockUserCredential);
      });
    });
  });

  group('Signup', () {
    test('should register the user', () {
      final mockUserCredential = MockUserCredential();
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      String _email = "email";
      String _password = "password";
      String _name = "name";

      when(firebaseAuthClient.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .thenAnswer((_) => Future.value(mockUserCredential));
      when(mockUserCredential.user).thenReturn(firebaseUser);
      when(firebaseUser.updateProfile(displayName: _name))
          .thenAnswer((_) => Future.value());

      auth.signUp(_email, _password, _name).then((value) {
        verify(firebaseAuthClient.createUserWithEmailAndPassword(
                email: _email, password: _password))
            .called(1);
        verify(mockUserCredential.user).called(1);
        verify(firebaseUser.updateProfile(displayName: _name)).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(mockUserCredential);
        verifyNoMoreInteractions(firebaseUser);
      });
    });

    test('should fail to register the user when create user fails', () {
      final mockUserCredential = MockUserCredential();
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
        verifyNoMoreInteractions(mockUserCredential);
        verifyNoMoreInteractions(firebaseUser);
      });
    });

    test('should fail to register the user when update profile fails', () {
      final mockUserCredential = MockUserCredential();
      final firebaseUser = MockFirebaseUser();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      String _email = "email";
      String _password = "password";
      String _name = "name";

      when(firebaseAuthClient.createUserWithEmailAndPassword(
              email: _email, password: _password))
          .thenAnswer((_) => Future.value(mockUserCredential));
      when(mockUserCredential.user).thenReturn(firebaseUser);
      when(firebaseUser.updateProfile(displayName: _name))
          .thenAnswer((_) => Future.error('error'));

      auth.signUp(_email, _password, _name).catchError((onError) {
        expect(onError.toString(), 'error');
        verify(firebaseAuthClient.createUserWithEmailAndPassword(
                email: _email, password: _password))
            .called(1);
        verify(mockUserCredential.user).called(1);
        verify(firebaseUser.updateProfile(displayName: _name)).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(mockUserCredential);
        verifyNoMoreInteractions(firebaseUser);
      });
    });
  });

  group('Get id token', () {
    test('should return the id token', () {
      final mockUserCredential = MockUserCredential();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      MockFirebaseUser firebaseUser = MockFirebaseUser();
      Auth auth = Auth(firebaseAuthClient);
      String id = 'id';

      when(firebaseAuthClient.currentUser).thenReturn(firebaseUser);
      when(firebaseUser.getIdToken()).thenAnswer((_) => Future.value(id));

      auth.getIdToken().then((value) {
        expect(value, id);

        verify(firebaseUser.getIdToken()).called(1);
        verify(firebaseAuthClient.currentUser).called(1);
        verifyNoMoreInteractions(firebaseUser);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(mockUserCredential);
      });
    });

    test('should throw error if firebase user is null', () {
      final mockUserCredential = MockUserCredential();
      MockFirebaseAuth firebaseAuthClient = MockFirebaseAuth();
      Auth auth = Auth(firebaseAuthClient);

      when(firebaseAuthClient.currentUser).thenReturn(null);

      auth.getIdToken().catchError((error) {
        expect(error.toString(), userIsNullCode);
        verify(firebaseAuthClient.currentUser).called(1);
        verifyNoMoreInteractions(firebaseAuthClient);
        verifyNoMoreInteractions(mockUserCredential);
      });
    });
  });
}
