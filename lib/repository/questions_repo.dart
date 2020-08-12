import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dive/errors/generic_http_error.dart';
import 'package:dive/models/dive_question.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/urls.dart';
import 'package:get_it/get_it.dart';

class QuestionsRepository {
  final Auth auth;
  final Dio client = GetIt.instance<Dio>();

  QuestionsRepository(this.auth);

  Future<List<QuestionTree>> getQuestions({String page = '1'}) {
    getLogger().d(fetchingUserQuestions);
    Map<String, String> header = {'Content-Type': 'application/json'};
    Map<String, String> query = {'page': '$page'};

    return auth.getIdToken().then((idToken) {
      header['uid_token'] = idToken;
      return client.get(GET_QUESTIONS_FOR_USER,
          queryParameters: query, options: Options(headers: header));
    }).then((response) {
      if (response.statusCode == 200) {
        return _composeQuestionsList(
            DiveQuestionsList.fromJson(json.decode(response.data)));
      } else {
        getLogger().e(fetchingUserQuestionsError);
        throw GenericError(
            'Error fetching questions ' + response.statusCode.toString());
      }
    }).catchError((onError) {
      throw onError;
    });
  }

  List<QuestionTree> _composeQuestionsList(
      DiveQuestionsList diveQuestionsList) {
    List<QuestionTree> questionTree = List<QuestionTree>();
    for (var diveQuestion in diveQuestionsList.questionsList) {
      questionTree.add(QuestionTree(
          question: diveQuestion.question,
          answer: diveQuestion.answer,
          relatedQuestionAnswer: diveQuestion.getRelatedQuestion()));
    }

    return questionTree;
  }
}
