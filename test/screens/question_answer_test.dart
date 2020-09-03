import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/screens/question_answer.dart';
import 'package:dive/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

void main() {
  final questionsRepository = MockQuestionsRepository();

  testWidgets(
      'should display the question and the answer to the question when'
      ' the question is a golden question', (WidgetTester tester) async {
    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";

    when(questionsRepository.getQuestionDetails(qid: 4, isGolden: true))
        .thenAnswer((_) => Future.value(Question(
            qid: 4,
            question: question,
            answer: answer,
            relatedQuestionAnswer: [])));

    await tester.pumpWidget(MaterialApp(
      home: QuestionAnswerScreen(
        qid: 4,
        isGolden: true,
        questionsRepository: questionsRepository,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Questions'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('$question'), findsOneWidget);
    expect(find.text('$answer'), findsOneWidget);

    verify(questionsRepository.getQuestionDetails(qid: 4, isGolden: true))
        .called(1);
    verifyNoMoreInteractions(questionsRepository);
  });

  testWidgets(
      'should display the question and the related questions to the question when'
      ' the question is not a golden question', (WidgetTester tester) async {
    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";

    when(questionsRepository.getQuestionDetails(qid: 4, isGolden: false))
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
      home: QuestionAnswerScreen(
        qid: 4,
        isGolden: false,
        questionsRepository: questionsRepository,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Questions'), findsOneWidget);
    expect(find.byType(ListView), findsNWidgets(2));
    expect(find.text('$question'), findsOneWidget);
    expect(find.text('q1'), findsOneWidget);
    expect(find.text('q2'), findsOneWidget);
    expect(find.text('q3'), findsOneWidget);
    expect(find.text(questionUnavailableMessage), findsOneWidget);
    expect(find.text(tapHereIfUnsatisfiedMessage), findsOneWidget);
    expect(find.text('$answer'), findsNothing);

    verify(questionsRepository.getQuestionDetails(qid: 4, isGolden: false))
        .called(1);
    verifyNoMoreInteractions(questionsRepository);
  });

  testWidgets(
      'should display error when there is an error fetching question details',
      (WidgetTester tester) async {
    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";

    when(questionsRepository.getQuestionDetails(qid: 4, isGolden: true))
        .thenAnswer((_) => Future.error('error'));

    await tester.pumpWidget(MaterialApp(
      home: QuestionAnswerScreen(
        qid: 4,
        isGolden: true,
        questionsRepository: questionsRepository,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Questions'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.text('$question'), findsNothing);
    expect(find.text('$answer'), findsNothing);
    expect(find.text(failedToFetchQuestionDetails), findsOneWidget);

    verify(questionsRepository.getQuestionDetails(qid: 4, isGolden: true))
        .called(1);
    verifyNoMoreInteractions(questionsRepository);
  });
}
