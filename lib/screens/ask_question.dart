import 'package:dive/base_state.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/material.dart';

enum NewQuestionStatus { ASK_NEW_QUESTION, ANSWER_FETCHED, ERROR }

class AskQuestionScreen extends StatefulWidget {
  final QuestionsRepository questionsRepository;

  AskQuestionScreen({this.questionsRepository});

  @override
  _AskQuestionScreenState createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends BaseState<AskQuestionScreen> {
  final inputQuestionController = TextEditingController();
  NewQuestionStatus status = NewQuestionStatus.ASK_NEW_QUESTION;
  Question question;

  @override
  void initState() {
    super.initState();
    subscribeToLinksStream();
    getLogger().d(initializingAskQuestion);
  }

  @override
  void dispose() {
    getLogger().d(disposingAskQuestion);
    inputQuestionController.dispose();
    unsubscribeToLinksStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (status == NewQuestionStatus.ASK_NEW_QUESTION) {
      return buildAskNewQuestion();
    } else if (status == NewQuestionStatus.ERROR) {
      return Text(
        'Error',
        style: TextStyle(
            color: blackTextColor,
            fontSize: 20,
            letterSpacing: 1,
            fontWeight: FontWeight.bold),
      );
    } else {
      return buildNewQuestionWithAnswer(question);
    }
  }

  Widget buildAskNewQuestion() {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: ReusableWidgets.getAppBar(newQuestionAppBar, context),
        body: Padding(
            padding: EdgeInsets.only(right: 48.0, top: 15.0),
            child: Container(
                margin: const EdgeInsets.all(3.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    color: appPrimaryColor, borderRadius: radiusBubble),
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: TextField(
                        key: Key(Keys.askQuestion),
                        controller: inputQuestionController,
                        decoration: InputDecoration.collapsed(
                            hintText: typeQuestionHere,
                            hintStyle: TextStyle(color: hintColor)),
                        style: TextStyle(color: whiteTextColor),
                        onSubmitted: (enteredQuestion) {
                          validateAndAskNewQuestion(enteredQuestion);
                        },
                        maxLines: null,
                        keyboardType: TextInputType.text,
                        cursorColor: whiteTextColor)))));
  }

  Widget buildNewQuestionWithAnswer(Question newQuestion) {
    return ReusableWidgets.getQuestionWithAnswer(context, newQuestion);
  }

  validateAndAskNewQuestion(String enteredQuestion) {
    widget.questionsRepository.askQuestion(enteredQuestion).then((newQuestion) {
      setState(() {
        question = newQuestion;
        status = NewQuestionStatus.ANSWER_FETCHED;
      });
    }).catchError((error) {
      setState(() {
        status = NewQuestionStatus.ERROR;
      });
    });
  }
}
