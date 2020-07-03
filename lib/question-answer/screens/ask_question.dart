import 'package:flutter/material.dart';
import 'package:dive/question-answer/utils/constants.dart';


class AskQuestionScreen extends StatefulWidget {


  @override
  _AskQuestionScreenState createState() => _AskQuestionScreenState();
}


class _AskQuestionScreenState extends State<AskQuestionScreen> {


  final inputQuestionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //inputQuestionController.addListener(printLatestValue(inputQuestionController.text));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    inputQuestionController.dispose();
    super.dispose();
  }

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

        body: Padding(
            padding: EdgeInsets.only(right: 48.0, top: 15.0),
            child: Container(
                margin: const EdgeInsets.all(3.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: appBarColor, borderRadius: radiusBubble),
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: TextField(
                      controller: inputQuestionController,
                      decoration: InputDecoration.collapsed(hintText: typeQuestionHere, hintStyle: TextStyle(color: hintColor)),
                      style: TextStyle(color: whiteTextColor),
                      //TODO: Call backend when submitted to get answer
                      onSubmitted: null,
                      maxLines: null,
                      keyboardType: TextInputType.text,
                      cursorColor: whiteTextColor
                    )
                )
            )
        )
    );
  }
}