import 'package:dio/dio.dart';
import 'package:dive/errors/bad_request.dart';
import 'package:dive/errors/conflict.dart';
import 'package:dive/errors/generic_http_error.dart';
import 'package:dive/errors/server_error.dart';
import 'package:dive/networking/register_request.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/urls.dart';
import 'package:get_it/get_it.dart';

class RegisterRepository {
  final Auth auth;
  final Dio client = GetIt.instance<Dio>();

  RegisterRepository(this.auth);

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
        BadRequest badRequest = BadRequest(badRequestCode);
        getLogger()
            .e(registerUserBackendError + response.statusCode.toString());
        throw badRequest;
      } else if (response.statusCode == 409) {
        Conflict conflict = Conflict(emailAlreadyInUse);
        getLogger()
            .e(registerUserBackendError + response.statusCode.toString());
        throw conflict;
      } else if (response.statusCode == 500) {
        ServerError serverError = ServerError(serverErrorCode);
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
}
