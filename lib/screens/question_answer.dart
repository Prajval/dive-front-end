import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/material.dart';

enum QuestionAnswerStatus { LOADING, FETCHED, ERROR_FETCHING_QUESTION }

class QuestionAnswerScreen extends StatefulWidget {
  final int qid;
  final bool isGolden;
  final QuestionsRepository questionsRepository;

  QuestionAnswerScreen(
      {@required this.qid, @required this.isGolden, this.questionsRepository});

  @override
  _QuestionAnswerScreenState createState() => _QuestionAnswerScreenState();
}

class _QuestionAnswerScreenState extends State {
  Question question;
  QuestionAnswerStatus status = QuestionAnswerStatus.LOADING;

  @override
  void initState() {
    super.initState();
    getLogger().d(initializingQuestionAnswer);

    fetchQuestionDetails(widget);
  }

  @override
  void dispose() {
    getLogger().d(disposingQuestionAnswer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (status == QuestionAnswerStatus.LOADING) {
      getLogger().d(loadingQuestionDetails);
      return buildWaitingScreen();
    } else if (status == QuestionAnswerStatus.ERROR_FETCHING_QUESTION) {
      getLogger().d(errorLoadingQuestionDetails);
      return buildErrorLoadingQuestionDetails();
    } else {
      getLogger().d(questionDetailsLoaded);
      return buildQuestionDetails();
    }
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildQuestionDetails() {
    return ReusableWidgets.getQuestionWithAnswer(context, question);
  }

  Widget buildErrorLoadingQuestionDetails() {
    return Scaffold(
        appBar: ReusableWidgets.getAppBar(questionAnswerAppBar, context),
        body: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                failedToFetchQuestionDetails,
                style: TextStyle(
                    color: blackTextColor,
                    fontSize: 20,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ));
  }

  void fetchQuestionDetails(QuestionAnswerScreen widget) {
    widget.questionsRepository
        .getQuestionDetails(qid: widget.qid, isGolden: widget.isGolden)
        .then((questionDetails) {
      setState(() {
        question = questionDetails;
        status = QuestionAnswerStatus.FETCHED;
      });
    }).catchError((error) {
      setState(() {
        status = QuestionAnswerStatus.ERROR_FETCHING_QUESTION;
      });
    });
  }
}
