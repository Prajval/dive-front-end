import 'package:dive/base_state.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/material.dart';

class QuestionAnswerScreen extends StatefulWidget {
  final String question, answer;

  QuestionAnswerScreen({@required this.question, @required this.answer});

  @override
  _QuestionAnswerScreenState createState() => _QuestionAnswerScreenState();
}

class _QuestionAnswerScreenState extends BaseState<QuestionAnswerScreen> {
  @override
  void initState() {
    super.initState();
    subscribeToLinksStream();
    getLogger().d(initializingQuestionAnswer);
  }

  @override
  void dispose() {
    getLogger().d(disposingQuestionAnswer);
    unsubscribeToLinksStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: ReusableWidgets.getAppBar(questionAnswerAppBar, context),
        body: ListView(children: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 48.0, top: 15.0),
              child: Container(
                  margin: const EdgeInsets.all(3.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      color: appPrimaryColor, borderRadius: radiusBubble),
                  child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(widget.question,
                          style: TextStyle(color: whiteTextColor))))),
          Padding(
              padding: EdgeInsets.only(left: 48.0, top: 10.0),
              child: Container(
                  margin: const EdgeInsets.all(3.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      color: answerBubbleColor, borderRadius: radiusBubble),
                  child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(widget.answer,
                          style: TextStyle(color: blackTextColor)))))
        ]));
  }
}
