import 'dart:convert';

import 'package:dive/errors/generic_http_error.dart';
import 'package:dive/models/dive_question.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/urls.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

class QuestionsRepository {
  final Client client = GetIt.instance<Client>();

  Future<List<QuestionTree>> getQuestions() async {
    getLogger().d(fetchingUserQuestions);

    var response = await client.get(GET_QUESTIONS_FOR_USER);
    if (response.statusCode == 200) {
      return _composeQuestionsList(
          DiveQuestionsList.fromJson(json.decode(response.body)));
    } else {
      getLogger().e(fetchingUserQuestionsError);
      throw GenericError(
          'Error fetching questions' + response.statusCode.toString());
    }
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
