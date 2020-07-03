import 'package:flutter/material.dart';
import 'package:dive/question-answer/utils/constants.dart';
import 'package:dive/question-answer/screens/question_answer.dart';


class RelatedQuestionAnswer {
  final String question;
  final String answer;

  RelatedQuestionAnswer({this.question, this.answer});
}


class QuestionWithRelatedQuestionsScreen extends StatefulWidget {


  final String question;
  final List<RelatedQuestionAnswer> relatedQuestionsAndAnswers;

  QuestionWithRelatedQuestionsScreen({
    @required this.question,
    @required this.relatedQuestionsAndAnswers
  });


  @override
  _QuestionWithRelatedQuestionsScreenState createState() => _QuestionWithRelatedQuestionsScreenState();
}


class _QuestionWithRelatedQuestionsScreenState extends State<QuestionWithRelatedQuestionsScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
            elevation: 3,
            backgroundColor: appBarColor,
            leading: IconButton(
                icon: Icon(Icons.keyboard_backspace),
                onPressed: () => Navigator.pop(context)
            )
        ),

        body: ListView(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 48.0, top: 15.0),
                  child: Container(
                      margin: const EdgeInsets.all(3.0),
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(color: appBarColor, borderRadius: radiusBubble),
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(widget.question, style: TextStyle(color: whiteTextColor))
                      )
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(left: 48.0, top: 10.0),
                  child: Container(
                      margin: const EdgeInsets.all(3.0),
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(color: answerBubbleColor, borderRadius: radiusBubble),
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                              questionUnavailableMessage,
                              style: TextStyle(color: blackTextColor)
                          )
                      )
                  )
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: widget.relatedQuestionsAndAnswers.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      child: Padding(
                          padding: EdgeInsets.only(left: 48.0, top: 10.0),
                          child: Container(
                              margin: const EdgeInsets.all(3.0),
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(color: appBarColor, borderRadius: radiusBubble),
                              child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                      widget.relatedQuestionsAndAnswers[index].question,
                                      style: TextStyle(color: whiteTextColor)
                                  )
                              )
                          )
                      ),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(builder: (context) =>
                          new QuestionAnswerScreen(
                              question: widget.relatedQuestionsAndAnswers[index].question,
                              answer: widget.relatedQuestionsAndAnswers[index].answer)
                          )
                      );
                    },
                  );
                },
              ),
              Padding(
                  padding: EdgeInsets.only(left: 48.0, top: 10.0),
                  child: Container(
                      margin: const EdgeInsets.all(3.0),
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(color: exclamationMessageColor, borderRadius: radiusBubble),
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                              tapHereIfUnsatisfiedMessage,
                              style: TextStyle(color: whiteTextColor)
                          )
                      )
                  )
              )
            ]
        )
    );
  }
}