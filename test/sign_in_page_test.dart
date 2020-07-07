import 'dart:math';

import 'package:dive/auth.dart';
import 'package:dive/home_page.dart';
import 'package:dive/register_page.dart';
import 'package:dive/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

class MockAuthResult extends Mock implements AuthResult {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  final mockAuth = MockAuth();

  testWidgets('should render signin page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SigninPage(),
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
      home: SigninPage(),
    ));

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Login');

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(emailForm, findsOneWidget);

    expect(find.text('Please enter some text'), findsNothing);

    await tester.enterText(emailForm, "");
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Please enter some text'), findsOneWidget);
  });

  testWidgets('should show error when entered email is an invalid email',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SigninPage(),
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
    await tester.pump();

    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('should show error when entered password is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SigninPage(),
    ));

    final Finder passwordForm =
        find.widgetWithText(TextFormField, 'Please enter your password');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Login');

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(passwordForm, findsOneWidget);

    expect(find.text('Please enter some password'), findsNothing);

    await tester.enterText(passwordForm, "");
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Please enter some password'), findsOneWidget);
  });

  testWidgets('should navigate to home page when sign in is successful',
      (WidgetTester tester) async {
    String email = 'prajval@gmail.com';
    String password = 'password';

    final mockObserver = MockNavigatorObserver();
    MockAuthResult mockAuthResult = MockAuthResult();
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(mockAuth.signIn(email, password))
        .thenAnswer((_) async => mockAuthResult);
    when(mockAuth.getCurrentUser()).thenAnswer((_) async => mockFirebaseUser);
    when(mockFirebaseUser.displayName).thenReturn('name');
    when(mockAuth.isEmailVerified()).thenAnswer((_) async => true);

    await tester.pumpWidget(MaterialApp(
      home: SigninPage(
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
    await tester.pump();
    await tester.pump();

    expect(find.text('Please enter some password'), findsNothing);
    expect(find.text('Please enter a valid email'), findsNothing);

    verify(mockObserver.didPush(any, any)).called(1);

    verify(mockAuth.getCurrentUser()).called(1);
    verify(mockAuth.signIn(email, password)).called(1);
    verify(mockFirebaseUser.displayName).called(1);
    verify(mockAuth.isEmailVerified()).called(1);
    verifyNoMoreInteractions(mockAuthResult);
    verifyNoMoreInteractions(mockAuth);
    verifyNoMoreInteractions(mockFirebaseUser);

    expect(find.byType(SigninPage), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('forgot password should do nothing', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SigninPage(),
    ));

    final Finder forgotPassword =
        find.widgetWithText(FlatButton, 'Forgot password');

    await tester.tap(forgotPassword);
    await tester.pump();

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

  testWidgets('signup should redirect to register page',
      (WidgetTester tester) async {
    final mockObserver = MockNavigatorObserver();

    await tester.pumpWidget(MaterialApp(
      home: SigninPage(),
      navigatorObservers: [mockObserver],
    ));

    final Finder registerButton = find.widgetWithText(FlatButton, 'SIGN UP');

    expect(find.byType(RegisterPage), findsNothing);

    await tester.tap(registerButton);
    await tester.pump();
    await tester.pump();

    verify(mockObserver.didPush(any, any));

    expect(find.byType(SigninPage), findsOneWidget);
    expect(find.byType(RegisterPage), findsOneWidget);
  });
}
