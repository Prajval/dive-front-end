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

  Future<QuestionsList> getQuestions({String page = '1'}) {
    getLogger().d(fetchingUserQuestions);
    Map<String, String> header = {'Content-Type': 'application/json'};
    Map<String, String> query = {'page': '$page'};

    return auth.getIdToken().then((idToken) {
      header['uid_token'] = idToken;
      return client.get(GET_QUESTIONS_FOR_USER,
          queryParameters: query, options: Options(headers: header));
    }).then((response) {
      if (response.statusCode == 200) {
        getLogger().d(fetchingUserQuestionsSuccess);
        return _composeQuestionsList(
            DiveQuestionsResponse.fromJson(response.data).data);
      } else {
        getLogger().e(fetchingUserQuestionsError);
        throw GenericError(
            'Error fetching user questions ' + response.statusCode.toString());
      }
    }).catchError((onError) {
      getLogger().e(onError);
      throw onError;
    });
  }

  Future<Question> getQuestionDetails({int qid, bool isGolden}) {
    getLogger().d(fetchingQuestionDetails);
    Map<String, String> header = {'Content-Type': 'application/json'};
    Map<String, dynamic> query = {'qid': qid, 'golden': isGolden};

    return auth.getIdToken().then((idToken) {
      header['uid_token'] = idToken;
      return client.get(GET_QUESTION_DETAILS,
          queryParameters: query, options: Options(headers: header));
    }).then((response) {
      if (response.statusCode == 200) {
        getLogger().d(fetchingQuestionDetailsSuccess);
        return _composeQuestion(
            DiveQuestionDetailsResponse.fromJson(response.data).data);
      } else {
        getLogger().e(fetchingQuestionDetailsError);
        throw GenericError('Error fetching question details ' +
            response.statusCode.toString());
      }
    }).catchError((onError) {
      getLogger().e(onError);
      throw onError;
    });
  }

  Future<Question> askQuestion(String question) {
    getLogger().d(askingANewQuestion);
    Map<String, String> header = {};
    Map<String, dynamic> body = {'question_text': question};

    return auth.getIdToken().then((idToken) {
      header['uid_token'] = idToken;
      return client.post(ASK_QUESTION,
          options: Options(headers: header), data: body);
    }).then((response) {
      if (response.statusCode == 200) {
        return _composeQuestion(
            DiveQuestionDetailsResponse.fromJson(response.data).data);
      } else {
        getLogger().e(askingNewQuestionError);
        throw GenericError(
            'Error asking new question ' + response.statusCode.toString());
      }
    }).catchError((onError) {
      getLogger().e(onError.toString());
      throw onError;
    });
  }

  QuestionsList _composeQuestionsList(DiveQuestionsList diveQuestionsList) {
    List<Question> questionTree = List<Question>();

    for (var diveQuestion in diveQuestionsList.questionsList) {
      questionTree.add(Question(
          qid: diveQuestion.qid,
          question: diveQuestion.question,
          answer: diveQuestion.answer,
          relatedQuestionAnswer: diveQuestion.getRelatedQuestion()));
    }
    return QuestionsList(
        noQuestionsAskedSoFar: diveQuestionsList.noQuestionsAskedSoFar,
        list: questionTree);
  }

  Question _composeQuestion(DiveQuestion diveQuestion) {
    return Question(
        qid: diveQuestion.qid,
        question: diveQuestion.question,
        answer: diveQuestion.answer,
        relatedQuestionAnswer: diveQuestion.getRelatedQuestion());
  }
}
