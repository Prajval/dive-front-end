import 'package:dive/base_state.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/push_notification/push_notification_service.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/router/router.dart';
import 'package:dive/router/router_keys.dart';
import 'package:dive/screens/bottom_nav_bar/home.dart';
import 'package:dive/screens/bottom_nav_bar/navigation_provider.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'base_state_test.dart';

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockFirebaseUser extends Mock implements User {}

class MockPNS extends Mock implements PushNotificationService {}

void main() {
  final MockUserRepository userRepository = MockUserRepository();
  final MockQuestionsRepository questionsRepository = MockQuestionsRepository();

  setUpAll(() {
    GetIt.instance.allowReassignment = true;

    GetIt.instance.registerSingleton<QuestionsRepository>(questionsRepository);
    GetIt.instance.registerSingleton<UserRepository>(userRepository);
    GetIt.instance.registerSingleton<PushNotificationService>(MockPNS());
    GetIt.instance
        .registerSingleton<GetLinksStreamWrapper>(GetLinksStreamWrapper());
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('should open home screen when user is signed in',
      (WidgetTester tester) async {
    MockFirebaseUser user = MockFirebaseUser();
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    QuestionsList questionsList =
        QuestionsList(noQuestionsAskedSoFar: true, list: new List<Question>());

    when(userRepository.getCurrentUser()).thenReturn(user);
    when(questionsRepository.getUserQuestions())
        .thenAnswer((_) => Future.value(questionsList));
    when(questionsRepository.getFrequentlyAskedQuestions())
        .thenAnswer((_) => Future.value(questionsList));

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

    verify(navigatorObserver.didPush(any, any));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(SigninScreen), findsNothing);

    verify(userRepository.getCurrentUser());
    verify(questionsRepository.getUserQuestions()).called(1);
    verify(questionsRepository.getFrequentlyAskedQuestions()).called(1);
    verifyNoMoreInteractions(questionsRepository);
    verifyNoMoreInteractions(user);
    verifyNoMoreInteractions(userRepository);
  });

  testWidgets('should open sign in screen when user is not signed in',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    when(userRepository.getCurrentUser()).thenReturn(null);

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: Router.generateRoute,
      initialRoute: RouterKeys.rootRoute,
      navigatorObservers: [navigatorObserver],
    ));
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPush(any, any));
    expect(find.byType(ChatListScreen), findsNothing);
    expect(find.byType(SigninScreen), findsOneWidget);

    verify(userRepository.getCurrentUser());
    verifyNoMoreInteractions(questionsRepository);
    verifyNoMoreInteractions(userRepository);
  });
}
