import 'package:dio/dio.dart';
import 'package:dive/base_state.dart';
import 'package:dive/main.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/push_notification/push_notification_service.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements Dio {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockFirebaseUser extends Mock implements User {}

class MockPNS extends Mock implements PushNotificationService {}

void main() {
  final MockQuestionsRepository questionsRepository = MockQuestionsRepository();

  setUpAll(() {
    GetIt.instance.allowReassignment = true;

    MockClient client = MockClient();
    GetIt.instance.registerSingleton<Dio>(client);
    MockUserRepository userRepository = MockUserRepository();
    GetIt.instance.registerSingleton<QuestionsRepository>(questionsRepository);
    GetIt.instance.registerSingleton<UserRepository>(userRepository);
    GetIt.instance
        .registerSingleton<GetLinksStreamWrapper>(GetLinksStreamWrapper());
    GetIt.instance.registerSingleton<PushNotificationService>(MockPNS());
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets(
      'should open sign in screen when app is opened and user is not signed in',
      (WidgetTester tester) async {
    MockUserRepository userRepository = MockUserRepository();
    GetIt.instance.registerSingleton<UserRepository>(userRepository);
    when(userRepository.getCurrentUser()).thenReturn(null);

    await tester.pumpWidget(DiveApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);

    verify(userRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(userRepository);
  });

  testWidgets(
      'should open chat list screen when app is opened and user is signed in',
      (WidgetTester tester) async {
    MockUserRepository userRepository = MockUserRepository();
    MockFirebaseUser user = MockFirebaseUser();
    List<Question> questionTree = new List<Question>();
    QuestionsList questionsList =
        QuestionsList(noQuestionsAskedSoFar: true, list: questionTree);

    GetIt.instance.registerSingleton<UserRepository>(userRepository);
    when(userRepository.getCurrentUser()).thenReturn(user);
    when(user.uid).thenReturn('uid');
    when(questionsRepository.getQuestions())
        .thenAnswer((_) => Future.value(questionsList));

    await tester.pumpWidget(DiveApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);

    verify(user.uid).called(1);
    verify(userRepository.getCurrentUser());
    verify(questionsRepository.getQuestions()).called(1);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(user);
    verifyNoMoreInteractions(questionsRepository);
  });
}
