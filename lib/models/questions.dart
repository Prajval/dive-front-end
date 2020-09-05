class QuestionsList {
  final List<Question> list;
  final bool noQuestionsAskedSoFar;

  QuestionsList({this.list, this.noQuestionsAskedSoFar});
}

class Question {
  final int qid;
  final String question;
  final String answer;
  final List<RelatedQuestionAnswer> relatedQuestionAnswer;
  final String time;

  Question(
      {this.qid,
      this.question,
      this.answer,
      this.relatedQuestionAnswer,
      this.time});
}

class RelatedQuestionAnswer {
  final int qid;
  final String question;
  final String answer;

  RelatedQuestionAnswer({this.qid, this.question, this.answer});
}
