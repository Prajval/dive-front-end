import 'package:dive/auth.dart';
import 'package:dive/root_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Dive',
    home: DiveApp(),
  ));
}

class DiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      home: new RootPage(auth: new Auth(FirebaseAuth.instance)),
    );
  }
}

//List<RelatedQuestionAnswer> _relatedQuestionsAnswersList = [
//  RelatedQuestionAnswer(question: "How can depression be treated?", answer: "It can be treated in a variety of ways."),
//  RelatedQuestionAnswer(question: "How do we know who is a good doctor?", answer: "Ah! Thats a tough question."),
//  RelatedQuestionAnswer(question: "How long does depression last?", answer: "It varies in each individual and to various degrees.")
//];
//List<QuestionTree> _questionTree = [
//  QuestionTree(question: "Can depression be treated?", answer: "Yes, it can be treated!", time: "5d ago"),
//  QuestionTree(question: "How long does depression last?", relatedQuestionAnswer: _relatedQuestionsAnswersList, time: "4d ago"),
//  QuestionTree(question: "Let me now ask a really really long question. Well. I don't know. I know. "
//      "I mean I know but don't know how to ask. But here is the thing that i really want to ask."
//      "How do we know who is a good doctor?", answer: "How about googling the same for now.", time: "55 mins ago"),
//  QuestionTree(question: "Is depression genetic?", relatedQuestionAnswer: _relatedQuestionsAnswersList, time: "33 mins ago")
//];
//return ChatListScreen(listOfQuestions: _questionTree);
