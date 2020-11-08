import 'package:dive/base_state.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/push_notification/push_notification_service.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/router/router.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/screens/bottom_nav_bar/navigation_provider.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/explore.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/utils/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockPNS extends Mock implements PushNotificationService {}

class MockFirebaseUser extends Mock implements User {}

void main() {
  final userRepository = MockUserRepository();
  final questionsRepository = MockQuestionsRepository();

  setUpAll(() {
    GetIt.instance.allowReassignment = true;

    GetIt.instance.registerSingleton<QuestionsRepository>(questionsRepository);
    GetIt.instance.registerSingleton<UserRepository>(userRepository);
    GetIt.instance
        .registerSingleton<GetLinksStreamWrapper>(GetLinksStreamWrapper());
    GetIt.instance.registerSingleton<PushNotificationService>(MockPNS());
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  QuestionsList getQuestionsList() {
    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<Question> questionTree = [
      Question(question: question, answer: answer, time: time)
    ];
    QuestionsList questionsList =
        QuestionsList(noQuestionsAskedSoFar: false, list: questionTree);

    return questionsList;
  }

  testWidgets('should render home screen with chat tab',
      (WidgetTester tester) async {
    MockFirebaseUser firebaseUser = MockFirebaseUser();

    when(userRepository.getCurrentUser()).thenReturn(firebaseUser);
    when(questionsRepository.getUserQuestions())
        .thenAnswer((_) => Future.value(getQuestionsList()));
    when(questionsRepository.getFrequentlyAskedQuestions())
        .thenAnswer((_) => Future.value(getQuestionsList()));

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            initialRoute: RouterKeys.rootRoute,
            navigatorKey: Router.navigatorKey,
            onGenerateRoute: NavigationProvider.of(context).onGenerateRoute,
          );
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('$chatListAppBar'), findsOneWidget);
    expect(find.byIcon(Icons.chat), findsOneWidget);
    expect(find.byIcon(Icons.explore), findsOneWidget);
    expect(find.text('Chat list'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(
        find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
    expect(find.widgetWithIcon(CircleAvatar, Icons.person), findsOneWidget);
    expect(find.text('Explore frequently asked questions here'), findsNothing);

    verify(userRepository.getCurrentUser()).called(1);
    verify(questionsRepository.getUserQuestions()).called(1);
    verify(questionsRepository.getFrequentlyAskedQuestions()).called(1);
    verifyNoMoreInteractions(firebaseUser);
    verifyNoMoreInteractions(questionsRepository);
    verifyNoMoreInteractions(userRepository);
  });

  testWidgets('should render home screen with explore tab',
      (WidgetTester tester) async {
    MockFirebaseUser firebaseUser = MockFirebaseUser();

    when(userRepository.getCurrentUser()).thenReturn(firebaseUser);
    when(questionsRepository.getUserQuestions())
        .thenAnswer((_) => Future.value(getQuestionsList()));

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            initialRoute: RouterKeys.rootRoute,
            navigatorKey: Router.navigatorKey,
            onGenerateRoute: NavigationProvider.of(context).onGenerateRoute,
          );
        },
      ),
    ));
    await tester.pumpAndSettle();

    final Finder exploreTab = find.byIcon(Icons.explore);
    await tester.tap(exploreTab);
    await tester.pumpAndSettle();

    expect(find.text('$chatListAppBar'), findsNothing);
    expect(find.byIcon(Icons.chat), findsOneWidget);
    expect(find.byIcon(Icons.explore), findsOneWidget);
    expect(find.text('Chat list'), findsOneWidget);
    expect(find.text('Explore'), findsNWidgets(2));
    expect(
        find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
    expect(find.widgetWithIcon(CircleAvatar, Icons.person), findsOneWidget);

    verify(userRepository.getCurrentUser()).called(1);
    verify(questionsRepository.getUserQuestions()).called(1);
    verify(questionsRepository.getFrequentlyAskedQuestions()).called(1);
    verifyNoMoreInteractions(firebaseUser);
    verifyNoMoreInteractions(questionsRepository);
    verifyNoMoreInteractions(userRepository);
  });

  testWidgets(
      'should render home screen with chat tab'
      'and open profile from chat tab', (WidgetTester tester) async {
    MockFirebaseUser firebaseUser = MockFirebaseUser();
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    when(userRepository.getCurrentUser()).thenReturn(firebaseUser);
    when(questionsRepository.getUserQuestions())
        .thenAnswer((_) => Future.value(getQuestionsList()));
    when(userRepository.isEmailVerified()).thenReturn(true);
    when(firebaseUser.displayName).thenReturn('name');
    when(firebaseUser.email).thenReturn("email");

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            navigatorObservers: [navigatorObserver],
            initialRoute: RouterKeys.rootRoute,
            navigatorKey: Router.navigatorKey,
            onGenerateRoute: NavigationProvider.of(context).onGenerateRoute,
          );
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('$chatListAppBar'), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);

    final Finder profileButton =
        find.widgetWithIcon(CircleAvatar, Icons.person);
    await tester.tap(profileButton);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPush(any, any));

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(ChatListScreen), findsNothing);

    verify(userRepository.getCurrentUser());
    verify(questionsRepository.getUserQuestions()).called(1);
    verify(questionsRepository.getFrequentlyAskedQuestions()).called(1);
    verify(firebaseUser.email).called(1);
    verify(firebaseUser.displayName).called(2);
    verify(userRepository.isEmailVerified()).called(1);
    verifyNoMoreInteractions(firebaseUser);
    verifyNoMoreInteractions(questionsRepository);
    verifyNoMoreInteractions(userRepository);
  });

  testWidgets(
      'should render home screen with explore tab'
      'and open profile from chat tab', (WidgetTester tester) async {
    MockFirebaseUser firebaseUser = MockFirebaseUser();
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    when(userRepository.getCurrentUser()).thenReturn(firebaseUser);
    when(questionsRepository.getUserQuestions())
        .thenAnswer((_) => Future.value(getQuestionsList()));
    when(userRepository.isEmailVerified()).thenReturn(true);
    when(firebaseUser.displayName).thenReturn('name');
    when(firebaseUser.email).thenReturn("email");

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            navigatorObservers: [navigatorObserver],
            initialRoute: RouterKeys.rootRoute,
            navigatorKey: Router.navigatorKey,
            onGenerateRoute: NavigationProvider.of(context).onGenerateRoute,
          );
        },
      ),
    ));
    await tester.pumpAndSettle();

    final Finder exploreTab = find.byIcon(Icons.explore);
    await tester.tap(exploreTab);
    await tester.pumpAndSettle();

    expect(find.byType(ExploreScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);

    final Finder profileButton =
        find.widgetWithIcon(CircleAvatar, Icons.person);
    await tester.tap(profileButton);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPush(any, any));

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(ExploreScreen), findsNothing);

    verify(userRepository.getCurrentUser()).called(2);
    verify(questionsRepository.getUserQuestions());
    verify(questionsRepository.getFrequentlyAskedQuestions());
    verify(firebaseUser.email).called(1);
    verify(firebaseUser.displayName).called(2);
    verify(userRepository.isEmailVerified()).called(1);
    verifyNoMoreInteractions(firebaseUser);
    verifyNoMoreInteractions(questionsRepository);
    verifyNoMoreInteractions(userRepository);
  });
}
