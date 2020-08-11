import 'package:dive/models/questions.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dive_question.g.dart';

@JsonSerializable()
class DiveQuestionsList {
  @JsonKey(name: 'questionslist')
  final List<DiveQuestion> questionsList;

  DiveQuestionsList(this.questionsList);

  factory DiveQuestionsList.fromJson(Map<String, dynamic> json) =>
      _$DiveQuestionsListFromJson(json);

  Map<String, dynamic> toJson() => _$DiveQuestionsListToJson(this);
}

@JsonSerializable()
class DiveQuestion {
  @JsonKey(name: 'question')
  final String question;

  @JsonKey(name: 'answer')
  final String answer;

  @JsonKey(name: 'relatedquestionanswer')
  final List<GoldenQuestion> goldenQuestions;

  DiveQuestion(this.question, this.answer, this.goldenQuestions);

  factory DiveQuestion.fromJson(Map<String, dynamic> json) =>
      _$DiveQuestionFromJson(json);

  List<RelatedQuestionAnswer> getRelatedQuestion() {
    List<RelatedQuestionAnswer> relatedQuestions =
        List<RelatedQuestionAnswer>();

    for (var goldenQuestion in goldenQuestions) {
      RelatedQuestionAnswer newRelatedQuestionAnswer = RelatedQuestionAnswer(
          question: goldenQuestion.question, answer: goldenQuestion.answer);

      relatedQuestions.add(newRelatedQuestionAnswer);
    }

    return relatedQuestions;
  }

  Map<String, dynamic> toJson() => _$DiveQuestionToJson(this);
}

@JsonSerializable()
class GoldenQuestion {
  @JsonKey(name: 'question')
  final String question;

  @JsonKey(name: 'answer')
  final String answer;

  GoldenQuestion(this.question, this.answer);

  factory GoldenQuestion.fromJson(Map<String, dynamic> json) =>
      _$GoldenQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$GoldenQuestionToJson(this);
}
