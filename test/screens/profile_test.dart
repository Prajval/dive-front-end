import 'package:dive/base_state.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/screens/sign_in.dart';
import 'package:dive/utils/router.dart';
import 'package:dive/utils/router_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockFirebaseUser extends Mock implements User {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  final mockUserRepository = MockUserRepository();

  setUpAll(() {
    GetIt.instance.allowReassignment = true;
    GetIt.instance.registerSingleton<UserRepository>(mockUserRepository);
    GetIt.instance
        .registerSingleton<GetLinksStreamWrapper>(GetLinksStreamWrapper());
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('should render home screen', (WidgetTester tester) async {
    final mockFirebaseUser = MockFirebaseUser();

    String name = 'name';
    String expectedWelcomeMessage = 'Welcome $name, We are here to help you!';

    when(mockUserRepository.isEmailVerified()).thenReturn(true);
    when(mockUserRepository.getCurrentUser()).thenReturn(mockFirebaseUser);
    when(mockFirebaseUser.displayName).thenReturn(name);

    await tester.pumpWidget(MaterialApp(
      home: ProfileScreen(
        mockUserRepository,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('$expectedWelcomeMessage'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FlatButton), findsOneWidget);

    verify(mockUserRepository.isEmailVerified()).called(1);
    verify(mockUserRepository.getCurrentUser()).called(1);
    verify(mockFirebaseUser.displayName).called(1);
    verifyNoMoreInteractions(mockUserRepository);
    verifyNoMoreInteractions(mockFirebaseUser);
  });

  testWidgets('should show email verification screen if email is not verified',
      (WidgetTester tester) async {
    final mockFirebaseUser = MockFirebaseUser();

    String expectedEmailVerificationMessage = 'Your email is not verified.';

    when(mockUserRepository.isEmailVerified()).thenReturn(false);

    await tester.pumpWidget(MaterialApp(
      home: ProfileScreen(
        mockUserRepository,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('$expectedEmailVerificationMessage'), findsOneWidget);
    expect(find.text('Verify email'), findsOneWidget);
    expect(find.text('Email verification'), findsOneWidget);

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FlatButton), findsOneWidget);

    verify(mockUserRepository.isEmailVerified()).called(1);
    verifyNoMoreInteractions(mockUserRepository);
    verifyNoMoreInteractions(mockFirebaseUser);
  });

  testWidgets(
      'should initiate email verification and come back to home screen when verify email is pressed',
      (WidgetTester tester) async {
    final mockFirebaseUser = MockFirebaseUser();

    String expectedEmailVerificationMessage = 'Your email is not verified.';
    String name = 'name';
    String expectedWelcomeMessage = 'Welcome $name, We are here to help you!';

    when(mockUserRepository.isEmailVerified()).thenReturn(false);
    when(mockUserRepository.sendEmailVerification()).thenAnswer((_) async {
      return;
    });
    when(mockUserRepository.getCurrentUser()).thenReturn(mockFirebaseUser);
    when(mockFirebaseUser.displayName).thenReturn(name);

    await tester.pumpWidget(MaterialApp(
      home: ProfileScreen(
        mockUserRepository,
      ),
    ));
    await tester.pumpAndSettle();

    final Finder verifyEmailButton =
        find.widgetWithText(FlatButton, 'Verify email');

    expect(find.text('$expectedEmailVerificationMessage'), findsOneWidget);
    expect(find.text('Verify email'), findsOneWidget);
    expect(find.text('Email verification'), findsOneWidget);

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FlatButton), findsOneWidget);

    await tester.tap(verifyEmailButton);
    await tester.pumpAndSettle();

    expect(find.text('$expectedEmailVerificationMessage'), findsNothing);
    expect(find.text('Verify email'), findsNothing);
    expect(find.text('Email verification'), findsNothing);
    expect(find.text('$expectedWelcomeMessage'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FlatButton), findsOneWidget);

    verify(mockUserRepository.isEmailVerified()).called(1);
    verify(mockFirebaseUser.displayName).called(1);
    verify(mockUserRepository.getCurrentUser()).called(1);
    verify(mockUserRepository.sendEmailVerification()).called(1);
    verifyNoMoreInteractions(mockUserRepository);
    verifyNoMoreInteractions(mockFirebaseUser);
  });

  testWidgets(
      'should show error dialog when initiation of email verification fails',
      (WidgetTester tester) async {
    String expectedEmailVerificationMessage = 'Your email is not verified.';

    when(mockUserRepository.isEmailVerified()).thenReturn(false);
    when(mockUserRepository.sendEmailVerification())
        .thenAnswer((_) => new Future.error('error'));

    await tester.pumpWidget(MaterialApp(
      home: ProfileScreen(
        mockUserRepository,
      ),
    ));
    await tester.pumpAndSettle();

    final Finder verifyEmailButton =
        find.widgetWithText(FlatButton, 'Verify email');

    expect(find.text('$expectedEmailVerificationMessage'), findsOneWidget);
    expect(find.text('Verify email'), findsOneWidget);
    expect(find.text('Email verification'), findsOneWidget);

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FlatButton), findsOneWidget);

    await tester.tap(verifyEmailButton);
    await tester.pumpAndSettle();

    final Finder errorDialog = find.widgetWithText(
        AlertDialog, 'Sending verification email failed. Please try again.');
    expect(errorDialog, findsOneWidget);
    expect(find.widgetWithText(AlertDialog, 'Error'), findsOneWidget);
    expect(
        find.descendant(
            of: errorDialog, matching: find.widgetWithText(FlatButton, 'Ok')),
        findsOneWidget);

    verify(mockUserRepository.isEmailVerified()).called(1);
    verify(mockUserRepository.sendEmailVerification()).called(1);
    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets('should close error dialog when ok is pressed',
      (WidgetTester tester) async {
    String expectedEmailVerificationMessage = 'Your email is not verified.';

    when(mockUserRepository.isEmailVerified()).thenReturn(false);
    when(mockUserRepository.sendEmailVerification())
        .thenAnswer((_) => new Future.error('error'));

    await tester.pumpWidget(MaterialApp(
      home: ProfileScreen(
        mockUserRepository,
      ),
    ));
    await tester.pumpAndSettle();

    final Finder verifyEmailButton =
        find.widgetWithText(FlatButton, 'Verify email');

    expect(find.text('$expectedEmailVerificationMessage'), findsOneWidget);
    expect(find.text('Verify email'), findsOneWidget);
    expect(find.text('Email verification'), findsOneWidget);

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FlatButton), findsOneWidget);

    await tester.tap(verifyEmailButton);
    await tester.pumpAndSettle();

    final Finder errorDialog = find.widgetWithText(
        AlertDialog, 'Sending verification email failed. Please try again.');
    final Finder errorDialogOkButton = find.descendant(
        of: errorDialog, matching: find.widgetWithText(FlatButton, 'Ok'));

    expect(errorDialog, findsOneWidget);

    await tester.tap(errorDialogOkButton);
    await tester.pumpAndSettle();

    expect(
        find.widgetWithText(AlertDialog,
            'Sending verification email failed. Please try again.'),
        findsNothing);

    verify(mockUserRepository.isEmailVerified()).called(1);
    verify(mockUserRepository.sendEmailVerification()).called(1);
    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets(
      'should signout and redirect to signin screen when signout button is pressed',
      (WidgetTester tester) async {
    MockNavigatorObserver mockNavigatorObserver = MockNavigatorObserver();
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(mockUserRepository.isEmailVerified()).thenReturn(true);
    when(mockUserRepository.getCurrentUser()).thenReturn(mockFirebaseUser);
    when(mockFirebaseUser.displayName).thenReturn('name');
    when(mockUserRepository.signOut()).thenAnswer((_) => Future.value());

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.profileRoute,
      navigatorObservers: [mockNavigatorObserver],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(SigninScreen), findsNothing);

    final Finder signOutButton = find.widgetWithText(FlatButton, 'Sign out');

    when(mockUserRepository.getCurrentUser()).thenReturn(null);

    await tester.tap(signOutButton);
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPush(any, any));

    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(SigninScreen), findsOneWidget);

    verify(mockUserRepository.isEmailVerified()).called(1);
    verify(mockUserRepository.getCurrentUser()).called(3);
    verify(mockUserRepository.signOut()).called(1);
    verify(mockFirebaseUser.displayName).called(1);
    verifyNoMoreInteractions(mockUserRepository);
    verifyNoMoreInteractions(mockFirebaseUser);
  });

  testWidgets(
      'should show error dialog when signout button is pressed and signout fails',
      (WidgetTester tester) async {
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(mockUserRepository.isEmailVerified()).thenReturn(true);
    when(mockUserRepository.getCurrentUser()).thenReturn(mockFirebaseUser);
    when(mockFirebaseUser.displayName).thenReturn('name');
    when(mockUserRepository.signOut()).thenAnswer((_) => Future.error('error'));

    await tester.pumpWidget(MaterialApp(
      home: ProfileScreen(mockUserRepository),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(SigninScreen), findsNothing);

    final Finder signOutButton = find.widgetWithText(FlatButton, 'Sign out');

    await tester.tap(signOutButton);
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(SigninScreen), findsNothing);
    expect(
        find.widgetWithText(
            AlertDialog, 'Signing out failed. Please try again.'),
        findsOneWidget);
    expect(find.widgetWithText(AlertDialog, 'Error'), findsOneWidget);
    expect(find.widgetWithText(AlertDialog, 'Ok'), findsOneWidget);

    verify(mockUserRepository.isEmailVerified()).called(1);
    verify(mockUserRepository.getCurrentUser()).called(1);
    verify(mockUserRepository.signOut()).called(1);
    verify(mockFirebaseUser.displayName).called(1);
    verifyNoMoreInteractions(mockUserRepository);
    verifyNoMoreInteractions(mockFirebaseUser);
  });

  testWidgets('should close the signout error dialog',
      (WidgetTester tester) async {
    MockFirebaseUser mockFirebaseUser = MockFirebaseUser();

    when(mockUserRepository.isEmailVerified()).thenReturn(true);
    when(mockUserRepository.getCurrentUser()).thenReturn(mockFirebaseUser);
    when(mockFirebaseUser.displayName).thenReturn('name');
    when(mockUserRepository.signOut()).thenAnswer((_) => Future.error('error'));

    await tester.pumpWidget(MaterialApp(
      home: ProfileScreen(mockUserRepository),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(SigninScreen), findsNothing);

    final Finder signOutButton = find.widgetWithText(FlatButton, 'Sign out');

    await tester.tap(signOutButton);
    await tester.pumpAndSettle();

    final Finder signoutFailedDialog = find.widgetWithText(
        AlertDialog, 'Signing out failed. Please try again.');
    final Finder signOutFailedDialogOkButton = find.descendant(
        of: signoutFailedDialog,
        matching: find.widgetWithText(FlatButton, 'Ok'));

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(SigninScreen), findsNothing);
    expect(signoutFailedDialog, findsOneWidget);

    await tester.tap(signOutFailedDialogOkButton);
    await tester.pumpAndSettle();

    expect(
        find.widgetWithText(
            AlertDialog, 'Signing out failed. Please try again.'),
        findsNothing);

    verify(mockUserRepository.isEmailVerified()).called(1);
    verify(mockUserRepository.getCurrentUser()).called(1);
    verify(mockUserRepository.signOut()).called(1);
    verify(mockFirebaseUser.displayName).called(1);
    verifyNoMoreInteractions(mockUserRepository);
    verifyNoMoreInteractions(mockFirebaseUser);
  });

  testWidgets('should show error when fetching user details returns null',
      (WidgetTester tester) async {
    final mockFirebaseUser = MockFirebaseUser();

    String expectedAppBarTitle = 'Error';
    String expectedErrorMessage =
        'Failed to fetch user details. Please try again after some time.';

    when(mockUserRepository.isEmailVerified()).thenReturn(true);
    when(mockUserRepository.getCurrentUser()).thenReturn(null);

    await tester.pumpWidget(MaterialApp(
      home: ProfileScreen(
        mockUserRepository,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsNothing);
    expect(find.widgetWithText(AppBar, '$expectedAppBarTitle'), findsOneWidget);
    expect(find.text('$expectedErrorMessage'), findsOneWidget);

    verify(mockUserRepository.isEmailVerified()).called(1);
    verify(mockUserRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockUserRepository);
    verifyNoMoreInteractions(mockFirebaseUser);
  });

  testWidgets('should show error when fetching user details fails',
      (WidgetTester tester) async {
    final mockFirebaseUser = MockFirebaseUser();

    String expectedAppBarTitle = 'Error';
    String expectedErrorMessage =
        'Failed to fetch user details. Please try again after some time.';

    when(mockUserRepository.isEmailVerified()).thenReturn(true);
    when(mockUserRepository.getCurrentUser()).thenReturn(null);

    await tester.pumpWidget(MaterialApp(
      home: ProfileScreen(
        mockUserRepository,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsNothing);
    expect(find.widgetWithText(AppBar, '$expectedAppBarTitle'), findsOneWidget);
    expect(find.text('$expectedErrorMessage'), findsOneWidget);

    verify(mockUserRepository.isEmailVerified()).called(1);
    verify(mockUserRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockUserRepository);
    verifyNoMoreInteractions(mockFirebaseUser);
  });
}
