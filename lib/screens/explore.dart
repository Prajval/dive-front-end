import 'package:dive/base_state.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/utils/constants.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/strings.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  final QuestionsRepository questionsRepository;

  ExploreScreen({this.questionsRepository});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends BaseState<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    subscribeToLinksStream();
    getLogger().d(initializingExplore);
  }

  @override
  void dispose() {
    getLogger().d(disposingExplore);
    unsubscribeToLinksStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: ReusableWidgets.getAppBarWithAvatar(
          exploreAppBar, context, Key(Keys.profileButton)),
      body: Text(
        'Explore frequently asked questions here',
        style: TextStyle(
            color: blackTextColor,
            fontSize: 20,
            letterSpacing: 1,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
