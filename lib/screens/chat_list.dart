import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/screens/ask_question.dart';
import 'package:dive/screens/profile.dart';
import 'package:dive/screens/question_answer.dart';
import 'package:dive/screens/question_with_related_questions.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/material.dart';

import '../utils/auth.dart';

enum ChatListStatus { LOADING, CHAT_LIST_FETCHED, ERROR_FETCHING_CHAT_LIST }

class ChatListScreen extends StatefulWidget {
  final QuestionsRepository questionsRepository;
  final Auth auth;

  ChatListScreen({this.auth, this.questionsRepository});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<QuestionTree> listOfQuestions;
  ChatListStatus status = ChatListStatus.LOADING;

  @override
  void initState() {
    super.initState();
    getLogger().d(initializingChatList);

    widget.questionsRepository.getQuestions().then((questions) {
      listOfQuestions = questions;
      setState(() {
        status = ChatListStatus.CHAT_LIST_FETCHED;
      });
    }).catchError((error) {
      setState(() {
        status = ChatListStatus.ERROR_FETCHING_CHAT_LIST;
      });
    });
  }

  @override
  void dispose() {
    getLogger().d(disposingChatList);
    super.dispose();
  }

  Widget getChatList() {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: ReusableWidgets.getAppBarWithAvatar(
            chatListAppBar, context, widget.auth, Key(Keys.profileButton), () {
          Navigator.push(context, MaterialPageRoute(
            builder: (BuildContext context) {
              return ProfileScreen(widget.auth);
            },
          ));
        }),
        body: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: listOfQuestions.length,
            itemBuilder: (context, index) {
              return Column(children: <Widget>[
                ListTile(
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
                      if (listOfQuestions[index].answer != null) {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new QuestionAnswerScreen(
                                    question: listOfQuestions[index].question,
                                    answer: listOfQuestions[index].answer)));
                      } else {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                    new QuestionWithRelatedQuestionsScreen(
                                        question:
                                            listOfQuestions[index].question,
                                        relatedQuestionsAndAnswers:
                                            listOfQuestions[index]
                                                .relatedQuestionAnswer)));
                      }
                    }),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 0.5,
                    child: Divider(),
                  ),
                )
              ]);
            }),
        floatingActionButton: FloatingActionButton(
          backgroundColor: appPrimaryColor,
          child: Icon(
            Icons.add,
            color: appWhiteColor,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AskQuestionScreen()),
            );
          },
        ));
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildErrorLoadingChatDetails() {
    return Scaffold(
        appBar: ReusableWidgets.getAppBarWithAvatar(
            chatListAppBar, context, widget.auth, Key(Keys.profileButton), () {
          Navigator.push(context, MaterialPageRoute(
            builder: (BuildContext context) {
              return ProfileScreen(widget.auth);
            },
          ));
        }),
        body: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                failedToFetchChatList,
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

  @override
  Widget build(BuildContext context) {
    if (status == ChatListStatus.CHAT_LIST_FETCHED) {
      getLogger().d(chatDetailsLoaded);
      return getChatList();
    } else if (status == ChatListStatus.LOADING) {
      getLogger().d(loadingChatDetails);
      return buildWaitingScreen();
    } else {
      getLogger().d(errorLoadingChatDetails);
      return buildErrorLoadingChatDetails();
    }
  }
}
