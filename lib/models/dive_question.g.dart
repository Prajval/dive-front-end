// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dive_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiveQuestionsList _$DiveQuestionsListFromJson(Map<String, dynamic> json) {
  return DiveQuestionsList(
    (json['questionslist'] as List)
        ?.map((e) =>
            e == null ? null : DiveQuestion.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$DiveQuestionsListToJson(DiveQuestionsList instance) =>
    <String, dynamic>{
      'questionslist': instance.questionsList,
    };

DiveQuestion _$DiveQuestionFromJson(Map<String, dynamic> json) {
  return DiveQuestion(
    json['question'] as String,
    json['answer'] as String,
    (json['relatedquestionanswer'] as List)
        ?.map((e) => e == null
            ? null
            : GoldenQuestion.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$DiveQuestionToJson(DiveQuestion instance) =>
    <String, dynamic>{
      'question': instance.question,
      'answer': instance.answer,
      'relatedquestionanswer': instance.goldenQuestions,
    };

GoldenQuestion _$GoldenQuestionFromJson(Map<String, dynamic> json) {
  return GoldenQuestion(
    json['question'] as String,
    json['answer'] as String,
  );
}

Map<String, dynamic> _$GoldenQuestionToJson(GoldenQuestion instance) =>
    <String, dynamic>{
      'question': instance.question,
      'answer': instance.answer,
    };
