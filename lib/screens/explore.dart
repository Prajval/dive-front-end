import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/router/bottom_nav_router.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/material.dart';

enum ExploreStatus {
  LOADING,
  FAQ_FETCHED,
  ERROR_FETCHING_FAQ,
  NO_QUESTIONS_ASKED_SO_FAR,
}

class ExploreScreen extends StatefulWidget {
  final QuestionsRepository questionsRepository;

  ExploreScreen({this.questionsRepository});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State {
  List<Question> listOfQuestions;
  ExploreStatus status = ExploreStatus.LOADING;

  @override
  void initState() {
    super.initState();
    getLogger().d(initializingExplore);

    fetchQuestions(widget);
  }

  @override
  void dispose() {
    getLogger().d(disposingExplore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (status == ExploreStatus.FAQ_FETCHED ||
        status == ExploreStatus.NO_QUESTIONS_ASKED_SO_FAR) {
      getLogger().d(faqLoaded);
      return ReusableWidgets.getQuestionsListWidget(
          context,
          (status == ExploreStatus.NO_QUESTIONS_ASKED_SO_FAR),
          listOfQuestions,
          exploreAppBar,
          Key(Keys.profileButton + 'explore'), () {
        BottomNavRouter.openAskQuestionRoute(context).then((_) {
          setState(() {
            status = ExploreStatus.LOADING;
            fetchQuestions(widget);
          });
        });
      }, "explore");
    } else if (status == ExploreStatus.LOADING) {
      getLogger().d(loadingFAQ);
      return ReusableWidgets.buildWaitingScreen();
    } else {
      getLogger().d(errorLoadingFAQ);
      return ReusableWidgets.getErrorLoadingQuestionsListWidget(
          context,
          exploreAppBar,
          Key(Keys.profileButton + 'explore'),
          failedToFetchFAQList);
    }
  }

  void fetchQuestions(ExploreScreen widget) {
    widget.questionsRepository
        .getFrequentlyAskedQuestions()
        .then((questionsList) {
      listOfQuestions = questionsList.list;
      setState(() {
        if (questionsList.noQuestionsAskedSoFar == true)
          status = ExploreStatus.NO_QUESTIONS_ASKED_SO_FAR;
        else
          status = ExploreStatus.FAQ_FETCHED;
      });
    }).catchError((error) {
      setState(() {
        status = ExploreStatus.ERROR_FETCHING_FAQ;
      });
    });
  }
}
