import 'package:dive/base_state.dart';
import 'package:dive/push_notification/push_notification_service.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/screens/forgot_password.dart';
import 'package:dive/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockPNS extends Mock implements PushNotificationService {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  final mockUserRepository = MockUserRepository();

  setUpAll(() {
    GetIt.instance.allowReassignment = true;
    GetIt.instance.registerSingleton<UserRepository>(mockUserRepository);
    GetIt.instance
        .registerSingleton<GetLinksStreamWrapper>(GetLinksStreamWrapper());
    GetIt.instance.registerSingleton<PushNotificationService>(MockPNS());
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('should render forgot password screen',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordScreen(mockUserRepository),
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, forgotPasswordAppBar), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.widgetWithText(FlatButton, passwordResetEmailButton),
        findsOneWidget);

    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets('should show error when entered email is empty',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordScreen(mockUserRepository),
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder resetPasswordButton =
        find.widgetWithText(FlatButton, passwordResetEmailButton);

    await tester.enterText(emailForm, "");
    await tester.tap(resetPasswordButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter some text'), findsOneWidget);

    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets('should show error when entered email is an invalid email',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordScreen(mockUserRepository),
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder resetPasswordButton =
        find.widgetWithText(FlatButton, passwordResetEmailButton);

    await tester.enterText(emailForm, "email");
    await tester.tap(resetPasswordButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email'), findsOneWidget);

    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets(
      'should show success dialog when password reset email is sent successfully',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();
    String email = "prajval@gmail.com";

    when(mockUserRepository.resetPassword(email))
        .thenAnswer((_) => Future.value());

    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordScreen(mockUserRepository),
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder resetPasswordButton =
        find.widgetWithText(FlatButton, passwordResetEmailButton);

    await tester.enterText(emailForm, email);
    await tester.tap(resetPasswordButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email'), findsNothing);
    expect(find.widgetWithText(Dialog, success), findsOneWidget);
    expect(
        find.widgetWithText(Dialog, sentEmailToResetPassword), findsOneWidget);
    expect(find.widgetWithText(Dialog, ok), findsOneWidget);

    verify(mockUserRepository.resetPassword(email)).called(1);
    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets(
      'should show success dialog and then close the forgot password screen'
      ' when password reset email is sent successfully',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();
    String email = "prajval@gmail.com";

    when(mockUserRepository.resetPassword(email))
        .thenAnswer((_) => Future.value());

    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordScreen(mockUserRepository),
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder resetPasswordButton =
        find.widgetWithText(FlatButton, passwordResetEmailButton);

    await tester.enterText(emailForm, email);
    await tester.tap(resetPasswordButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email'), findsNothing);
    expect(find.widgetWithText(Dialog, success), findsOneWidget);
    expect(
        find.widgetWithText(Dialog, sentEmailToResetPassword), findsOneWidget);
    expect(find.widgetWithText(Dialog, ok), findsOneWidget);

    final Finder okButton = find.widgetWithText(FlatButton, '$ok');
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPop(any, any)).called(2);

    verify(mockUserRepository.resetPassword(email)).called(1);
    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets('should show error dialog when password reset email fails',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();
    String email = "prajval@gmail.com";

    when(mockUserRepository.resetPassword(email))
        .thenAnswer((_) => Future.error("error"));

    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordScreen(mockUserRepository),
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder resetPasswordButton =
        find.widgetWithText(FlatButton, passwordResetEmailButton);

    await tester.enterText(emailForm, email);
    await tester.tap(resetPasswordButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email'), findsNothing);
    expect(find.widgetWithText(Dialog, errorTitle), findsOneWidget);
    expect(find.widgetWithText(Dialog, passwordResetSendingEmailFailed),
        findsOneWidget);
    expect(find.widgetWithText(Dialog, ok), findsOneWidget);

    verify(mockUserRepository.resetPassword(email)).called(1);
    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets(
      'should show error dialog and then close the dialog'
      ' when password reset email fails', (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();
    String email = "prajval@gmail.com";

    when(mockUserRepository.resetPassword(email))
        .thenAnswer((_) => Future.error("error"));

    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordScreen(mockUserRepository),
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder resetPasswordButton =
        find.widgetWithText(FlatButton, passwordResetEmailButton);

    await tester.enterText(emailForm, email);
    await tester.tap(resetPasswordButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email'), findsNothing);
    expect(find.widgetWithText(Dialog, errorTitle), findsOneWidget);
    expect(find.widgetWithText(Dialog, passwordResetSendingEmailFailed),
        findsOneWidget);
    expect(find.widgetWithText(Dialog, ok), findsOneWidget);

    final Finder okButton = find.widgetWithText(FlatButton, '$ok');
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPop(any, any)).called(1);

    verify(mockUserRepository.resetPassword(email)).called(1);
    verifyNoMoreInteractions(mockUserRepository);
  });
}
