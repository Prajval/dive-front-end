import 'dart:async';

import 'package:dive/base_state.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/push_notification/push_notification_service.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/router/router.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/screens/question_answer.dart';
import 'package:dive/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockStreamWrapper extends Mock implements GetLinksStreamWrapper {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockUser extends Mock implements User {}

class MockPNS extends Mock implements PushNotificationService {}

void main() {
  final mockUserRepository = MockUserRepository();
  final mockStreamWrapper = MockStreamWrapper();
  final mockQuestionsRepository = MockQuestionsRepository();
  final userRepository = MockUserRepository();
  final mockUser = MockUser();

  final baseRoute = BackendRouterKeys.baseRoute;
  final baseChatRoute = baseRoute + RouterKeys.chatListRoute;
  final baseChatRouteWithQid =
      baseChatRoute + "?" + BackendRouterKeys.questionIdParameter + "=";
  final baseRootRoute = baseRoute + RouterKeys.rootRoute;
  final invalidRoute = baseRoute + "/invalid";

  setUpAll(() {
    GetIt.instance.allowReassignment = true;
    GetIt.instance.registerSingleton<UserRepository>(userRepository);
    GetIt.instance
        .registerSingleton<QuestionsRepository>(mockQuestionsRepository);
    GetIt.instance.registerSingleton<GetLinksStreamWrapper>(mockStreamWrapper);
    GetIt.instance.registerSingleton<PushNotificationService>(MockPNS());

    when(userRepository.getCurrentUser()).thenReturn(mockUser);
    when(userRepository.isEmailVerified()).thenReturn(true);
    when(mockUser.displayName).thenReturn("name");
    when(mockUser.uid).thenReturn("uid");
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets(
      'should open chat list screen when deep link with just chat list is opened',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<Question> questionTree = [
      Question(question: question, answer: answer, time: time)
    ];
    QuestionsList questionsList =
        QuestionsList(noQuestionsAskedSoFar: false, list: questionTree);

    StreamController<String> streamController =
        StreamController<String>.broadcast();

    String name = 'name';
    String email = 'email';

    when(mockUserRepository.isEmailVerified()).thenReturn(true);
    when(mockUserRepository.getCurrentUser()).thenReturn(mockUser);
    when(mockUser.displayName).thenReturn(name);
    when(mockUser.email).thenReturn(email);
    when(mockQuestionsRepository.getUserQuestions())
        .thenAnswer((_) async => questionsList);
    when(mockStreamWrapper.getLinksStreamFromLibrary())
        .thenAnswer((_) => streamController.stream);

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.profileRoute,
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);

    streamController.add(baseChatRoute);
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(QuestionAnswerScreen), findsNothing);

    streamController.close();

    verify(mockQuestionsRepository.getUserQuestions()).called(1);
    verify(mockStreamWrapper.getLinksStreamFromLibrary()).called(2);
    verify(userRepository.getCurrentUser()).called(2);
    verify(userRepository.isEmailVerified()).called(1);
    verify(mockUser.displayName).called(2);
    verify(mockUser.email).called(1);
    verify(mockUser.uid).called(1);
    verifyNoMoreInteractions(mockQuestionsRepository);
    verifyNoMoreInteractions(mockStreamWrapper);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockUser);
  });

  testWidgets(
      'should open chat list screen when deep link with just chat list is opened',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<Question> questionTree = [
      Question(question: question, answer: answer, time: time)
    ];
    QuestionsList questionsList =
        QuestionsList(noQuestionsAskedSoFar: false, list: questionTree);

    StreamController<String> streamController =
        StreamController<String>.broadcast();
    when(mockQuestionsRepository.getUserQuestions())
        .thenAnswer((_) async => questionsList);
    when(mockStreamWrapper.getLinksStreamFromLibrary())
        .thenAnswer((_) => streamController.stream);
    when(mockQuestionsRepository.getQuestionDetails(qid: 8, isGolden: false))
        .thenAnswer((_) => Future.value(Question(
                qid: 4,
                question: question,
                answer: answer,
                relatedQuestionAnswer: [
                  RelatedQuestionAnswer(question: 'q1', answer: 'a1', qid: 1),
                  RelatedQuestionAnswer(question: 'q2', answer: 'a2', qid: 2),
                  RelatedQuestionAnswer(question: 'q3', answer: 'a3', qid: 3),
                ])));

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.profileRoute,
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);

    streamController.add(baseChatRouteWithQid + '8');
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(QuestionAnswerScreen), findsOneWidget);

    streamController.close();

    verify(mockQuestionsRepository.getUserQuestions()).called(1);
    verify(mockStreamWrapper.getLinksStreamFromLibrary()).called(3);
    verify(userRepository.getCurrentUser()).called(2);
    verify(userRepository.isEmailVerified()).called(1);
    verify(mockUser.displayName).called(2);
    verify(mockUser.uid).called(1);
    verify(mockUser.email).called(1);
    verify(mockQuestionsRepository.getQuestionDetails(qid: 8, isGolden: false))
        .called(1);
    verifyNoMoreInteractions(mockQuestionsRepository);
    verifyNoMoreInteractions(mockStreamWrapper);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockUser);
  });

  testWidgets('should throw error when deep link has invalid route',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<Question> questionTree = [
      Question(question: question, answer: answer, time: time)
    ];
    QuestionsList questionsList =
        QuestionsList(noQuestionsAskedSoFar: false, list: questionTree);

    StreamController<String> streamController =
        StreamController<String>.broadcast();

    String name = 'name';
    String email = 'email';

    when(mockUserRepository.isEmailVerified()).thenReturn(true);
    when(mockUserRepository.getCurrentUser()).thenReturn(mockUser);
    when(mockUser.displayName).thenReturn(name);
    when(mockUser.email).thenReturn(email);
    when(mockStreamWrapper.getLinksStreamFromLibrary())
        .thenAnswer((_) => streamController.stream);

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.profileRoute,
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);

    streamController.add(baseRoute);
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(QuestionAnswerScreen), findsNothing);

    streamController.close();

    verify(mockStreamWrapper.getLinksStreamFromLibrary()).called(1);
    verify(userRepository.getCurrentUser()).called(1);
    verify(userRepository.isEmailVerified()).called(1);
    verify(mockUser.displayName).called(2);
    verify(mockUser.email).called(1);
    verifyNoMoreInteractions(mockQuestionsRepository);
    verifyNoMoreInteractions(mockStreamWrapper);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockUser);
  });

  testWidgets('should throw error when deep link errors out',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<Question> questionTree = [
      Question(question: question, answer: answer, time: time)
    ];
    QuestionsList questionsList =
        QuestionsList(noQuestionsAskedSoFar: false, list: questionTree);

    StreamController<String> streamController =
        StreamController<String>.broadcast();

    String name = 'name';
    String email = 'email';

    when(mockUserRepository.isEmailVerified()).thenReturn(true);
    when(mockUserRepository.getCurrentUser()).thenReturn(mockUser);
    when(mockUser.displayName).thenReturn(name);
    when(mockUser.email).thenReturn(email);
    when(mockStreamWrapper.getLinksStreamFromLibrary())
        .thenAnswer((_) => streamController.stream);

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.profileRoute,
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);

    streamController.addError(Error());
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(QuestionAnswerScreen), findsNothing);

    streamController.close();

    verify(mockStreamWrapper.getLinksStreamFromLibrary()).called(1);
    verify(userRepository.getCurrentUser()).called(1);
    verify(userRepository.isEmailVerified()).called(1);
    verify(mockUser.displayName).called(2);
    verify(mockUser.email).called(1);
    verifyNoMoreInteractions(mockQuestionsRepository);
    verifyNoMoreInteractions(mockStreamWrapper);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockUser);
  });

  testWidgets('should open root screen when deep link with root is opened',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    StreamController<String> streamController =
        StreamController<String>.broadcast();

    when(mockUserRepository.getCurrentUser()).thenReturn(mockUser);
    when(mockStreamWrapper.getLinksStreamFromLibrary())
        .thenAnswer((_) => streamController.stream);
    when(userRepository.getCurrentUser()).thenReturn(null);

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.profileRoute,
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);

    streamController.add(baseRootRoute);
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byType(QuestionAnswerScreen), findsNothing);
    expect(find.byType(SigninScreen), findsOneWidget);

    streamController.close();

    verify(mockStreamWrapper.getLinksStreamFromLibrary()).called(2);
    verify(userRepository.getCurrentUser());
    verifyNoMoreInteractions(mockQuestionsRepository);
    verifyNoMoreInteractions(mockStreamWrapper);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockUser);
  });

  testWidgets('should do nothing when deep link with invalid route is opened',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    StreamController<String> streamController =
        StreamController<String>.broadcast();
    when(mockStreamWrapper.getLinksStreamFromLibrary())
        .thenAnswer((_) => streamController.stream);
    when(userRepository.getCurrentUser()).thenReturn(null);

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.profileRoute,
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);

    streamController.add(invalidRoute);
    await tester.pumpAndSettle();

    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(QuestionAnswerScreen), findsNothing);
    expect(find.byType(SigninScreen), findsNothing);

    streamController.close();

    verify(mockStreamWrapper.getLinksStreamFromLibrary()).called(1);
    verify(userRepository.getCurrentUser());
    verifyNoMoreInteractions(mockQuestionsRepository);
    verifyNoMoreInteractions(mockStreamWrapper);
    verifyNoMoreInteractions(userRepository);
    verifyNoMoreInteractions(mockUser);
  });
}
