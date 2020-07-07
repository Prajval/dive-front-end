import 'package:dive/auth.dart';
import 'package:dive/home_page.dart';
import 'package:dive/root_page.dart';
import 'package:dive/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

void main() {
  final auth = MockAuth();

  testWidgets('should redirect to homepage if user is logged in',
      (WidgetTester tester) async {
    final auth = MockAuth();
    final firebaseUser = MockFirebaseUser();
    String uid = "uid";
    String displayName = "name";

    when(auth.getCurrentUser()).thenAnswer((_) async => firebaseUser);
    when(firebaseUser.uid).thenReturn(uid);
    when(auth.isEmailVerified()).thenAnswer((_) async => true);
    when(firebaseUser.displayName).thenReturn(displayName);

    await tester.pumpWidget(MaterialApp(
      home: RootPage(
        auth: auth,
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SigninPage), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    verify(auth.getCurrentUser()).called(2);
    verify(firebaseUser.uid).called(2);
    verify(auth.isEmailVerified()).called(1);
    verify(firebaseUser.displayName).called(1);
    verifyNoMoreInteractions(auth);
    verifyNoMoreInteractions(firebaseUser);
  });

  testWidgets('should redirect to Signin page if user is not logged in',
      (WidgetTester tester) async {
    when(auth.getCurrentUser()).thenAnswer((_) async => null);

    await tester.pumpWidget(MaterialApp(
      home: RootPage(
        auth: auth,
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();

    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(SigninPage), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    verify(auth.getCurrentUser()).called(1);
    verifyNoMoreInteractions(auth);
  });

  testWidgets('should redirect to Signin page if there is an error',
      (WidgetTester tester) async {
    when(auth.getCurrentUser()).thenAnswer((_) => new Future.error('error'));

    await tester.pumpWidget(MaterialApp(
      home: RootPage(
        auth: auth,
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();

    //expectLater(tester.takeException(), isInstanceOf<Exception>());
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(SigninPage), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    verify(auth.getCurrentUser()).called(1);
    verifyNoMoreInteractions(auth);
  });

  testWidgets('should show loader before sign-in details are fetched',
      (WidgetTester tester) async {
    when(auth.getCurrentUser()).thenAnswer((_) => new Future.error('error'));

    await tester.pumpWidget(MaterialApp(
      home: RootPage(
        auth: auth,
      ),
    ));

    //expectLater(tester.takeException(), isInstanceOf<Exception>());
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(SigninPage), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    verify(auth.getCurrentUser()).called(1);
    verifyNoMoreInteractions(auth);
  });
}
