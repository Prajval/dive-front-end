import 'package:dive/auth.dart';
import 'package:dive/home_page.dart';
import 'package:dive/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockAuthResult extends Mock implements AuthResult {}

class MockAuthFirebaseUser extends Mock implements FirebaseUser {}

void main() {
  testWidgets('should render register page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(),
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
      home: RegisterPage(),
    ));

    final Finder emailForm =
        find.widgetWithText(TextFormField, 'Enter your email');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Register');

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(emailForm, findsOneWidget);

    expect(find.text('Please enter some text'), findsNothing);

    await tester.enterText(emailForm, "");
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Please enter some text'), findsWidgets);
  });

  testWidgets('should show error when entered email is an invalid email',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(),
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
    await tester.pump();

    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('should show error when entered password is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(),
    ));

    final Finder passwordForm =
        find.widgetWithText(TextFormField, 'Choose a password');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Register');

    expect(find.widgetWithIcon(TextFormField, Icons.person), findsWidgets);
    expect(passwordForm, findsOneWidget);

    expect(find.text('Please enter some password'), findsNothing);

    await tester.enterText(passwordForm, "");
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Please enter some password'), findsOneWidget);
  });

  testWidgets('should show error when entered name is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(),
    ));

    final Finder passwordForm =
        find.widgetWithText(TextFormField, 'Enter your full name');
    final Finder loginButton = find.widgetWithText(FlatButton, 'Register');

    expect(find.widgetWithIcon(TextFormField, Icons.person), findsWidgets);
    expect(passwordForm, findsOneWidget);

    expect(find.text('Please enter some text'), findsNothing);

    await tester.enterText(passwordForm, "");
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Please enter some text'), findsWidgets);
  });

  testWidgets('should redirect to home page if registration is successful',
      (WidgetTester tester) async {
    String name = "name";
    String password = "password";
    String email = "prajval@gmail.com";

    final mockAuth = MockAuth();
    final mockAuthResult = MockAuthResult();
    final mockFirebaseUser = MockAuthFirebaseUser();
    final mockObserver = MockNavigatorObserver();

    when(mockAuth.signUp(email, password, name))
        .thenAnswer((_) async => mockAuthResult);
    when(mockAuth.isEmailVerified()).thenAnswer((_) async => true);
    when(mockFirebaseUser.displayName).thenReturn(name);
    when(mockAuth.getCurrentUser()).thenAnswer((_) async => mockFirebaseUser);

    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(
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

    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(RegisterPage), findsOneWidget);

    await tester.enterText(nameForm, name);
    await tester.enterText(emailForm, email);
    await tester.enterText(passwordForm, password);

    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter some password'), findsNothing);
    expect(find.text('Please enter a valid email'), findsNothing);
    expect(find.text('Please enter some text'), findsNothing);

    verify(mockObserver.didPush(any, any));

    verify(mockAuth.signUp(email, password, name)).called(1);
    verify(mockAuth.getCurrentUser()).called(1);
    verify(mockAuth.isEmailVerified()).called(1);
    verify(mockFirebaseUser.displayName).called(1);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(RegisterPage), findsNothing);
  });
}
