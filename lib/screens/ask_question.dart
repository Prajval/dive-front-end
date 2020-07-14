import 'package:dive/utils/constants.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/material.dart';

class AskQuestionScreen extends StatefulWidget {
  @override
  _AskQuestionScreenState createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final inputQuestionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getLogger().d(initializingAskQuestion);
  }

  @override
  void dispose() {
    getLogger().d(disposingAskQuestion);
    inputQuestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: ReusableWidgets.getAppBar(newQuestionAppBar, context),
        body: Padding(
            padding: EdgeInsets.only(right: 48.0, top: 15.0),
            child: Container(
                margin: const EdgeInsets.all(3.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    color: appPrimaryColor, borderRadius: radiusBubble),
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: TextField(
                        controller: inputQuestionController,
                        decoration: InputDecoration.collapsed(
                            hintText: typeQuestionHere,
                            hintStyle: TextStyle(color: hintColor)),
                        style: TextStyle(color: whiteTextColor),
                        onSubmitted: null,
                        maxLines: null,
                        keyboardType: TextInputType.text,
                        cursorColor: whiteTextColor)))));
  }
}
