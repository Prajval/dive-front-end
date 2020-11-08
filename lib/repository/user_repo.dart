import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dive/errors/generic_http_error.dart';
import 'package:dive/networking/register_request.dart';
import 'package:dive/push_notification/push_notification_service.dart';
import 'package:dive/repository/local_storage/cache_keys.dart';
import 'package:dive/repository/local_storage/cache_repo.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/urls.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

class UserRepository {
  final Auth auth;
  final Dio client = GetIt.instance<Dio>();
  final PushNotificationService pushNotificationService =
      GetIt.instance<PushNotificationService>();
  final CacheRepo cacheRepo = GetIt.instance<CacheRepo>();

  UserRepository(this.auth);

  User getCurrentUser() {
    return auth.getCurrentUser();
  }

  Future<void> registerUser(String name, String email, String password) {
    getLogger().d(registerUserInitiation);

    return auth
        .signUp(email, password, name)
        .then((_) => auth.getCurrentUser())
        .then((user) {
      RegisterRequest registerRequest = RegisterRequest(name, email, user.uid);

      return client.post(REGISTER_USER, data: registerRequest);
    }).then((response) {
      if (response.statusCode == 200) {
        getLogger().d(registerUserSuccess);
        updateUserFcmToken();
      } else if (response.statusCode == 400) {
        GenericError badRequest = GenericError(badRequestCode);
        getLogger()
            .e(registerUserBackendError + response.statusCode.toString());
        throw badRequest;
      } else if (response.statusCode == 409) {
        GenericError conflict = GenericError(emailAlreadyInUse);
        getLogger()
            .e(registerUserBackendError + response.statusCode.toString());
        throw conflict;
      } else if (response.statusCode == 500) {
        GenericError serverError = GenericError(serverErrorCode);
        getLogger()
            .e(registerUserBackendError + response.statusCode.toString());
        throw serverError;
      } else {
        GenericError error = GenericError(response.statusCode.toString());
        getLogger()
            .e(registerUserBackendError + response.statusCode.toString());
        throw error;
      }
    }).catchError((error) {
      getLogger().e(registerUserError);
      getLogger().e(error.toString());
      throw error;
    });
  }

  Future<UserCredential> signIn(String email, String password) {
    return auth.signIn(email, password).then((userCredential) {
      updateUserFcmToken();
      return userCredential;
    });
  }

  Future<void> signOut() {
    cacheRepo.onSignOut();
    return auth.signOut();
  }

  bool isEmailVerified() {
    return auth.isEmailVerified();
  }

  Future<void> sendEmailVerification() {
    return auth.sendEmailVerification();
  }

  Future<String> getAuthToken() {
    return auth.getIdToken();
  }

  Future<void> updateUserFcmToken() async {
    Map<String, String> header = {};
    Map<String, dynamic> body = {};
    getLogger().i(updatingFcmTokenForUser);

    return pushNotificationService.getFcmToken().then((fcmToken) {
      if (cacheRepo.getData(CacheKeys.fcmToken) != fcmToken) {
        return auth.getIdToken().then((idToken) {
          header['uid_token'] = idToken;
          body['fcm_token'] = fcmToken;
          return client.post(UPDATE_USER_FCM_TOKEN,
              options: Options(headers: header), data: body);
        }).then((response) {
          if (response.statusCode == 200) {
            getLogger().i(successfullyUpdatedFcmTokenForUser);
            cacheRepo.putData(key: CacheKeys.fcmToken, data: fcmToken);
          } else {
            throw GenericError(
                updatingFcmTokenForUserFailed + response.statusCode.toString());
          }
        }).catchError((error) {
          getLogger().e(error.toString());
          throw error;
        });
      } else {
        getLogger().i(fcmTokenHasNotChanged);
        return Future.value();
      }
    }).catchError((error) {
      getLogger().e(error.toString());
      throw error;
    });
  }

  Future<void> resetPassword(String email) {
    return auth.resetPassword(email);
  }

  Future<void> updateProfile(String newEmail, String newName) {
    return auth.updateEmail(newEmail).then((_) => auth.updateName(newName));
  }
}
