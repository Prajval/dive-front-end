import 'package:dio/dio.dart';
import 'package:dive/base_state.dart';
import 'package:dive/errors/generic_http_error.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/router/router.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/screens/bottom_nav_bar/navigation_provider.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/forgot_password.dart';
import 'package:dive/screens/register.dart';
import 'package:dive/screens/sign_in.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockUserCredential extends Mock implements UserCredential {}

class MockFirebaseUser extends Mock implements User {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

class MockClient extends Mock implements Dio {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  final userRepository = MockUserRepository();

  setUpAll(() {
    MockClient client = MockClient();
    GetIt.instance.registerSingleton<Dio>(client);
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();
    GetIt.instance.registerSingleton<QuestionsRepository>(questionsRepository);
    GetIt.instance.registerSingleton<UserRepository>(userRepository);
    GetIt.instance
        .registerSingleton<GetLinksStreamWrapper>(GetLinksStreamWrapper());
    GetIt.instance.allowReassignment = true;
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('should render signin screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SigninScreen(userRepository),
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
      home: SigninScreen(userRepository),
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
      home: SigninScreen(userRepository),
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
      home: SigninScreen(userRepository),
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

  testWidgets('should navigate to home screen when sign in is successful',
      (WidgetTester tester) async {
    String email = 'prajval@gmail.com';
    String password = 'password';

    MockQuestionsRepository questionsRepository = MockQuestionsRepository();
    GetIt.instance.registerSingleton<QuestionsRepository>(questionsRepository);

    final mockObserver = MockNavigatorObserver();
    MockUserCredential mockUserCredential = MockUserCredential();
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(userRepository.signIn(email, password))
        .thenAnswer((_) async => mockUserCredential);
    when(questionsRepository.getUserQuestions())
        .thenAnswer((_) async => getQuestionTree());
    when(questionsRepository.getFrequentlyAskedQuestions())
        .thenAnswer((_) async => getQuestionTree());

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            navigatorObservers: [mockObserver],
            initialRoute: RouterKeys.signInRoute,
            navigatorKey: Router.navigatorKey,
            onGenerateRoute: NavigationProvider.of(context).onGenerateRoute,
          );
        },
      ),
    ));
    await tester.pumpAndSettle();

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

    verify(mockObserver.didPush(any, any)).called(2);

    verify(userRepository.signIn(email, password)).called(1);
    verify(questionsRepository.getUserQuestions()).called(1);
    verify(questionsRepository.getFrequentlyAskedQuestions()).called(1);
    verifyNoMoreInteractions(mockUserCredential);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(questionsRepository);
    verifyNoMoreInteractions(mockFirebaseUser);

    expect(find.byType(SigninScreen), findsNothing);
    expect(find.byType(ChatListScreen), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('should show error dialog when email is invalid',
      (WidgetTester tester) async {
    String email = 'prajval@gmail.com';
    String password = 'password';

    final mockObserver = MockNavigatorObserver();
    MockUserCredential mockUserCredential = MockUserCredential();
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(userRepository.signIn(email, password))
        .thenAnswer((_) => Future.error(GenericError('$invalidEmail')));

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.signInRoute,
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.widgetWithText(AlertDialog, '$invalidEmailMessage'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    verify(userRepository.signIn(email, password)).called(1);
    verifyNoMoreInteractions(mockUserCredential);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockFirebaseUser);

    expect(find.byType(SigninScreen), findsOneWidget);
    expect(find.byType(ChatListScreen), findsNothing);
  });

  testWidgets('should show error dialog when password is wrong',
      (WidgetTester tester) async {
    String email = 'prajval@gmail.com';
    String password = 'password';

    final mockObserver = MockNavigatorObserver();
    MockUserCredential mockUserCredential = MockUserCredential();
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(userRepository.signIn(email, password))
        .thenAnswer((_) => Future.error(GenericError('$wrongPassword')));

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.signInRoute,
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.widgetWithText(AlertDialog, '$wrongPasswordMessage'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    verify(userRepository.signIn(email, password)).called(1);
    verifyNoMoreInteractions(mockUserCredential);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockFirebaseUser);

    expect(find.byType(SigninScreen), findsOneWidget);
    expect(find.byType(ChatListScreen), findsNothing);
  });

  testWidgets('should show error dialog when user is not found',
      (WidgetTester tester) async {
    String email = 'prajval@gmail.com';
    String password = 'password';

    final mockObserver = MockNavigatorObserver();
    MockUserCredential mockUserCredential = MockUserCredential();
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(userRepository.signIn(email, password))
        .thenAnswer((_) => Future.error(GenericError('$userNotFound')));

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.signInRoute,
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.widgetWithText(AlertDialog, '$userNotFoundMessage'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    verify(userRepository.signIn(email, password)).called(1);
    verifyNoMoreInteractions(mockUserCredential);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockFirebaseUser);

    expect(find.byType(SigninScreen), findsOneWidget);
    expect(find.byType(ChatListScreen), findsNothing);
  });

  testWidgets('should show error dialog when user is disabled',
      (WidgetTester tester) async {
    String email = 'prajval@gmail.com';
    String password = 'password';

    final mockObserver = MockNavigatorObserver();
    MockUserCredential mockUserCredential = MockUserCredential();
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(userRepository.signIn(email, password))
        .thenAnswer((_) => Future.error(GenericError('$userDisabled')));

    await tester.pumpWidget(MaterialApp(
      home: SigninScreen(
        userRepository,
      ),
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.widgetWithText(AlertDialog, '$userDisabledMessage'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    verify(userRepository.signIn(email, password)).called(1);
    verifyNoMoreInteractions(mockUserCredential);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockFirebaseUser);

    expect(find.byType(SigninScreen), findsOneWidget);
    expect(find.byType(ChatListScreen), findsNothing);
  });

  testWidgets('should show error dialog when too many requests are made',
      (WidgetTester tester) async {
    String email = 'prajval@gmail.com';
    String password = 'password';

    final mockObserver = MockNavigatorObserver();
    MockUserCredential mockUserCredential = MockUserCredential();
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(userRepository.signIn(email, password))
        .thenAnswer((_) => Future.error(GenericError('random error')));

    await tester.pumpWidget(MaterialApp(
      home: SigninScreen(userRepository),
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.widgetWithText(AlertDialog, '$defaultErrorMessageForSignIn'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    verify(userRepository.signIn(email, password)).called(1);
    verifyNoMoreInteractions(mockUserCredential);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockFirebaseUser);

    expect(find.byType(SigninScreen), findsOneWidget);
    expect(find.byType(ChatListScreen), findsNothing);
  });

  testWidgets('should show error dialog when any other error occurs',
      (WidgetTester tester) async {
    String email = 'prajval@gmail.com';
    String password = 'password';

    final mockObserver = MockNavigatorObserver();
    MockUserCredential mockUserCredential = MockUserCredential();
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(userRepository.signIn(email, password))
        .thenAnswer((_) => Future.error(GenericError('generic error')));

    await tester.pumpWidget(MaterialApp(
      home: SigninScreen(userRepository),
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.widgetWithText(AlertDialog, '$defaultErrorMessageForSignIn'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    verify(userRepository.signIn(email, password)).called(1);
    verifyNoMoreInteractions(mockUserCredential);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockFirebaseUser);

    expect(find.byType(SigninScreen), findsOneWidget);
    expect(find.byType(ChatListScreen), findsNothing);
  });

  testWidgets('should close error dialog when ok is pressed',
      (WidgetTester tester) async {
    String email = 'prajval@gmail.com';
    String password = 'password';

    final mockObserver = MockNavigatorObserver();
    MockUserCredential mockUserCredential = MockUserCredential();
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(userRepository.signIn(email, password))
        .thenAnswer((_) => Future.error(GenericError('generic error')));

    await tester.pumpWidget(MaterialApp(
      home: SigninScreen(userRepository),
      navigatorObservers: [mockObserver],
    ));
    await tester.pumpAndSettle();

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

    expect(find.widgetWithText(AlertDialog, '$defaultErrorMessageForSignIn'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, '$ok'), findsOneWidget);

    verify(userRepository.signIn(email, password)).called(1);
    verifyNoMoreInteractions(mockUserCredential);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockFirebaseUser);

    final Finder okButton = find.widgetWithText(FlatButton, '$ok');
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AlertDialog, '$errorTitle'), findsNothing);
  });

  testWidgets('forgot password should open forgot password screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.signInRoute,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SigninScreen), findsOneWidget);
    expect(find.byType(ForgotPasswordScreen), findsNothing);

    final Finder forgotPassword =
        find.widgetWithText(FlatButton, 'Forgot password');

    await tester.tap(forgotPassword);
    await tester.pumpAndSettle();

    expect(find.byType(SigninScreen), findsNothing);
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  });

  testWidgets('signup should redirect to register screen',
      (WidgetTester tester) async {
    final mockObserver = MockNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.signInRoute,
      navigatorObservers: [mockObserver],
    ));

    final Finder registerButton =
        find.widgetWithText(FlatButton, '$signUpButton');

    expect(find.byType(RegisterScreen), findsNothing);

    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    verify(mockObserver.didPush(any, any));

    expect(find.byType(SigninScreen), findsNothing);
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}

QuestionsList getQuestionTree() {
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

  List<Question> _questionTree = [
    Question(
        question: "Can depression be treated?",
        answer: "Yes, it can be treated!",
        time: "5d ago"),
    Question(
        question: "How long does depression last?",
        relatedQuestionAnswer: _relatedQuestionsAnswersList,
        time: "4d ago"),
    Question(
        question:
            "Let me now ask a really really long question. Well. I don't know. I know. "
            "I mean I know but don't know how to ask. But here is the thing that i really want to ask."
            "How do we know who is a good doctor?",
        answer: "How about googling the same for now.",
        time: "55 mins ago"),
    Question(
        question: "Is depression genetic?",
        relatedQuestionAnswer: _relatedQuestionsAnswersList,
        time: "33 mins ago")
  ];

  return QuestionsList(list: _questionTree, noQuestionsAskedSoFar: false);
}
