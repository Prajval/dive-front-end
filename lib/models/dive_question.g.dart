// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dive_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiveQuestionsResponse _$DiveQuestionsResponseFromJson(
    Map<String, dynamic> json) {
  return DiveQuestionsResponse(
    json['data'] == null
        ? null
        : DiveQuestionsList.fromJson(json['data'] as Map<String, dynamic>),
    json['message'] as String,
    json['status'] as int,
  );
}

Map<String, dynamic> _$DiveQuestionsResponseToJson(
        DiveQuestionsResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
      'status': instance.status,
    };

DiveAskQuestionResponse _$DiveAskQuestionResponseFromJson(
    Map<String, dynamic> json) {
  return DiveAskQuestionResponse(
    json['data'] == null
        ? null
        : DiveQuestion.fromJson(json['data'] as Map<String, dynamic>),
    json['message'] as String,
    json['status'] as int,
  );
}

Map<String, dynamic> _$DiveAskQuestionResponseToJson(
        DiveAskQuestionResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
      'status': instance.status,
    };

DiveQuestionsList _$DiveQuestionsListFromJson(Map<String, dynamic> json) {
  return DiveQuestionsList(
    (json['questionslist'] as List)
        ?.map((e) =>
            e == null ? null : DiveQuestion.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['no_questions_asked_so_far'] as bool,
  );
}

Map<String, dynamic> _$DiveQuestionsListToJson(DiveQuestionsList instance) =>
    <String, dynamic>{
      'questionslist': instance.questionsList,
      'no_questions_asked_so_far': instance.noQuestionsAskedSoFar,
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
