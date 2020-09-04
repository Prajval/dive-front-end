import 'package:dio/dio.dart';
import 'package:dive/base_state.dart';
import 'package:dive/main.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/register_repo.dart';
import 'package:dive/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

class MockClient extends Mock implements Dio {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

class MockRegisterRepository extends Mock implements RegisterRepository {}

class MockFirebaseUser extends Mock implements User {}

void main() {
  final MockQuestionsRepository questionsRepository = MockQuestionsRepository();

  setUpAll(() {
    MockClient client = MockClient();
    GetIt.instance.registerSingleton<Dio>(client);
    MockRegisterRepository registerRepository = MockRegisterRepository();
    GetIt.instance.registerSingleton<QuestionsRepository>(questionsRepository);
    GetIt.instance.registerSingleton<RegisterRepository>(registerRepository);
    GetIt.instance
        .registerSingleton<GetLinksStreamWrapper>(GetLinksStreamWrapper());
    GetIt.instance.allowReassignment = true;
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets(
      'should open sign in screen when app is opened and user is not signed in',
      (WidgetTester tester) async {
    MockAuth auth = MockAuth();
    GetIt.instance.registerSingleton<BaseAuth>(auth);
    when(auth.getCurrentUser()).thenReturn(null);

    await tester.pumpWidget(DiveApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);

    verify(auth.getCurrentUser()).called(1);
    verifyNoMoreInteractions(auth);
  });

  testWidgets(
      'should open chat list screen when app is opened and user is signed in',
      (WidgetTester tester) async {
    MockAuth auth = MockAuth();
    MockFirebaseUser user = MockFirebaseUser();
    List<Question> questionTree = new List<Question>();
    QuestionsList questionsList =
        QuestionsList(noQuestionsAskedSoFar: true, list: questionTree);

    GetIt.instance.registerSingleton<BaseAuth>(auth);
    when(auth.getCurrentUser()).thenReturn(user);
    when(user.uid).thenReturn('uid');
    when(questionsRepository.getQuestions())
        .thenAnswer((_) => Future.value(questionsList));

    await tester.pumpWidget(DiveApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);

    verify(user.uid).called(1);
    verify(auth.getCurrentUser()).called(1);
    verify(questionsRepository.getQuestions()).called(1);
    verifyNoMoreInteractions(auth);
    verifyNoMoreInteractions(user);
    verifyNoMoreInteractions(questionsRepository);
  });
}
