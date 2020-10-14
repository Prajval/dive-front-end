import 'package:dive/base_state.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/router/tab_router.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/material.dart';

enum ChatListStatus {
  LOADING,
  CHAT_LIST_FETCHED,
  ERROR_FETCHING_CHAT_LIST,
  NO_QUESTIONS_ASKED_SO_FAR
}

class ChatListScreen extends StatefulWidget {
  final QuestionsRepository questionsRepository;

  ChatListScreen({this.questionsRepository});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends BaseState<ChatListScreen> {
  List<Question> listOfQuestions;
  ChatListStatus status = ChatListStatus.LOADING;

  @override
  void initState() {
    super.initState();
    subscribeToLinksStream();
    getLogger().d(initializingChatList);

    fetchQuestions(widget);
  }

  @override
  void dispose() {
    getLogger().d(disposingChatList);
    unsubscribeToLinksStream();
    super.dispose();
  }

  Widget getChatListBody() {
    if (status == ChatListStatus.CHAT_LIST_FETCHED) {
      return ListView.builder(
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
                    TabRouter.openQuestionWithAnswerRoute(
                        context, listOfQuestions[index].qid, false);
                  }),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 0.5,
                  child: Divider(),
                ),
              )
            ]);
          });
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

  Widget getChatList() {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: ReusableWidgets.getAppBarWithAvatar(
            chatListAppBar, context, Key(Keys.profileButton)),
        body: getChatListBody(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: appPrimaryColor,
          child: Icon(
            Icons.add,
            color: appWhiteColor,
          ),
          onPressed: () {
            TabRouter.openAskQuestionRoute(context).then((_) {
              setState(() {
                status = ChatListStatus.LOADING;
                fetchQuestions(widget);
              });
            });
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
            chatListAppBar, context, Key(Keys.profileButton)),
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ChatScreenArguments arguments = (ModalRoute.of(context).settings == null)
          ? null
          : (ModalRoute.of(context).settings.arguments);

      if (arguments != null) {
        arguments.callback(context);
      }
    });

    if (status == ChatListStatus.CHAT_LIST_FETCHED ||
        status == ChatListStatus.NO_QUESTIONS_ASKED_SO_FAR) {
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

  void fetchQuestions(ChatListScreen widget) {
    widget.questionsRepository.getUserQuestions().then((questionsList) {
      listOfQuestions = questionsList.list;
      setState(() {
        if (questionsList.noQuestionsAskedSoFar == true)
          status = ChatListStatus.NO_QUESTIONS_ASKED_SO_FAR;
        else
          status = ChatListStatus.CHAT_LIST_FETCHED;
      });
    }).catchError((error) {
      setState(() {
        status = ChatListStatus.ERROR_FETCHING_CHAT_LIST;
      });
    });
  }
}

class ChatScreenArguments {
  Function(BuildContext) callback;

  ChatScreenArguments({this.callback});
}
