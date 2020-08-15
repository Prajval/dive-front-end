import 'package:dio/dio.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/register_repo.dart';
import 'package:dive/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

void setUpDependencies() {
  Dio dio = Dio();
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  GetIt.instance.registerSingleton<BaseAuth>(Auth(FirebaseAuth.instance));
  GetIt.instance.registerSingleton<Dio>(dio);
  GetIt.instance.registerSingleton<QuestionsRepository>(
      QuestionsRepository(GetIt.instance<BaseAuth>()));
  GetIt.instance.registerSingleton<RegisterRepository>(
      RegisterRepository(GetIt.instance<BaseAuth>()));
}
