import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/screens/ask_question.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/screens/question_answer.dart';
import 'package:dive/screens/question_with_related_questions.dart';
import 'package:dive/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

void main() {
  testWidgets('should render chat list screen', (WidgetTester tester) async {
    MockAuth auth = MockAuth();
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();

    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<QuestionTree> questionTree = [
      QuestionTree(question: question, answer: answer, time: time)
    ];

    when(questionsRepository.getQuestionTree()).thenReturn(questionTree);

    await tester.pumpWidget(MaterialApp(
      home: ChatListScreen(
        auth: auth,
        questionsRepository: questionsRepository,
      ),
    ));

    expect(find.widgetWithText(AppBar, 'Questions'), findsOneWidget);
    expect(find.widgetWithIcon(AppBar, Icons.person), findsOneWidget);
    expect(
        find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.widgetWithText(ListTile, '$question'), findsOneWidget);
    expect(find.widgetWithText(ListTile, '$time'), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);

    verify(questionsRepository.getQuestionTree()).called(1);
    verifyNoMoreInteractions(auth);
    verifyNoMoreInteractions(questionsRepository);
  });

  testWidgets(
      'should render chat list screen with specific number of questions',
      (WidgetTester tester) async {
    MockAuth auth = MockAuth();
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();

    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<QuestionTree> questionTree = [
      QuestionTree(question: question, answer: answer, time: time),
      QuestionTree(question: question, answer: answer, time: time),
      QuestionTree(question: question, answer: answer, time: time),
      QuestionTree(question: question, answer: answer, time: time)
    ];

    when(questionsRepository.getQuestionTree()).thenReturn(questionTree);

    await tester.pumpWidget(MaterialApp(
      home: ChatListScreen(
        auth: auth,
        questionsRepository: questionsRepository,
      ),
    ));

    expect(find.widgetWithText(AppBar, 'Questions'), findsOneWidget);
    expect(find.widgetWithIcon(AppBar, Icons.person), findsOneWidget);
    expect(
        find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);

    expect(find.byType(ListTile), findsNWidgets(questionTree.length));

    verify(questionsRepository.getQuestionTree()).called(1);
    verifyNoMoreInteractions(auth);
    verifyNoMoreInteractions(questionsRepository);
  });

  testWidgets(
      'should navigate to question answer screen when the question is clicked and answer is available to the question',
      (WidgetTester tester) async {
    MockAuth auth = MockAuth();
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    List<RelatedQuestionAnswer> relatedQuestionsAnswersList = [
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

    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<QuestionTree> questionTree = [
      QuestionTree(
          question: question + '1',
          relatedQuestionAnswer: relatedQuestionsAnswersList,
          time: time),
      QuestionTree(question: question + '2', answer: answer, time: time)
    ];

    when(questionsRepository.getQuestionTree()).thenReturn(questionTree);

    await tester.pumpWidget(MaterialApp(
      home: ChatListScreen(
        auth: auth,
        questionsRepository: questionsRepository,
      ),
      navigatorObservers: [navigatorObserver],
    ));

    expect(find.widgetWithText(AppBar, 'Questions'), findsOneWidget);
    expect(find.widgetWithIcon(AppBar, Icons.person), findsOneWidget);
    expect(
        find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(QuestionAnswerScreen), findsNothing);
    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsNothing);

    final Finder questionWithAnswer =
        find.widgetWithText(ListTile, '$question' + '2');
    await tester.tap(questionWithAnswer);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPush(any, any));

    expect(find.widgetWithText(AppBar, 'Questions'), findsOneWidget);
    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(QuestionAnswerScreen), findsOneWidget);
    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsNothing);

    verify(questionsRepository.getQuestionTree()).called(1);
    verifyNoMoreInteractions(auth);
    verifyNoMoreInteractions(questionsRepository);
  });

  testWidgets(
      'should navigate to question with related questions screen when the question is clicked and answer is not available to the question',
      (WidgetTester tester) async {
    MockAuth auth = MockAuth();
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    List<RelatedQuestionAnswer> relatedQuestionsAnswersList = [
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

    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<QuestionTree> questionTree = [
      QuestionTree(
          question: question + '1',
          relatedQuestionAnswer: relatedQuestionsAnswersList,
          time: time),
      QuestionTree(question: question + '2', answer: answer, time: time)
    ];

    when(questionsRepository.getQuestionTree()).thenReturn(questionTree);

    await tester.pumpWidget(MaterialApp(
      home: ChatListScreen(
        auth: auth,
        questionsRepository: questionsRepository,
      ),
      navigatorObservers: [navigatorObserver],
    ));

    expect(find.widgetWithText(AppBar, 'Questions'), findsOneWidget);
    expect(find.widgetWithIcon(AppBar, Icons.person), findsOneWidget);
    expect(
        find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(QuestionAnswerScreen), findsNothing);
    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsNothing);

    final Finder questionWithAnswer =
        find.widgetWithText(ListTile, '$question' + '1');
    await tester.tap(questionWithAnswer);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPush(any, any));

    expect(find.widgetWithText(AppBar, 'Related Questions'), findsOneWidget);
    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(QuestionAnswerScreen), findsNothing);
    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsOneWidget);

    verify(questionsRepository.getQuestionTree()).called(1);
    verifyNoMoreInteractions(auth);
    verifyNoMoreInteractions(questionsRepository);
  });

  testWidgets(
      'should navigate to Ask Question screen when ask question floating action button is tapped',
      (WidgetTester tester) async {
    MockAuth auth = MockAuth();
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<QuestionTree> questionTree = [
      QuestionTree(question: question, answer: answer, time: time)
    ];

    when(questionsRepository.getQuestionTree()).thenReturn(questionTree);

    await tester.pumpWidget(MaterialApp(
      home: ChatListScreen(
        auth: auth,
        questionsRepository: questionsRepository,
      ),
      navigatorObservers: [navigatorObserver],
    ));

    expect(find.byType(AskQuestionScreen), findsNothing);
    expect(find.byType(ChatListScreen), findsOneWidget);

    final Finder addQuestionButton =
        find.widgetWithIcon(FloatingActionButton, Icons.add);
    await tester.tap(addQuestionButton);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPush(any, any));

    expect(find.byType(AskQuestionScreen), findsOneWidget);
    expect(find.byType(ChatListScreen), findsNothing);

    verify(questionsRepository.getQuestionTree()).called(1);
    verifyNoMoreInteractions(auth);
    verifyNoMoreInteractions(questionsRepository);
  });

  testWidgets('should navigate to profile screen when profile is tapped',
      (WidgetTester tester) async {
    MockAuth auth = MockAuth();
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();
    MockFirebaseUser firebaseUser = MockFirebaseUser();

    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<QuestionTree> questionTree = [
      QuestionTree(question: question, answer: answer, time: time)
    ];

    when(questionsRepository.getQuestionTree()).thenReturn(questionTree);
    when(auth.isEmailVerified()).thenAnswer((_) async => true);
    when(auth.getCurrentUser()).thenAnswer((_) async => firebaseUser);
    when(firebaseUser.displayName).thenReturn('name');

    await tester.pumpWidget(MaterialApp(
      home: ChatListScreen(
        auth: auth,
        questionsRepository: questionsRepository,
      ),
      navigatorObservers: [navigatorObserver],
    ));

    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(ChatListScreen), findsOneWidget);

    final Finder profileButton =
        find.widgetWithIcon(CircleAvatar, Icons.person);
    await tester.tap(profileButton);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPush(any, any));

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(ChatListScreen), findsNothing);

    verify(questionsRepository.getQuestionTree()).called(1);
    verify(auth.isEmailVerified()).called(1);
    verify(auth.getCurrentUser()).called(1);
    verify(firebaseUser.displayName).called(1);
    verifyNoMoreInteractions(auth);
    verifyNoMoreInteractions(firebaseUser);
    verifyNoMoreInteractions(questionsRepository);
  });
}
