import 'package:dive/errors/generic_http_error.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/register_repo.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/register.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockAuthResult extends Mock implements AuthResult {}

class MockAuthFirebaseUser extends Mock implements FirebaseUser {}

class MockClient extends Mock implements Client {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

class MockRegisterRepository extends Mock implements RegisterRepository {}

void main() {
  setUpAll(() {
    GetIt.instance.allowReassignment = true;
    MockClient client = MockClient();
    GetIt.instance.registerSingleton<Client>(client);
    GetIt.instance.registerSingleton<BaseAuth>(MockAuth());
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('should render register screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(),
    ));
    await tester.pumpAndSettle();

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

    final mockObserver = MockNavigatorObserver();
    final mockRegisterRepo = MockRegisterRepository();

    when(mockRegisterRepo.registerUser(name, email, password))
        .thenAnswer((_) async => null);
    when(questionsRepository.getQuestions())
        .thenAnswer((_) async => getQuestionTree());

    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(
        registerRepo: mockRegisterRepo,
      ),
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    verify(mockRegisterRepo.registerUser(name, email, password)).called(1);
    verify(questionsRepository.getQuestions()).called(1);
    verifyNoMoreInteractions(questionsRepository);
    verifyNoMoreInteractions(mockRegisterRepo);
  });

  testWidgets('should show weak password error if password is weak',
      (WidgetTester tester) async {
    String name = "name";
    String password = "password";
    String email = "prajval@gmail.com";

    final mockObserver = MockNavigatorObserver();
    final mockRegisterRepo = MockRegisterRepository();

    when(mockRegisterRepo.registerUser(name, email, password))
        .thenAnswer((_) => Future.error(GenericError('ERROR_WEAK_PASSWORD')));

    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(
        registerRepo: mockRegisterRepo,
      ),
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.byType(ChatListScreen), findsNothing);

    expect(find.widgetWithText(AlertDialog, '$weakPasswordMessage'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    verify(mockRegisterRepo.registerUser(name, email, password)).called(1);
    verifyNoMoreInteractions(mockRegisterRepo);
  });

  testWidgets('should show invalid email error if password is weak',
      (WidgetTester tester) async {
    String name = "name";
    String password = "password";
    String email = "prajval@gmail.com";

    final mockObserver = MockNavigatorObserver();
    final mockRegisterRepo = MockRegisterRepository();

    when(mockRegisterRepo.registerUser(name, email, password))
        .thenAnswer((_) => Future.error(GenericError('ERROR_INVALID_EMAIL')));

    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(
        registerRepo: mockRegisterRepo,
      ),
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.byType(ChatListScreen), findsNothing);

    expect(find.widgetWithText(AlertDialog, '$malformedEmailMessage'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    verify(mockRegisterRepo.registerUser(name, email, password)).called(1);
    verifyNoMoreInteractions(mockRegisterRepo);
  });

  testWidgets('should show email already in use error if password is weak',
      (WidgetTester tester) async {
    String name = "name";
    String password = "password";
    String email = "prajval@gmail.com";

    final mockObserver = MockNavigatorObserver();
    final mockRegisterRepo = MockRegisterRepository();

    when(mockRegisterRepo.registerUser(name, email, password)).thenAnswer(
        (_) => Future.error(GenericError('ERROR_EMAIL_ALREADY_IN_USE')));

    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(
        registerRepo: mockRegisterRepo,
      ),
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.byType(ChatListScreen), findsNothing);

    expect(find.widgetWithText(AlertDialog, '$emailAlreadyInUseMessage'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    verify(mockRegisterRepo.registerUser(name, email, password)).called(1);
    verifyNoMoreInteractions(mockRegisterRepo);
  });

  testWidgets('should show general error if registration fails otherwise',
      (WidgetTester tester) async {
    String name = "name";
    String password = "password";
    String email = "prajval@gmail.com";

    final mockObserver = MockNavigatorObserver();
    final mockRegisterRepo = MockRegisterRepository();

    when(mockRegisterRepo.registerUser(name, email, password))
        .thenAnswer((_) => Future.error(GenericError('general error')));

    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(
        registerRepo: mockRegisterRepo,
      ),
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.byType(ChatListScreen), findsNothing);

    expect(
        find.widgetWithText(AlertDialog, '$defaultErrorMessageForRegistration'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    verify(mockRegisterRepo.registerUser(name, email, password)).called(1);
    verifyNoMoreInteractions(mockRegisterRepo);
  });

  testWidgets('should close error dialog when ok is pressed',
      (WidgetTester tester) async {
    String name = "name";
    String password = "password";
    String email = "prajval@gmail.com";

    final mockObserver = MockNavigatorObserver();
    final mockRegisterRepo = MockRegisterRepository();

    when(mockRegisterRepo.registerUser(name, email, password))
        .thenAnswer((_) => Future.error(GenericError('general error')));

    await tester.pumpWidget(MaterialApp(
      home: RegisterScreen(
        registerRepo: mockRegisterRepo,
      ),
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.byType(ChatListScreen), findsNothing);

    expect(
        find.widgetWithText(AlertDialog, '$defaultErrorMessageForRegistration'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    final Finder okButton = find.widgetWithText(FlatButton, '$ok');
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsNothing);

    verify(mockRegisterRepo.registerUser(name, email, password)).called(1);
    verifyNoMoreInteractions(mockRegisterRepo);
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
