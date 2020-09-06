import 'package:dio/dio.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/push_notification_service.dart';
import 'package:dive/utils/urls.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements Dio {}

class MockAuth extends Mock implements Auth {}

class MockFirebaseUser extends Mock implements User {}

class MockResponse extends Mock implements Response {}

class MockUserCredential extends Mock implements UserCredential {}

class MockPushNotificationService extends Mock
    implements PushNotificationService {}

void main() {
  MockClient client;

  final mockPNS = MockPushNotificationService();

  setUpAll(() {
    GetIt.instance.allowReassignment = true;
    client = MockClient();
    GetIt.instance.registerSingleton<Dio>(client);
    GetIt.instance.registerSingleton<PushNotificationService>(mockPNS);
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  group('user repository register user', () {
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

  group('user repository update fcm token', () {
    test('should fail to update fcm token if fetching user token fails',
        () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);

      when(auth.getIdToken()).thenAnswer((_) => Future.error('error'));

      repo.updateUserFcmToken().catchError((onError) {
        expect(onError.toString(), 'error');

        verify(auth.getIdToken()).called(1);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(mockPNS);
        verifyNoMoreInteractions(client);
      });
    });

    test('should fail to update fcm token if fetching fcm token fails',
        () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);

      when(auth.getIdToken()).thenAnswer((_) => Future.value('token'));
      when(mockPNS.getFcmToken()).thenAnswer((_) => Future.error('error'));

      repo.updateUserFcmToken().catchError((onError) {
        expect(onError.toString(), 'error');

        verify(auth.getIdToken()).called(1);
        verify(mockPNS.getFcmToken()).called(1);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(mockPNS);
        verifyNoMoreInteractions(client);
      });
    });

    test('should fail to update fcm token if there is an error in dive backend',
        () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);

      when(auth.getIdToken()).thenAnswer((_) => Future.value('auth_token'));
      when(mockPNS.getFcmToken()).thenAnswer((_) => Future.value('fcm_token'));
      when(client.post(UPDATE_USER_FCM_TOKEN,
              options: anyNamed('options'), data: anyNamed('data')))
          .thenAnswer((_) => Future.error('error'));

      repo.updateUserFcmToken().catchError((onError) {
        expect(onError.toString(), 'error');

        verify(auth.getIdToken()).called(1);
        verify(mockPNS.getFcmToken()).called(1);
        verify(client.post(UPDATE_USER_FCM_TOKEN,
                options: anyNamed('options'), data: anyNamed('data')))
            .called(1);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(mockPNS);
        verifyNoMoreInteractions(client);
      });
    });

    test('should fail to update fcm token if response code is not success',
        () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      MockResponse response = MockResponse();

      when(auth.getIdToken()).thenAnswer((_) => Future.value('auth_token'));
      when(mockPNS.getFcmToken()).thenAnswer((_) => Future.value('fcm_token'));
      when(client.post(UPDATE_USER_FCM_TOKEN,
              options: anyNamed('options'), data: anyNamed('data')))
          .thenAnswer((_) => Future.value(response));
      when(response.statusCode).thenReturn(401);

      repo.updateUserFcmToken().catchError((onError) {
        expect(onError.toString(), updatingFcmTokenForUserFailed + "401");

        verify(auth.getIdToken()).called(1);
        verify(mockPNS.getFcmToken()).called(1);
        verify(client.post(UPDATE_USER_FCM_TOKEN,
                options: anyNamed('options'), data: anyNamed('data')))
            .called(1);
        verify(response.statusCode).called(2);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(mockPNS);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(response);
      });
    });

    test('should update fcm token', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      MockResponse response = MockResponse();

      when(auth.getIdToken()).thenAnswer((_) => Future.value('auth_token'));
      when(mockPNS.getFcmToken()).thenAnswer((_) => Future.value('fcm_token'));
      when(client.post(UPDATE_USER_FCM_TOKEN,
              options: anyNamed('options'), data: anyNamed('data')))
          .thenAnswer((_) => Future.value(response));
      when(response.statusCode).thenReturn(200);

      repo.updateUserFcmToken().then((_) {
        verify(auth.getIdToken()).called(1);
        verify(mockPNS.getFcmToken()).called(1);
        verify(client.post(UPDATE_USER_FCM_TOKEN,
                options: anyNamed('options'), data: anyNamed('data')))
            .called(1);
        verify(response.statusCode).called(1);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(mockPNS);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(response);
      });
    });
  });

  group('get current user', () {
    test('should return current user', () async {
      MockAuth auth = MockAuth();
      MockFirebaseUser user = MockFirebaseUser();
      UserRepository repo = UserRepository(auth);

      when(auth.getCurrentUser()).thenReturn(user);

      expect(repo.getCurrentUser(), user);

      verify(auth.getCurrentUser()).called(1);
      verifyNoMoreInteractions(auth);
      verifyNoMoreInteractions(user);
    });

    test('should return null', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);

      when(auth.getCurrentUser()).thenReturn(null);

      expect(repo.getCurrentUser(), null);

      verify(auth.getCurrentUser()).called(1);
      verifyNoMoreInteractions(auth);
    });
  });

  group('sign in', () {
    test('should sign in user', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      MockUserCredential userCredential = MockUserCredential();
      String email = "email";
      String password = "password";

      when(auth.signIn(email, password))
          .thenAnswer((_) => Future.value(userCredential));

      repo.signIn(email, password).then((result) {
        expect(result, userCredential);

        verify(auth.signIn(email, password)).called(1);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(userCredential);
      });
    });

    test('should propagate error if signin fails', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      String email = "email";
      String password = "password";

      when(auth.signIn(email, password))
          .thenAnswer((_) => Future.error("error"));

      repo.signIn(email, password).catchError((error) {
        expect(error, "error");

        verify(auth.signIn(email, password)).called(1);
        verifyNoMoreInteractions(auth);
      });
    });
  });

  group('sign out', () {
    test('should sign out user', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);

      when(auth.signOut()).thenAnswer((_) => Future.value());

      repo.signOut().then((_) {
        verify(auth.signOut()).called(1);
        verifyNoMoreInteractions(auth);
      });
    });

    test('should propagate error if signout fails', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);

      when(auth.signOut()).thenAnswer((_) => Future.error("error"));

      repo.signOut().catchError((error) {
        expect(error, "error");

        verify(auth.signOut()).called(1);
        verifyNoMoreInteractions(auth);
      });
    });
  });

  group('is email verified', () {
    test('should return true if email is verified', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);

      when(auth.isEmailVerified()).thenReturn(true);

      expect(repo.isEmailVerified(), true);

      verify(auth.isEmailVerified()).called(1);
      verifyNoMoreInteractions(auth);
    });

    test('should return false if email is not verified', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);

      when(auth.isEmailVerified()).thenReturn(false);

      expect(repo.isEmailVerified(), false);

      verify(auth.isEmailVerified()).called(1);
      verifyNoMoreInteractions(auth);
    });
  });

  group('send email verification', () {
    test('should send email verification', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);

      when(auth.sendEmailVerification()).thenAnswer((_) => Future.value());

      repo.sendEmailVerification().then((_) {
        verify(auth.sendEmailVerification()).called(1);
        verifyNoMoreInteractions(auth);
      });
    });

    test('should propagate error if it fails', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);

      when(auth.sendEmailVerification())
          .thenAnswer((_) => Future.error("error"));

      repo.sendEmailVerification().catchError((error) {
        expect(error, "error");

        verify(auth.sendEmailVerification()).called(1);
        verifyNoMoreInteractions(auth);
      });
    });
  });

  group('get auth token', () {
    test('should return auth token', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      String authToken = "auth_token";

      when(auth.getIdToken()).thenAnswer((_) => Future.value(authToken));

      repo.getAuthToken().then((result) {
        expect(result, authToken);

        verify(auth.getIdToken()).called(1);
        verifyNoMoreInteractions(auth);
      });
    });

    test('should propagate error if it fails', () async {
      MockAuth auth = MockAuth();
      UserRepository repo = UserRepository(auth);
      String authToken = "auth_token";

      when(auth.getIdToken()).thenAnswer((_) => Future.error("error"));

      repo.getAuthToken().catchError((error) {
        expect(error, "error");

        verify(auth.getIdToken()).called(1);
        verifyNoMoreInteractions(auth);
      });
    });
  });
}
