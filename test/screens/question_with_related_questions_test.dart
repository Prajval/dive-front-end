import 'package:dive/models/questions.dart';
import 'package:dive/screens/chat_list.dart';
import 'package:dive/screens/question_answer.dart';
import 'package:dive/screens/question_with_related_questions.dart';
import 'package:dive/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  testWidgets('should render question with related questions screen',
      (WidgetTester tester) async {
    String question1 = "How can depression be treated?";
    String question2 = "How do we know who is a good doctor?";
    String question3 = "How long does depression last?";
    String answer1 = "It can be treated in a variety of ways.";
    String answer2 = "Ah! That's a tough question.";
    String answer3 = "It varies in each individual and to various degrees.";

    RelatedQuestionAnswer relatedQuestionAnswer1 =
        RelatedQuestionAnswer(question: question1, answer: answer1);
    RelatedQuestionAnswer relatedQuestionAnswer2 =
        RelatedQuestionAnswer(question: question2, answer: answer2);
    RelatedQuestionAnswer relatedQuestionAnswer3 =
        RelatedQuestionAnswer(question: question3, answer: answer3);

    List<RelatedQuestionAnswer> relatedQuestionsAnswersList = [
      relatedQuestionAnswer1,
      relatedQuestionAnswer2,
      relatedQuestionAnswer3
    ];

    String question = "Can depression be treated?";

    await tester.pumpWidget(MaterialApp(
      home: QuestionWithRelatedQuestionsScreen(
        question: question,
        relatedQuestionsAndAnswers: relatedQuestionsAnswersList,
      ),
    ));

    expect(find.widgetWithText(AppBar, 'Related Questions'), findsOneWidget);
    expect(find.text('$question'), findsOneWidget);
    expect(find.text('$questionUnavailableMessage'), findsOneWidget);
    expect(find.widgetWithText(ListView, '$question1'), findsWidgets);
    expect(find.widgetWithText(ListView, '$question2'), findsWidgets);
    expect(find.widgetWithText(ListView, '$question3'), findsWidgets);
    expect(find.text('$tapHereIfUnsatisfiedMessage'), findsOneWidget);
  });

  testWidgets('should open related question number 1 when tapped',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    String question1 = "How can depression be treated?";
    String question2 = "How do we know who is a good doctor?";
    String question3 = "How long does depression last?";
    String answer1 = "It can be treated in a variety of ways.";
    String answer2 = "Ah! That's a tough question.";
    String answer3 = "It varies in each individual and to various degrees.";

    RelatedQuestionAnswer relatedQuestionAnswer1 =
        RelatedQuestionAnswer(question: question1, answer: answer1);
    RelatedQuestionAnswer relatedQuestionAnswer2 =
        RelatedQuestionAnswer(question: question2, answer: answer2);
    RelatedQuestionAnswer relatedQuestionAnswer3 =
        RelatedQuestionAnswer(question: question3, answer: answer3);

    List<RelatedQuestionAnswer> relatedQuestionsAnswersList = [
      relatedQuestionAnswer1,
      relatedQuestionAnswer2,
      relatedQuestionAnswer3
    ];

    String question = "Can depression be treated?";

    await tester.pumpWidget(MaterialApp(
      home: QuestionWithRelatedQuestionsScreen(
        question: question,
        relatedQuestionsAndAnswers: relatedQuestionsAnswersList,
      ),
      navigatorObservers: [navigatorObserver],
    ));

    expect(find.byType(QuestionAnswerScreen), findsNothing);
    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsOneWidget);

    final Finder relatedQuestion1 = find.text('$question1');
    await tester.tap(relatedQuestion1);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPush(any, any));

    expect(find.text('$question1'), findsOneWidget);
    expect(find.text('$answer1'), findsOneWidget);
    expect(find.byType(QuestionAnswerScreen), findsOneWidget);
    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsNothing);
  });

  testWidgets('should open related question number 2 when tapped',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    String question1 = "How can depression be treated?";
    String question2 = "How do we know who is a good doctor?";
    String question3 = "How long does depression last?";
    String answer1 = "It can be treated in a variety of ways.";
    String answer2 = "Ah! That's a tough question.";
    String answer3 = "It varies in each individual and to various degrees.";

    RelatedQuestionAnswer relatedQuestionAnswer1 =
        RelatedQuestionAnswer(question: question1, answer: answer1);
    RelatedQuestionAnswer relatedQuestionAnswer2 =
        RelatedQuestionAnswer(question: question2, answer: answer2);
    RelatedQuestionAnswer relatedQuestionAnswer3 =
        RelatedQuestionAnswer(question: question3, answer: answer3);

    List<RelatedQuestionAnswer> relatedQuestionsAnswersList = [
      relatedQuestionAnswer1,
      relatedQuestionAnswer2,
      relatedQuestionAnswer3
    ];

    String question = "Can depression be treated?";

    await tester.pumpWidget(MaterialApp(
      home: QuestionWithRelatedQuestionsScreen(
        question: question,
        relatedQuestionsAndAnswers: relatedQuestionsAnswersList,
      ),
      navigatorObservers: [navigatorObserver],
    ));

    expect(find.byType(QuestionAnswerScreen), findsNothing);
    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsOneWidget);

    final Finder relatedQuestion1 = find.text('$question2');
    await tester.tap(relatedQuestion1);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPush(any, any));

    expect(find.text('$question2'), findsOneWidget);
    expect(find.text('$answer2'), findsOneWidget);
    expect(find.byType(QuestionAnswerScreen), findsOneWidget);
    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsNothing);
  });

  testWidgets('should open related question number 3 when tapped',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    String question1 = "How can depression be treated?";
    String question2 = "How do we know who is a good doctor?";
    String question3 = "How long does depression last?";
    String answer1 = "It can be treated in a variety of ways.";
    String answer2 = "Ah! That's a tough question.";
    String answer3 = "It varies in each individual and to various degrees.";

    RelatedQuestionAnswer relatedQuestionAnswer1 =
        RelatedQuestionAnswer(question: question1, answer: answer1);
    RelatedQuestionAnswer relatedQuestionAnswer2 =
        RelatedQuestionAnswer(question: question2, answer: answer2);
    RelatedQuestionAnswer relatedQuestionAnswer3 =
        RelatedQuestionAnswer(question: question3, answer: answer3);

    List<RelatedQuestionAnswer> relatedQuestionsAnswersList = [
      relatedQuestionAnswer1,
      relatedQuestionAnswer2,
      relatedQuestionAnswer3
    ];

    String question = "Can depression be treated?";

    await tester.pumpWidget(MaterialApp(
      home: QuestionWithRelatedQuestionsScreen(
        question: question,
        relatedQuestionsAndAnswers: relatedQuestionsAnswersList,
      ),
      navigatorObservers: [navigatorObserver],
    ));

    expect(find.byType(QuestionAnswerScreen), findsNothing);
    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsOneWidget);

    final Finder relatedQuestion1 = find.text('$question3');
    await tester.tap(relatedQuestion1);
    await tester.pumpAndSettle();

    verify(navigatorObserver.didPush(any, any));

    expect(find.text('$question3'), findsOneWidget);
    expect(find.text('$answer3'), findsOneWidget);
    expect(find.byType(QuestionAnswerScreen), findsOneWidget);
    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsNothing);
  });

  testWidgets('should do nothing when tapHereIfUnsatisfied text is tapped',
      (WidgetTester tester) async {
    MockNavigatorObserver navigatorObserver = MockNavigatorObserver();

    String question1 = "How can depression be treated?";
    String question2 = "How do we know who is a good doctor?";
    String question3 = "How long does depression last?";
    String answer1 = "It can be treated in a variety of ways.";
    String answer2 = "Ah! That's a tough question.";
    String answer3 = "It varies in each individual and to various degrees.";

    RelatedQuestionAnswer relatedQuestionAnswer1 =
        RelatedQuestionAnswer(question: question1, answer: answer1);
    RelatedQuestionAnswer relatedQuestionAnswer2 =
        RelatedQuestionAnswer(question: question2, answer: answer2);
    RelatedQuestionAnswer relatedQuestionAnswer3 =
        RelatedQuestionAnswer(question: question3, answer: answer3);

    List<RelatedQuestionAnswer> relatedQuestionsAnswersList = [
      relatedQuestionAnswer1,
      relatedQuestionAnswer2,
      relatedQuestionAnswer3
    ];

    String question = "Can depression be treated?";

    await tester.pumpWidget(MaterialApp(
      home: QuestionWithRelatedQuestionsScreen(
        question: question,
        relatedQuestionsAndAnswers: relatedQuestionsAnswersList,
      ),
      navigatorObservers: [navigatorObserver],
    ));

    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsOneWidget);

    final Finder tapHereIfUnsatisfiedText =
        find.text('$tapHereIfUnsatisfiedMessage');
    await tester.tap(tapHereIfUnsatisfiedText);

    verify(navigatorObserver.didPush(any, any)).called(1);

    expect(find.byType(QuestionWithRelatedQuestionsScreen), findsOneWidget);
  });
}
