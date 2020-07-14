import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/screens/register.dart';
import 'package:dive/utils/dependencies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockAuthResult extends Mock implements AuthResult {}

class MockAuthFirebaseUser extends Mock implements FirebaseUser {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

void main() {
  setUpAll(() {
    setUpDependencies();
    GetIt.instance.allowReassignment = true;
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('should render register screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(),
    ));

    expect(find.text('Enter your full name'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Choose a password'), findsOneWidget);
    expect(find.text('Register'), findsNWidgets(2));
    expect(find.widgetWithText(FlatButton, 'Register'), findsOneWidget);

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(find.widgetWithIcon(TextFormField, Icons.person), findsNWidgets(2));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(FlatButton), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });

  testWidgets('should show error when entered email is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(),
    ));

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Register');

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(emailForm, findsOneWidget);

    expect(find.text('Please enter some text'), findsNothing);

    await tester.enterText(emailForm, "");
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter some text'), findsWidgets);
  });

  testWidgets('should show error when entered email is an invalid email',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(),
    ));

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Register');

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(emailForm, findsOneWidget);

    expect(find.text('Please enter some text'), findsNothing);
    expect(find.text('Please enter a valid email'), findsNothing);

    await tester.enterText(emailForm, "email");
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('should show error when entered password is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(),
    ));

    final Finder passwordForm =
        find.widgetWithText(TextFormField, 'Choose a password');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Register');

    expect(find.widgetWithIcon(TextFormField, Icons.person), findsWidgets);
    expect(passwordForm, findsOneWidget);

    expect(find.text('Please enter some password'), findsNothing);

    await tester.enterText(passwordForm, "");
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter some password'), findsOneWidget);
  });

  testWidgets('should show error when entered name is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(),
    ));

    final Finder passwordForm =
        find.widgetWithText(TextFormField, 'Enter your full name');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Register');

    expect(find.widgetWithIcon(TextFormField, Icons.person), findsWidgets);
    expect(passwordForm, findsOneWidget);

    expect(find.text('Please enter some text'), findsNothing);

    await tester.enterText(passwordForm, "");
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter some text'), findsWidgets);
  });

  testWidgets('should redirect to chat screen if registration is successful',
      (WidgetTester tester) async {
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();
    GetIt.instance.registerSingleton<QuestionsRepository>(questionsRepository);

    String name = "name";
    String password = "password";
    String email = "prajval@gmail.com";

    final mockAuth = MockAuth();
    final mockAuthResult = MockAuthResult();
    final mockObserver = MockNavigatorObserver();

    when(mockAuth.signUp(email, password, name))
        .thenAnswer((_) async => mockAuthResult);
    when(questionsRepository.getQuestionTree()).thenReturn(getQuestionTree());

    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(
        auth: mockAuth,
      ),
      navigatorObservers: [mockObserver],
    ));

    final Finder nameForm =
        find.widgetWithText(TextFormField, 'Enter your full name');
    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder passwordForm =
        find.widgetWithText(TextFormField, 'Choose a password');
    final Finder registerButton = find.widgetWithText(FlatButton, 'Register');

    expect(find.byType(ChatListScreen), findsNothing);

    await tester.enterText(nameForm, name);
    await tester.enterText(emailForm, email);
    await tester.enterText(passwordForm, password);

    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter some password'), findsNothing);
    expect(find.text('Please enter a valid email'), findsNothing);
    expect(find.text('Please enter some text'), findsNothing);
    expect(find.byType(ChatListScreen), findsOneWidget);

    verify(mockObserver.didPush(any, any));

    verify(mockAuth.signUp(email, password, name)).called(1);
    verify(questionsRepository.getQuestionTree()).called(1);
    verifyNoMoreInteractions(questionsRepository);
    verifyNoMoreInteractions(mockAuth);
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
