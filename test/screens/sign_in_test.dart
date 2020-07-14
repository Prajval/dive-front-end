import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/screens/register.dart';
import 'package:dive/screens/sign_in.dart';
import 'package:dive/utils/dependencies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

class MockAuthResult extends Mock implements AuthResult {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

void main() {
  final mockAuth = MockAuth();

  setUpAll(() {
    setUpDependencies();
    GetIt.instance.allowReassignment = true;
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('should render signin screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SigninScreen(),
    ));

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
    expect(find.text('Login'), findsNWidgets(2));

    expect(find.widgetWithText(FlatButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, 'Forgot password'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, 'SIGN UP'), findsOneWidget);

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(find.widgetWithIcon(TextFormField, Icons.person), findsOneWidget);

    expect(find.text('Don\'t have an account ?'), findsOneWidget);

    expect(find.byType(FlatButton), findsNWidgets(3));
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('should show error when entered email is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SigninScreen(),
    ));

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Login');

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(emailForm, findsOneWidget);

    expect(find.text('Please enter some text'), findsNothing);

    await tester.enterText(emailForm, "");
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter some text'), findsOneWidget);
  });

  testWidgets('should show error when entered email is an invalid email',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SigninScreen(),
    ));

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Login');

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
      home: SigninScreen(),
    ));

    final Finder passwordForm =
        find.widgetWithText(TextFormField, 'Please enter your password');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Login');

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(passwordForm, findsOneWidget);

    expect(find.text('Please enter some password'), findsNothing);

    await tester.enterText(passwordForm, "");
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter some password'), findsOneWidget);
  });

  testWidgets('should navigate to chat screen when sign in is successful',
      (WidgetTester tester) async {
    String email = 'prajval@gmail.com';
    String password = 'password';

    MockQuestionsRepository questionsRepository = MockQuestionsRepository();
    GetIt.instance.registerSingleton<QuestionsRepository>(questionsRepository);

    final mockObserver = MockNavigatorObserver();
    MockAuthResult mockAuthResult = MockAuthResult();
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(mockAuth.signIn(email, password))
        .thenAnswer((_) async => mockAuthResult);
    when(mockAuth.getCurrentUser()).thenAnswer((_) async => mockFirebaseUser);
    when(questionsRepository.getQuestionTree()).thenReturn(getQuestionTree());

    await tester.pumpWidget(MaterialApp(
      home: SigninScreen(
        auth: mockAuth,
      ),
      navigatorObservers: [mockObserver],
    ));

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder passwordForm =
        find.widgetWithText(TextFormField, 'Please enter your password');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Login');

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(emailForm, findsOneWidget);

    await tester.enterText(emailForm, email);
    await tester.enterText(passwordForm, password);

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter some password'), findsNothing);
    expect(find.text('Please enter a valid email'), findsNothing);

    verify(mockObserver.didPush(any, any)).called(1);

    verify(mockAuth.signIn(email, password)).called(1);
    verify(questionsRepository.getQuestionTree()).called(1);
    verifyNoMoreInteractions(mockAuthResult);
    verifyNoMoreInteractions(mockAuth);
    verifyNoMoreInteractions(questionsRepository);
    verifyNoMoreInteractions(mockFirebaseUser);

    expect(find.byType(SigninScreen), findsNothing);
    expect(find.byType(ChatListScreen), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('forgot password should do nothing', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SigninScreen(),
    ));

    final Finder forgotPassword =
        find.widgetWithText(FlatButton, 'Forgot password');

    await tester.tap(forgotPassword);
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
    expect(find.text('Login'), findsNWidgets(2));

    expect(find.widgetWithText(FlatButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, 'Forgot password'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, 'SIGN UP'), findsOneWidget);

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(find.widgetWithIcon(TextFormField, Icons.person), findsOneWidget);

    expect(find.text('Don\'t have an account ?'), findsOneWidget);

    expect(find.byType(FlatButton), findsNWidgets(3));
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('signup should redirect to register screen',
      (WidgetTester tester) async {
    final mockObserver = MockNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      home: SigninScreen(),
      navigatorObservers: [mockObserver],
    ));

    final Finder registerButton = find.widgetWithText(FlatButton, 'SIGN UP');

    expect(find.byType(RegisterScreen), findsNothing);

    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    verify(mockObserver.didPush(any, any));

    expect(find.byType(SigninScreen), findsNothing);
    expect(find.byType(RegisterScreen), findsOneWidget);
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
