// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionsList _$QuestionsListFromJson(Map<String, dynamic> json) {
  return QuestionsList(
    list: (json['list'] as List)
        ?.map((e) =>
            e == null ? null : Question.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    noQuestionsAskedSoFar: json['noQuestionsAskedSoFar'] as bool,
  );
}

Map<String, dynamic> _$QuestionsListToJson(QuestionsList instance) =>
    <String, dynamic>{
      'list': instance.list,
      'noQuestionsAskedSoFar': instance.noQuestionsAskedSoFar,
    };

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return Question(
    qid: json['qid'] as int,
    question: json['question'] as String,
    answer: json['answer'] as String,
    relatedQuestionAnswer: (json['relatedQuestionAnswer'] as List)
        ?.map((e) => e == null
            ? null
            : RelatedQuestionAnswer.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    time: json['time'] as String,
  );
}

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'qid': instance.qid,
      'question': instance.question,
      'answer': instance.answer,
      'relatedQuestionAnswer': instance.relatedQuestionAnswer,
      'time': instance.time,
    };

RelatedQuestionAnswer _$RelatedQuestionAnswerFromJson(
    Map<String, dynamic> json) {
  return RelatedQuestionAnswer(
    qid: json['qid'] as int,
    question: json['question'] as String,
    answer: json['answer'] as String,
  );
}

Map<String, dynamic> _$RelatedQuestionAnswerToJson(
        RelatedQuestionAnswer instance) =>
    <String, dynamic>{
      'qid': instance.qid,
      'question': instance.question,
      'answer': instance.answer,
    };
