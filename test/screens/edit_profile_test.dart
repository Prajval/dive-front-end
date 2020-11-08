import 'package:dive/base_state.dart';
import 'package:dive/push_notification/push_notification_service.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/screens/edit_profile.dart';
import 'package:dive/utils/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import '../main_test.dart';

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

  testWidgets("should render edit profile screen", (WidgetTester tester) async {
    User user = MockFirebaseUser();
    String name = "name secondname";
    String email = "email@email.com";

    when(mockUserRepository.getCurrentUser()).thenReturn(user);
    when(user.displayName).thenReturn(name);
    when(user.email).thenReturn(email);

    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(mockUserRepository),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, editProfileAppBar), findsOneWidget);
    expect(find.widgetWithText(TextFormField, email), findsOneWidget);
    expect(find.widgetWithText(TextFormField, name), findsOneWidget);
    expect(
        find.widgetWithText(FlatButton, updateProfileButton), findsOneWidget);

    verify(mockUserRepository.getCurrentUser()).called(2);
    verify(user.email).called(1);
    verify(user.displayName).called(1);
    verifyNoMoreInteractions(user);
    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets("should update only name", (WidgetTester tester) async {
    User user = MockFirebaseUser();
    String name = "name secondname";
    String email = "email@email.com";
    String newName = "new name";
    NavigatorObserver navigatorObserver = MockNavigatorObserver();

    when(mockUserRepository.getCurrentUser()).thenReturn(user);
    when(user.displayName).thenReturn(name);
    when(user.email).thenReturn(email);
    when(mockUserRepository.updateProfile(email, newName))
        .thenAnswer((_) => Future.value());

    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(mockUserRepository),
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    final Finder nameForm = find.widgetWithText(TextFormField, name);
    final Finder updateProfileButton =
        find.widgetWithText(FlatButton, "Update Profile");

    await tester.enterText(nameForm, newName);
    await tester.tap(updateProfileButton);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Dialog, success), findsOneWidget);
    expect(find.widgetWithText(Dialog, updateProfileSuccess), findsOneWidget);
    expect(find.widgetWithText(Dialog, ok), findsOneWidget);

    final Finder okButton = find.widgetWithText(FlatButton, '$ok');
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPop(any, any)).called(2);
    verify(mockUserRepository.getCurrentUser()).called(2);
    verify(user.email).called(1);
    verify(user.displayName).called(1);
    verify(mockUserRepository.updateProfile(email, newName)).called(1);
    verifyNoMoreInteractions(user);
    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets("should update only email", (WidgetTester tester) async {
    User user = MockFirebaseUser();
    String name = "name secondname";
    String email = "email@email.com";
    String newEmail = "newemail@email.com";
    NavigatorObserver navigatorObserver = MockNavigatorObserver();

    when(mockUserRepository.getCurrentUser()).thenReturn(user);
    when(user.displayName).thenReturn(name);
    when(user.email).thenReturn(email);
    when(mockUserRepository.updateProfile(newEmail, name))
        .thenAnswer((_) => Future.value());

    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(mockUserRepository),
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    final Finder emailForm = find.widgetWithText(TextFormField, email);
    final Finder updateProfileButton =
        find.widgetWithText(FlatButton, "Update Profile");

    await tester.enterText(emailForm, newEmail);
    await tester.tap(updateProfileButton);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Dialog, success), findsOneWidget);
    expect(find.widgetWithText(Dialog, updateProfileSuccess), findsOneWidget);
    expect(find.widgetWithText(Dialog, ok), findsOneWidget);

    final Finder okButton = find.widgetWithText(FlatButton, '$ok');
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPop(any, any)).called(2);
    verify(mockUserRepository.getCurrentUser()).called(2);
    verify(user.email).called(1);
    verify(user.displayName).called(1);
    verify(mockUserRepository.updateProfile(newEmail, name)).called(1);
    verifyNoMoreInteractions(user);
    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets("should update both name and email", (WidgetTester tester) async {
    User user = MockFirebaseUser();
    String name = "name secondname";
    String email = "email@email.com";
    String newEmail = "newemail@email.com";
    String newName = "new name";
    NavigatorObserver navigatorObserver = MockNavigatorObserver();

    when(mockUserRepository.getCurrentUser()).thenReturn(user);
    when(user.displayName).thenReturn(name);
    when(user.email).thenReturn(email);
    when(mockUserRepository.updateProfile(newEmail, newName))
        .thenAnswer((_) => Future.value());

    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(mockUserRepository),
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    final Finder emailForm = find.widgetWithText(TextFormField, email);
    final Finder nameForm = find.widgetWithText(TextFormField, name);
    final Finder updateProfileButton =
        find.widgetWithText(FlatButton, "Update Profile");

    await tester.enterText(emailForm, newEmail);
    await tester.enterText(nameForm, newName);
    await tester.tap(updateProfileButton);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Dialog, success), findsOneWidget);
    expect(find.widgetWithText(Dialog, updateProfileSuccess), findsOneWidget);
    expect(find.widgetWithText(Dialog, ok), findsOneWidget);

    final Finder okButton = find.widgetWithText(FlatButton, '$ok');
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPop(any, any)).called(2);
    verify(mockUserRepository.getCurrentUser()).called(2);
    verify(user.email).called(1);
    verify(user.displayName).called(1);
    verify(mockUserRepository.updateProfile(newEmail, newName)).called(1);
    verifyNoMoreInteractions(user);
    verifyNoMoreInteractions(mockUserRepository);
  });

  testWidgets("should fail to update name and email",
      (WidgetTester tester) async {
    User user = MockFirebaseUser();
    String name = "name secondname";
    String email = "email@email.com";
    String newEmail = "newemail@email.com";
    String newName = "new name";
    NavigatorObserver navigatorObserver = MockNavigatorObserver();

    when(mockUserRepository.getCurrentUser()).thenReturn(user);
    when(user.displayName).thenReturn(name);
    when(user.email).thenReturn(email);
    when(mockUserRepository.updateProfile(newEmail, newName))
        .thenAnswer((_) => Future.error("error"));

    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(mockUserRepository),
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    final Finder emailForm = find.widgetWithText(TextFormField, email);
    final Finder nameForm = find.widgetWithText(TextFormField, name);
    final Finder updateProfileButton =
        find.widgetWithText(FlatButton, "Update Profile");

    await tester.enterText(emailForm, newEmail);
    await tester.enterText(nameForm, newName);
    await tester.tap(updateProfileButton);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Dialog, errorTitle), findsOneWidget);
    expect(find.widgetWithText(Dialog, updateProfileFailure), findsOneWidget);
    expect(find.widgetWithText(Dialog, ok), findsOneWidget);

    final Finder okButton = find.widgetWithText(FlatButton, '$ok');
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    expect(find.byType(EditProfileScreen), findsOneWidget);

    verify(navigatorObserver.didPop(any, any)).called(1);
    verify(mockUserRepository.getCurrentUser()).called(2);
    verify(user.email).called(1);
    verify(user.displayName).called(1);
    verify(mockUserRepository.updateProfile(newEmail, newName)).called(1);
    verifyNoMoreInteractions(user);
    verifyNoMoreInteractions(mockUserRepository);
  });
}
