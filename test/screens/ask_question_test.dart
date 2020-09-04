import 'package:dive/base_state.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/screens/ask_question.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

void main() {
  setUpAll(() {
    GetIt.instance.allowReassignment = true;
    GetIt.instance
        .registerSingleton<GetLinksStreamWrapper>(GetLinksStreamWrapper());
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('should load ask question screen', (WidgetTester tester) async {
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();

    await tester.pumpWidget(MaterialApp(
      home: AskQuestionScreen(
        questionsRepository: questionsRepository,
      ),
    ));

    expect(find.widgetWithText(AppBar, 'New Question'), findsOneWidget);
    expect(find.widgetWithText(TextField, '$typeQuestionHere'), findsOneWidget);
  });

  testWidgets(
      'should ask new question and show error if failed to get the answer from backend',
      (WidgetTester tester) async {
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();

    await tester.pumpWidget(MaterialApp(
      home: AskQuestionScreen(
        questionsRepository: questionsRepository,
      ),
    ));

    expect(find.widgetWithText(AppBar, 'New Question'), findsOneWidget);
    expect(find.widgetWithText(TextField, '$typeQuestionHere'), findsOneWidget);

    when(questionsRepository.askQuestion('question'))
        .thenAnswer((_) => Future.error('error'));

    final TextField askQuestionButton =
        tester.widget(find.byKey(Key(Keys.askQuestion)));
    final Finder askQuestionField =
        find.widgetWithText(TextField, typeQuestionHere);
    await tester.tap(askQuestionField);
    await tester.enterText(askQuestionField, 'question');
    askQuestionButton.onSubmitted(askQuestionButton.controller.text);
    await tester.pumpAndSettle();

    expect(find.text('Error'), findsOneWidget);
  });

  testWidgets('should ask new question and fetch the answer from backend',
      (WidgetTester tester) async {
    MockQuestionsRepository questionsRepository = MockQuestionsRepository();
    String question = 'How long will depression last';
    String answer = '3 months';

    await tester.pumpWidget(MaterialApp(
      home: AskQuestionScreen(
        questionsRepository: questionsRepository,
      ),
    ));

    expect(find.widgetWithText(AppBar, 'New Question'), findsOneWidget);
    expect(find.widgetWithText(TextField, '$typeQuestionHere'), findsOneWidget);

    when(questionsRepository.askQuestion(question)).thenAnswer((_) =>
        Future.value(Question(
            question: question,
            answer: answer,
            relatedQuestionAnswer: [
              RelatedQuestionAnswer(
                  question: 'When will depression end?', answer: '3 months')
            ])));

    final TextField askQuestionButton =
        tester.widget(find.byKey(Key(Keys.askQuestion)));
    final Finder askQuestionField =
        find.widgetWithText(TextField, typeQuestionHere);
    await tester.tap(askQuestionField);
    await tester.enterText(askQuestionField, '$question');
    askQuestionButton.onSubmitted(askQuestionButton.controller.text);
    await tester.pumpAndSettle();

    verify(questionsRepository.askQuestion(question)).called(1);

    expect(find.text(question), findsOneWidget);
    expect(find.text(answer), findsOneWidget);
  });
}
