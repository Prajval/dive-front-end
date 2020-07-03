import 'package:flutter/material.dart';

// Colors
final Color appBarColor = Color(0xFF0BBFD6);
final Color answerBubbleColor = Colors.grey[200];
final Color backgroundColor = Colors.grey[50];
final Color hintColor = Colors.grey[350];
final Color whiteTextColor = Colors.white;
final Color blackTextColor = Colors.black87;
final Color exclamationMessageColor = Colors.grey[700];

final radiusBubble = BorderRadius.only(
  topLeft: Radius.circular(10.0),
  topRight: Radius.circular(10.0),
  bottomLeft: Radius.circular(10.0),
  bottomRight: Radius.circular(10.0),
);

// Default messages
final String questions = "Questions";
final String typeQuestionHere = "Type a question";
final String questionUnavailableMessage = "Sorry, we don't have that question. Here are some related questions we found.";
final String tapHereIfUnsatisfiedMessage = "Tap here if this doesn't answer your question. We will get back to you with an answer shortly.";