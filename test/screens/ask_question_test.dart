import 'package:dive/screens/ask_question.dart';
import 'package:dive/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should load ask questions screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AskQuestionScreen(),
    ));

    expect(find.widgetWithText(AppBar, 'New Question'), findsOneWidget);
    expect(find.widgetWithText(TextField, '$typeQuestionHere'), findsOneWidget);
  });
}
