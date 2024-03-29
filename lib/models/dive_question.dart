import 'package:dive/models/questions.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dive_question.g.dart';

@JsonSerializable()
class DiveQuestionsResponse {
  @JsonKey(name: 'data')
  final DiveQuestionsList data;

  @JsonKey(name: 'message')
  final String message;

  DiveQuestionsResponse(this.data, this.message);

  factory DiveQuestionsResponse.fromJson(Map<String, dynamic> json) =>
      _$DiveQuestionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DiveQuestionsResponseToJson(this);
}

@JsonSerializable()
class DiveQuestionDetailsResponse {
  @JsonKey(name: 'data')
  final DiveQuestion data;

  @JsonKey(name: 'message')
  final String message;

  DiveQuestionDetailsResponse(this.data, this.message);

  factory DiveQuestionDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$DiveQuestionDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DiveQuestionDetailsResponseToJson(this);
}

@JsonSerializable()
class DiveQuestionsList {
  @JsonKey(name: 'questionslist')
  final List<DiveQuestion> questionsList;

  @JsonKey(name: 'no_questions_asked_so_far')
  final bool noQuestionsAskedSoFar;

  DiveQuestionsList(this.questionsList, this.noQuestionsAskedSoFar);

  factory DiveQuestionsList.fromJson(Map<String, dynamic> json) =>
      _$DiveQuestionsListFromJson(json);

  Map<String, dynamic> toJson() => _$DiveQuestionsListToJson(this);
}

@JsonSerializable()
class DiveQuestion {
  @JsonKey(name: 'qid')
  final int qid;

  @JsonKey(name: 'question')
  final String question;

  @JsonKey(name: 'answer')
  final String answer;

  @JsonKey(name: 'relatedquestionanswer')
  final List<GoldenQuestion> goldenQuestions;

  DiveQuestion(this.question, this.answer, this.goldenQuestions, this.qid);

  factory DiveQuestion.fromJson(Map<String, dynamic> json) =>
      _$DiveQuestionFromJson(json);

  List<RelatedQuestionAnswer> getRelatedQuestion() {
    List<RelatedQuestionAnswer> relatedQuestions =
        List<RelatedQuestionAnswer>();

    for (var goldenQuestion in goldenQuestions) {
      RelatedQuestionAnswer newRelatedQuestionAnswer = RelatedQuestionAnswer(
          qid: goldenQuestion.qid,
          question: goldenQuestion.question,
          answer: goldenQuestion.answer);

      relatedQuestions.add(newRelatedQuestionAnswer);
    }

    return relatedQuestions;
  }

  Map<String, dynamic> toJson() => _$DiveQuestionToJson(this);
}

@JsonSerializable()
class GoldenQuestion {
  @JsonKey(name: 'qid')
  final int qid;

  @JsonKey(name: 'question')
  final String question;

  @JsonKey(name: 'answer')
  final String answer;

  GoldenQuestion(this.question, this.answer, this.qid);

  factory GoldenQuestion.fromJson(Map<String, dynamic> json) =>
      _$GoldenQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$GoldenQuestionToJson(this);
}
