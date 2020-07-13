import 'package:dive/screens/question_answer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should display the question and the answer to the question',
      (WidgetTester tester) async {
    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";

    await tester.pumpWidget(MaterialApp(
      home: QuestionAnswerScreen(
        question: question,
        answer: answer,
      ),
    ));

    expect(find.widgetWithText(AppBar, 'Questions'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('$question'), findsOneWidget);
    expect(find.text('$answer'), findsOneWidget);
  });
}
