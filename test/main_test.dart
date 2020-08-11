import 'package:dive/main.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/register_repo.dart';
import 'package:dive/root.dart';
import 'package:dive/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

class MockClient extends Mock implements Client {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

class MockRegisterRepository extends Mock implements RegisterRepository {}

void main() {
  setUpAll(() {
    MockClient client = MockClient();
    GetIt.instance.registerSingleton<Client>(client);
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();
    MockRegisterRepository registerRepository = MockRegisterRepository();
    GetIt.instance.registerSingleton<QuestionsRepository>(questionsRepository);
    GetIt.instance.registerSingleton<RegisterRepository>(registerRepository);
    GetIt.instance.allowReassignment = true;
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('should open Root screen when app is opened',
      (WidgetTester tester) async {
    MockAuth auth = MockAuth();
    GetIt.instance.registerSingleton<BaseAuth>(auth);
    when(auth.getCurrentUser()).thenAnswer((_) async => null);

    await tester.pumpWidget(DiveApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Root), findsOneWidget);

    verify(auth.getCurrentUser()).called(1);
    verifyNoMoreInteractions(auth);
  });
}
