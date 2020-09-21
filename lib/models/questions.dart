import 'package:json_annotation/json_annotation.dart';

part 'questions.g.dart';

@JsonSerializable()
class QuestionsList {
  final List<Question> list;
  final bool noQuestionsAskedSoFar;

  QuestionsList({this.list, this.noQuestionsAskedSoFar});

  factory QuestionsList.fromJson(Map<String, dynamic> json) =>
      _$QuestionsListFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionsListToJson(this);
}

@JsonSerializable()
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

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}

@JsonSerializable()
class RelatedQuestionAnswer {
  final int qid;
  final String question;
  final String answer;

  RelatedQuestionAnswer({this.qid, this.question, this.answer});

  factory RelatedQuestionAnswer.fromJson(Map<String, dynamic> json) =>
      _$RelatedQuestionAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$RelatedQuestionAnswerToJson(this);
}
