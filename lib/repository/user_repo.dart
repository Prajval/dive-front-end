import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dive/errors/generic_http_error.dart';
import 'package:dive/networking/register_request.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/push_notification_service.dart';
import 'package:dive/utils/urls.dart';
import 'package:get_it/get_it.dart';

class UserRepository {
  final Auth auth;
  final Dio client = GetIt.instance<Dio>();
  final PushNotificationService pushNotificationService =
      GetIt.instance<PushNotificationService>();

  UserRepository(this.auth);

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

  Future<void> updateUserFcmToken() async {
    Map<String, String> header = {};
    Map<String, dynamic> body = {};
    getLogger().i(updatingFcmTokenForUser);

    return auth.getIdToken().then((idToken) {
      header['uid_token'] = idToken;
      return pushNotificationService.getFcmToken();
    }).then((fcmToken) {
      body['fcm_token'] = fcmToken;
      return client.post(UPDATE_USER_FCM_TOKEN,
          options: Options(headers: header), data: body);
    }).then((response) {
      if (response.statusCode == 200) {
        getLogger().i(successfullyUpdatedFcmTokenForUser);
      } else {
        throw GenericError(
            updatingFcmTokenForUserFailed + response.statusCode.toString());
      }
    }).catchError((error) {
      getLogger().e(error.toString());
      throw error;
    });
  }
}
