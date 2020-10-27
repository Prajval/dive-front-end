import 'package:dive/models/questions.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should build standard app bar', (WidgetTester tester) async {
    String title = 'title';

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ReusableWidgets.getAppBar(title, context);
        },
      ),
    ));

    expect(find.widgetWithText(AppBar, '$title'), findsOneWidget);
  });

  testWidgets('should build app bar with avatar', (WidgetTester tester) async {
    String title = 'title';

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ReusableWidgets.getAppBarWithAvatar(
              title, context, Key(Keys.profileButton));
        },
      ),
    ));

    expect(find.widgetWithText(AppBar, '$title'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.widgetWithIcon(FlatButton, Icons.person), findsOneWidget);
  });

  testWidgets('should render form', (WidgetTester tester) async {
    String hintText = 'hintText';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ReusableWidgets.getForm(
            Key(Keys.emailFormForSignUp),
            TextEditingController(),
            hintText,
            (value) => null,
            Icon(Icons.email)),
      ),
    ));

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '$hintText'), findsOneWidget);
  });

  testWidgets(
      'get question with answer should render question with just answer'
      'when the question matches the golden question',
      (WidgetTester tester) async {
    String questionText = 'How long will depression last?';
    int qid = 4;
    String answer = '3 months';
    Question question = Question(
        qid: qid,
        question: questionText,
        answer: answer,
        relatedQuestionAnswer: []);

    await tester.pumpWidget(MaterialApp(home: Builder(
      builder: (BuildContext context) {
        return ReusableWidgets.getQuestionWithAnswer(context, question);
      },
    )));
    await tester.pumpAndSettle();

    expect(
        find.widgetWithText(AppBar, '$questionAnswerAppBar'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text(questionText), findsOneWidget);
    expect(find.text(answer), findsOneWidget);
  });

  testWidgets(
      'get question with answer should render question with related questions'
      'when the question doesnt match a golden question',
      (WidgetTester tester) async {
    String q1Text = 'What?';
    String q2Text = 'When?';
    String q3Text = 'Why?';
    RelatedQuestionAnswer q1 =
        RelatedQuestionAnswer(qid: 1, question: q1Text, answer: 'answer1');
    RelatedQuestionAnswer q2 =
        RelatedQuestionAnswer(qid: 2, question: q2Text, answer: 'answer2');
    RelatedQuestionAnswer q3 =
        RelatedQuestionAnswer(qid: 3, question: q3Text, answer: 'answer3');

    String questionText = 'How long will depression last?';
    int qid = 4;
    String answer = '3 months';
    Question question = Question(
        qid: qid,
        question: questionText,
        answer: answer,
        relatedQuestionAnswer: [q1, q2, q3]);

    await tester.pumpWidget(MaterialApp(home: Builder(
      builder: (BuildContext context) {
        return ReusableWidgets.getQuestionWithAnswer(context, question);
      },
    )));
    await tester.pumpAndSettle();

    expect(
        find.widgetWithText(AppBar, '$questionAnswerAppBar'), findsOneWidget);
    expect(find.byType(ListView), findsNWidgets(2));
    expect(find.text(questionText), findsOneWidget);
    expect(find.text(questionUnavailableMessage), findsOneWidget);
    expect(find.text(q1Text), findsOneWidget);
    expect(find.text(q2Text), findsOneWidget);
    expect(find.text(q3Text), findsOneWidget);
    expect(find.text(tapHereIfUnsatisfiedMessage), findsOneWidget);
    expect(find.text(answer), findsNothing);
  });

  testWidgets('should build waiting screen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ReusableWidgets.buildWaitingScreen();
        },
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should build error loading questions list widget',
      (WidgetTester tester) async {
    String messageToDisplay = 'message';

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ReusableWidgets.getErrorWidget(
              context, messageToDisplay, () {});
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text(messageToDisplay), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.text(error), findsOneWidget);
    expect(find.text(tryAgain), findsOneWidget);
    expect(find.widgetWithText(FlatButton, refreshButton), findsOneWidget);
  });

  testWidgets('should build questions list widget with questions',
      (WidgetTester tester) async {
    String appBarTitle = 'app bar title';
    Key key = Key('test key');
    bool noQuestionsAsked = false;

    String question = "Can depression be treated?";
    String answer = "Yes, it can be treated!";
    String time = "5d ago";
    List<Question> questionTree = [
      Question(question: question, answer: answer, time: time)
    ];

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ReusableWidgets.getQuestionsListWidget(
            context,
            noQuestionsAsked,
            questionTree,
            appBarTitle,
            key,
            () {},
            "test_tag",
          );
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, appBarTitle), findsOneWidget);
    expect(find.widgetWithIcon(CircleAvatar, Icons.person), findsOneWidget);
    expect(find.byKey(key), findsOneWidget);
    expect(
        find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.widgetWithText(ListTile, question), findsOneWidget);
  });

  testWidgets(
      'should build questions list widget with no questions asked so far message'
      'when there are no questions asked so far', (WidgetTester tester) async {
    String appBarTitle = 'app bar title';
    Key key = Key('test key');
    bool noQuestionsAsked = true;

    List<Question> questionTree = [];

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ReusableWidgets.getQuestionsListWidget(
            context,
            noQuestionsAsked,
            questionTree,
            appBarTitle,
            key,
            () {},
            "test_tag",
          );
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, appBarTitle), findsOneWidget);
    expect(find.widgetWithIcon(CircleAvatar, Icons.person), findsOneWidget);
    expect(find.byKey(key), findsOneWidget);
    expect(
        find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.text(noQuestionsAskedPrompt), findsOneWidget);
  });
}
