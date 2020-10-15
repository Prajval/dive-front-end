import 'package:dive/models/questions.dart';
import 'package:dive/router/bottom_nav_router.dart';
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

  static getAppBarWithAvatar(String title, BuildContext context, Key key) {
    return AppBar(
        actions: <Widget>[
          FlatButton(
            key: key,
            onPressed: () {
              Router.openProfileRoute(context);
            },
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
                BottomNavRouter.openQuestionWithAnswerRoute(
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

  static displayDialog(BuildContext context, String title, String dialogMessage,
      String dialogButtonMessage, VoidCallback callback) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(dialogMessage),
            actions: <Widget>[
              FlatButton(
                child: Text(dialogButtonMessage),
                onPressed: () {
                  Navigator.of(context).pop();
                  callback();
                },
              )
            ],
          );
        });
  }

  static _getQuestionsListBody(
      bool noQuestionsAsked, List<Question> listOfQuestions) {
    if (!noQuestionsAsked) {
      return ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: listOfQuestions.length,
        itemBuilder: (context, index) {
          return ListTile(
              title: Container(
                  margin: const EdgeInsets.all(3.0),
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(listOfQuestions[index].question,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: blackTextColor),
                          maxLines: 2))),
              trailing: Text("${listOfQuestions[index].time}",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.right),
              onTap: () {
                BottomNavRouter.openQuestionWithAnswerRoute(
                    context, listOfQuestions[index].qid, false);
              });
        },
        separatorBuilder: (BuildContext context, int index) {
          return Align(
            alignment: Alignment.center,
            child: Container(
              height: 0.5,
              child: Divider(),
            ),
          );
        },
      );
    } else {
      return Text(
        '$noQuestionsAskedPrompt',
        style: TextStyle(
            color: blackTextColor,
            fontSize: 20,
            letterSpacing: 1,
            fontWeight: FontWeight.bold),
      );
    }
  }

  static getQuestionsListWidget(
      BuildContext context,
      bool noQuestionsAsked,
      List<Question> listOfQuestions,
      String appBarTitle,
      Key key,
      VoidCallback fabCallback,
      String fabTag) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: getAppBarWithAvatar(appBarTitle, context, key),
        body: _getQuestionsListBody(noQuestionsAsked, listOfQuestions),
        floatingActionButton: FloatingActionButton(
          heroTag: "fab" + fabTag,
          backgroundColor: appPrimaryColor,
          child: Icon(
            Icons.add,
            color: appWhiteColor,
          ),
          onPressed: fabCallback,
        ));
  }

  static getErrorLoadingQuestionsListWidget(BuildContext context,
      String appBarTitle, Key key, String messageToDisplay) {
    return Scaffold(
        appBar: ReusableWidgets.getAppBarWithAvatar(appBarTitle, context, key),
        body: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                messageToDisplay,
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

  static buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
