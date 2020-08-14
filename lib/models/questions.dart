class QuestionsList {
  final List<Question> list;
  final bool noQuestionsAskedSoFar;

  QuestionsList({this.list, this.noQuestionsAskedSoFar});
}

class Question {
  final String question;
  final String answer;
  final List<RelatedQuestionAnswer> relatedQuestionAnswer;
  final String time;

  Question({this.question, this.answer, this.relatedQuestionAnswer, this.time});
}

class RelatedQuestionAnswer {
  final String question;
  final String answer;

  RelatedQuestionAnswer({this.question, this.answer});
}
