import 'package:dio/dio.dart';
import 'package:dive/base_state.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/push_notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

void setUpDependencies() {
  Dio dio = Dio();
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  GetIt.instance.registerSingleton<BaseAuth>(Auth(FirebaseAuth.instance));

  GetIt.instance
      .registerSingleton<PushNotificationService>(PushNotificationService());

  final PushNotificationService _pushNotificationService =
      GetIt.instance<PushNotificationService>();
  _pushNotificationService.initialise();

  GetIt.instance.registerSingleton<Dio>(dio);

  GetIt.instance.registerSingleton<UserRepository>(
      UserRepository(GetIt.instance<BaseAuth>()));

  GetIt.instance.registerSingleton<QuestionsRepository>(
      QuestionsRepository(GetIt.instance<UserRepository>()));
  GetIt.instance
      .registerSingleton<GetLinksStreamWrapper>(GetLinksStreamWrapper());
}
