import 'dart:convert';

import 'package:dive/errors/generic_http_error.dart';
import 'package:dive/models/dive_question.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/urls.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

class QuestionsRepository {
  final Auth auth;
  final Client client = GetIt.instance<Client>();
  QuestionsRepository(this.auth);

  Future<List<QuestionTree>> getQuestions({String page = '1'}) {
    getLogger().d(fetchingUserQuestions);
    Map<String, String> header = {'Content-Type': 'application/json'};
    var uri = Uri.parse(GET_QUESTIONS_FOR_USER).replace(query: 'page=$page');

    return auth.getIdToken().then((idToken) {
      header['uid_token'] = idToken;
      return client.get(uri, headers: header);
    }).then((response) {
      if (response.statusCode == 200) {
        return _composeQuestionsList(
            DiveQuestionsList.fromJson(json.decode(response.body)));
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
