import 'package:dive/question-answer/screens/ask_question.dart';
import 'package:dive/question-answer/screens/question_answer.dart';
import 'package:dive/question-answer/screens/question_with_related_questions.dart';
import 'package:dive/question-answer/utils/constants.dart';
import 'package:flutter/material.dart';


class QuestionTree {

  final String question;
  final String answer;
  final List<RelatedQuestionAnswer> relatedQuestionAnswer;
  final String time;

  QuestionTree({this.question, this.answer, this.relatedQuestionAnswer, this.time});
}


class ChatListScreen extends StatefulWidget {


  final List<QuestionTree> listOfQuestions;
  ChatListScreen({this.listOfQuestions});


  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}


class _ChatListScreenState extends State<ChatListScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
            elevation: 3,
            backgroundColor: appBarColor,
            //title: Text(questions, style: TextStyle(color: whiteTextColor))
            title: Text(questions, style: TextStyle(color: whiteTextColor))
        ),
        body: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.listOfQuestions.length,
            itemBuilder: (context, index) {
              return Column(
                  children: <Widget> [
                    ListTile(
                        title: Container(
                            margin: const EdgeInsets.all(3.0),
                            padding: const EdgeInsets.all(5.0),
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                    widget.listOfQuestions[index].question,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: blackTextColor),
                                    maxLines: 2
                                )
                            )
                        ),
                        trailing: Text(
                            "${widget.listOfQuestions[index].time}",
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.right
                        ),
                        onTap: () {
                          if (widget.listOfQuestions[index].answer != null) {
                            Navigator.push(context,
                                new MaterialPageRoute(builder: (context) =>
                                new QuestionAnswerScreen(
                                    question: widget.listOfQuestions[index].question,
                                    answer: widget.listOfQuestions[index].answer)
                                )
                            );
                          } else {
                            Navigator.push(context,
                                new MaterialPageRoute(builder: (context) =>
                                new QuestionWithRelatedQuestionsScreen(
                                    question: widget.listOfQuestions[index].question,
                                    relatedQuestionsAndAnswers: widget.listOfQuestions[index].relatedQuestionAnswer)
                                )
                            );
                          }
                        }
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 0.5,
                        child: Divider(),
                      ),
                    )
                  ]
              );
            }
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: appBarColor,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AskQuestionScreen()),
            );
          },
        )
    );
  }
}