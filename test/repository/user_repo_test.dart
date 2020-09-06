import 'package:dio/dio.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/urls.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements Dio {}

class MockAuth extends Mock implements Auth {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

class MockResponse extends Mock implements Response {}

void main() {
  MockClient client;

  setUpAll(() {
    GetIt.instance.allowReassignment = true;
    client = MockClient();
    GetIt.instance.registerSingleton<Dio>(client);
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  group('user repository', () {
    test('should fail to register if firebase signup fails', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);

      String password = 'password';
      String email = 'email';
      String name = 'name';

      when(auth.signUp(email, password, name))
          .thenAnswer((_) => Future.error('error'));

      repo.registerUser(name, email, password).catchError((onError) {
        expect(onError.toString(), 'error');
      });

      verify(auth.signUp(email, password, name)).called(1);
      verifyNoMoreInteractions(auth);
    });

    test('should fail to register if registration at dive backend fails',
        () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      MockFirebaseUser firebaseUser = MockFirebaseUser();

      String password = 'password';
      String email = 'email';
      String name = 'name';

      when(auth.signUp(email, password, name))
          .thenAnswer((_) => Future.value());
      when(auth.getCurrentUser()).thenReturn(firebaseUser);
      when(firebaseUser.uid).thenReturn('uid');
      when(client.post(REGISTER_USER, data: anyNamed("data")))
          .thenAnswer((_) => Future.error('error'));

      repo.registerUser(name, email, password).catchError((onError) {
        expect(onError.toString(), 'error');

        verify(auth.getCurrentUser()).called(1);
        verify(firebaseUser.uid).called(1);
        verify(client.post(REGISTER_USER, data: anyNamed("data"))).called(1);
        verify(auth.signUp(email, password, name)).called(1);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(firebaseUser);
      });
    });

    test('should register successfully', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      MockFirebaseUser firebaseUser = MockFirebaseUser();
      MockResponse response = MockResponse();

      String password = 'password';
      String email = 'email';
      String name = 'name';

      when(auth.signUp(email, password, name))
          .thenAnswer((_) => Future.value());
      when(auth.getCurrentUser()).thenReturn(firebaseUser);
      when(firebaseUser.uid).thenReturn('uid');
      when(client.post(REGISTER_USER, data: anyNamed("data")))
          .thenAnswer((_) => Future.value(response));
      when(response.statusCode).thenReturn(200);

      repo.registerUser(name, email, password).catchError((onError) {
        expect(onError.toString(), 'error');

        verify(auth.getCurrentUser()).called(1);
        verify(firebaseUser.uid).called(1);
        verify(client.post(REGISTER_USER, data: anyNamed("data"))).called(1);
        verify(auth.signUp(email, password, name)).called(1);
        verify(response.statusCode).called(1);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(firebaseUser);
        verifyNoMoreInteractions(response);
      });
    });

    test('should fail to register with 400 code', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      MockFirebaseUser firebaseUser = MockFirebaseUser();
      MockResponse response = MockResponse();

      String password = 'password';
      String email = 'email';
      String name = 'name';

      when(auth.signUp(email, password, name))
          .thenAnswer((_) => Future.value());
      when(auth.getCurrentUser()).thenReturn(firebaseUser);
      when(firebaseUser.uid).thenReturn('uid');
      when(client.post(REGISTER_USER, data: anyNamed("data")))
          .thenAnswer((_) => Future.value(response));
      when(response.statusCode).thenReturn(400);

      repo.registerUser(name, email, password).catchError((onError) {
        expect(onError.toString(), "BAD_REQUEST");

        verify(auth.getCurrentUser()).called(1);
        verify(firebaseUser.uid).called(1);
        verify(client.post(REGISTER_USER, data: anyNamed("data")))
            .called(greaterThan(0));
        verify(auth.signUp(email, password, name)).called(1);
        verify(response.statusCode).called(3);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(firebaseUser);
        verifyNoMoreInteractions(response);
      });
    });

    test('should fail to register with 409 code', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      MockFirebaseUser firebaseUser = MockFirebaseUser();
      MockResponse response = MockResponse();

      String password = 'password';
      String email = 'email';
      String name = 'name';

      when(auth.signUp(email, password, name))
          .thenAnswer((_) => Future.value());
      when(auth.getCurrentUser()).thenReturn(firebaseUser);
      when(firebaseUser.uid).thenReturn('uid');
      when(client.post(REGISTER_USER, data: anyNamed("data")))
          .thenAnswer((_) => Future.value(response));
      when(response.statusCode).thenReturn(409);

      repo.registerUser(name, email, password).catchError((onError) {
        expect(onError.toString(), "$emailAlreadyInUse");

        verify(auth.getCurrentUser()).called(1);
        verify(firebaseUser.uid).called(1);
        verify(client.post(REGISTER_USER, data: anyNamed("data"))).called(1);
        verify(auth.signUp(email, password, name)).called(1);
        verify(response.statusCode).called(4);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(firebaseUser);
        verifyNoMoreInteractions(response);
      });
    });

    test('should fail to register with 500 code', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      MockFirebaseUser firebaseUser = MockFirebaseUser();
      MockResponse response = MockResponse();

      String password = 'password';
      String email = 'email';
      String name = 'name';

      when(auth.signUp(email, password, name))
          .thenAnswer((_) => Future.value());
      when(auth.getCurrentUser()).thenReturn(firebaseUser);
      when(firebaseUser.uid).thenReturn('uid');
      when(client.post(REGISTER_USER, data: anyNamed("data")))
          .thenAnswer((_) => Future.value(response));
      when(response.statusCode).thenReturn(500);

      repo.registerUser(name, email, password).catchError((onError) {
        expect(onError.toString(), "SERVER_ERROR");

        verify(auth.getCurrentUser()).called(1);
        verify(firebaseUser.uid).called(1);
        verify(client.post(REGISTER_USER, data: anyNamed("data"))).called(1);
        verify(auth.signUp(email, password, name)).called(1);
        verify(response.statusCode).called(5);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(firebaseUser);
        verifyNoMoreInteractions(response);
      });
    });

    test('should fail to register with any other code', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      MockFirebaseUser firebaseUser = MockFirebaseUser();
      MockResponse response = MockResponse();

      String password = 'password';
      String email = 'email';
      String name = 'name';

      when(auth.signUp(email, password, name))
          .thenAnswer((_) => Future.value());
      when(auth.getCurrentUser()).thenReturn(firebaseUser);
      when(firebaseUser.uid).thenReturn('uid');
      when(client.post(REGISTER_USER, data: anyNamed("data")))
          .thenAnswer((_) => Future.value(response));
      when(response.statusCode).thenReturn(504);

      repo.registerUser(name, email, password).catchError((onError) {
        expect(onError.toString(), "504");

        verify(auth.getCurrentUser()).called(1);
        verify(firebaseUser.uid).called(1);
        verify(client.post(REGISTER_USER, data: anyNamed("data"))).called(1);
        verify(auth.signUp(email, password, name)).called(1);
        verify(response.statusCode).called(6);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(firebaseUser);
        verifyNoMoreInteractions(response);
      });
    });
  });
}
