import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/root.dart';
import 'package:dive/screens/sign_in.dart';
import 'package:dive/utils/dependencies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

void main() {
  setUpAll(() {
    setUpDependencies();
    GetIt.instance.allowReassignment = true;
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  final auth = MockAuth();

  testWidgets('should redirect to chat screen if user is logged in',
      (WidgetTester tester) async {
    final auth = MockAuth();
    final firebaseUser = MockFirebaseUser();
    String uid = 'uid';

    MockQuestionsRepository questionsRepository = MockQuestionsRepository();
    GetIt.instance.registerSingleton<QuestionsRepository>(questionsRepository);

    when(questionsRepository.getQuestionTree()).thenReturn(getQuestionTree());
    when(auth.getCurrentUser()).thenAnswer((_) async => firebaseUser);
    when(firebaseUser.uid).thenReturn(uid);

    await tester.pumpWidget(MaterialApp(
      home: Root(
        auth: auth,
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsOneWidget);
    expect(find.byType(SigninScreen), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    verify(auth.getCurrentUser()).called(1);
    verify(questionsRepository.getQuestionTree()).called(1);
    verify(firebaseUser.uid).called(2);
    verifyNoMoreInteractions(questionsRepository);
    verifyNoMoreInteractions(auth);
    verifyNoMoreInteractions(firebaseUser);
  });

  testWidgets('should redirect to Signin screen if user is not logged in',
      (WidgetTester tester) async {
    when(auth.getCurrentUser()).thenAnswer((_) async => null);

    await tester.pumpWidget(MaterialApp(
      home: Root(
        auth: auth,
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(SigninScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    verify(auth.getCurrentUser()).called(1);
    verifyNoMoreInteractions(auth);
  });

  testWidgets('should redirect to Signin screen if there is an error',
      (WidgetTester tester) async {
    when(auth.getCurrentUser()).thenAnswer((_) => new Future.error('error'));

    await tester.pumpWidget(MaterialApp(
      home: Root(
        auth: auth,
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(SigninScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    verify(auth.getCurrentUser()).called(1);
    verifyNoMoreInteractions(auth);
  });

  testWidgets('should show loader before sign-in details are fetched',
      (WidgetTester tester) async {
    when(auth.getCurrentUser()).thenAnswer((_) => new Future.error('error'));

    await tester.pumpWidget(MaterialApp(
      home: Root(
        auth: auth,
      ),
    ));

    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(SigninScreen), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    verify(auth.getCurrentUser()).called(1);
    verifyNoMoreInteractions(auth);
  });
}

List<QuestionTree> getQuestionTree() {
  List<RelatedQuestionAnswer> _relatedQuestionsAnswersList = [
    RelatedQuestionAnswer(
        question: "How can depression be treated?",
        answer: "It can be treated in a variety of ways."),
    RelatedQuestionAnswer(
        question: "How do we know who is a good doctor?",
        answer: "Ah! That's a tough question."),
    RelatedQuestionAnswer(
        question: "How long does depression last?",
        answer: "It varies in each individual and to various degrees.")
  ];

  List<QuestionTree> _questionTree = [
    QuestionTree(
        question: "Can depression be treated?",
        answer: "Yes, it can be treated!",
        time: "5d ago"),
    QuestionTree(
        question: "How long does depression last?",
        relatedQuestionAnswer: _relatedQuestionsAnswersList,
        time: "4d ago"),
    QuestionTree(
        question:
            "Let me now ask a really really long question. Well. I don't know. I know. "
            "I mean I know but don't know how to ask. But here is the thing that i really want to ask."
            "How do we know who is a good doctor?",
        answer: "How about googling the same for now.",
        time: "55 mins ago"),
    QuestionTree(
        question: "Is depression genetic?",
        relatedQuestionAnswer: _relatedQuestionsAnswersList,
        time: "33 mins ago")
  ];

  return _questionTree;
}
