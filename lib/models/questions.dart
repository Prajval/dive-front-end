class QuestionTree {
  final String question;
  final String answer;
  final List<RelatedQuestionAnswer> relatedQuestionAnswer;
  final String time;

  QuestionTree(
      {this.question, this.answer, this.relatedQuestionAnswer, this.time});
}

class RelatedQuestionAnswer {
  final String question;
  final String answer;

  RelatedQuestionAnswer({this.question, this.answer});
}
