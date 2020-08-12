import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/register_repo.dart';
import 'package:dive/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

void setUpDependencies() {
  GetIt.instance.registerSingleton<BaseAuth>(Auth(FirebaseAuth.instance));
  GetIt.instance.registerSingleton<Client>(Client());
  GetIt.instance.registerSingleton<QuestionsRepository>(
      QuestionsRepository(GetIt.instance<BaseAuth>()));
  GetIt.instance.registerSingleton<RegisterRepository>(
      RegisterRepository(GetIt.instance<BaseAuth>()));
}
