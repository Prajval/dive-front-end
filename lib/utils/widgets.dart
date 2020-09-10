import 'package:dive/models/questions.dart';
import 'package:dive/router/router.dart';
import 'package:dive/utils/strings.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class ReusableWidgets {
  static getAppBar(String title, BuildContext context) {
    return AppBar(
        elevation: 3,
        backgroundColor: appBarColor,
        title: Text(title, style: TextStyle(color: whiteTextColor)));
  }

  static getAppBarWithAvatar(
      String title, BuildContext context, Key key, VoidCallback callback) {
    return AppBar(
        actions: <Widget>[
          FlatButton(
            key: key,
            onPressed: callback,
            child: CircleAvatar(
              backgroundColor: backgroundColor,
              child: Icon(
                Icons.person,
                color: appPrimaryColor,
              ),
            ),
          )
        ],
        elevation: 3,
        backgroundColor: appBarColor,
        title: Text(title, style: TextStyle(color: whiteTextColor)));
  }

  static getForm(Key key, TextEditingController controller,
      final String hintText, FormFieldValidator validator, Icon icon) {
    return TextFormField(
      key: key,
      controller: controller,
      decoration: InputDecoration(
          prefixIcon: icon, hintText: hintText, focusColor: appPrimaryColor),
      validator: validator,
    );
  }

  static getQuestionWithAnswer(BuildContext context, Question question) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: getAppBar(questionAnswerAppBar, context),
        body: getQuestionDetailsBody(question));
  }

  static getQuestionDetailsBody(Question question) {
    if (question.relatedQuestionAnswer.length > 1) {
      return ListView(children: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: 48.0, top: 15.0),
            child: Container(
                margin: const EdgeInsets.all(3.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    color: appPrimaryColor, borderRadius: radiusBubble),
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(question.question,
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
                    child: Text(questionUnavailableMessage,
                        style: TextStyle(color: blackTextColor))))),
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: question.relatedQuestionAnswer.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Padding(
                  padding: EdgeInsets.only(left: 48.0, top: 10.0),
                  child: Container(
                      margin: const EdgeInsets.all(3.0),
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          color: appPrimaryColor, borderRadius: radiusBubble),
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                              question.relatedQuestionAnswer[index].question,
                              style: TextStyle(color: whiteTextColor))))),
              onTap: () {
                Router.openQuestionWithAnswerRoute(
                    context, question.relatedQuestionAnswer[index].qid, true);
              },
            );
          },
        ),
        Padding(
            padding: EdgeInsets.only(left: 48.0, top: 10.0),
            child: Container(
                margin: const EdgeInsets.all(3.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    color: exclamationMessageColor, borderRadius: radiusBubble),
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(tapHereIfUnsatisfiedMessage,
                        style: TextStyle(color: whiteTextColor)))))
      ]);
    } else {
      return ListView(children: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: 48.0, top: 15.0),
            child: Container(
                margin: const EdgeInsets.all(3.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    color: appPrimaryColor, borderRadius: radiusBubble),
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(question.question,
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
                    child: Text(question.answer,
                        style: TextStyle(color: blackTextColor)))))
      ]);
    }
  }
}
