import 'package:dive/repository/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'logger.dart';

bool isUserLoggedIn() {
  UserRepository userRepository = GetIt.instance<UserRepository>();
  User user = userRepository.getCurrentUser();
  if (user != null) {
    getLogger().d(userIsNotNull);
    getLogger().d(userIdIs + user.uid);
    return true;
  } else {
    getLogger().e(errorFetchingUser);
    return false;
  }
}
