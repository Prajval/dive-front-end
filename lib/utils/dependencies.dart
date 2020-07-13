import 'package:dive/repository/questions_repo.dart';
import 'package:dive/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

void setUpDependencies() {
  GetIt.instance.registerSingleton<BaseAuth>(Auth(FirebaseAuth.instance));
  GetIt.instance.registerSingleton<QuestionsRepository>(QuestionsRepository());
}
