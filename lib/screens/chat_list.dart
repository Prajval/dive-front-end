import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/router/bottom_nav_router.dart';
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

class _ChatListScreenState extends State {
  List<Question> listOfQuestions;
  ChatListStatus status = ChatListStatus.LOADING;

  @override
  void initState() {
    super.initState();
    getLogger().d(initializingChatList);

    fetchQuestions(widget);
  }

  @override
  void dispose() {
    getLogger().d(disposingChatList);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (status == ChatListStatus.CHAT_LIST_FETCHED ||
        status == ChatListStatus.NO_QUESTIONS_ASKED_SO_FAR) {
      getLogger().d(chatDetailsLoaded);
      return ReusableWidgets.getQuestionsListWidget(
          context,
          (status == ChatListStatus.NO_QUESTIONS_ASKED_SO_FAR),
          listOfQuestions,
          chatListAppBar,
          Key(Keys.profileButton + 'chat_list'), () {
        BottomNavRouter.openAskQuestionRoute(context).then((_) {
          setState(() {
            status = ChatListStatus.LOADING;
            fetchQuestions(widget);
          });
        });
      }, "chat_list");
    } else if (status == ChatListStatus.LOADING) {
      getLogger().d(loadingChatDetails);
      return ReusableWidgets.buildWaitingScreen();
    } else {
      getLogger().d(errorLoadingChatDetails);
      return Scaffold(
          appBar: ReusableWidgets.getAppBarWithAvatar(
              chatListAppBar, context, Key(Keys.profileButton + 'chat_list')),
          body: ReusableWidgets.getErrorWidget(context, failedToFetchChatList,
              () {
            status = ChatListStatus.LOADING;
            fetchQuestions(widget);
          }));
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
