import 'package:dio/dio.dart';
import 'package:dive/errors/generic_http_error.dart';
import 'package:dive/models/dive_question.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/repository/local_storage/cache_keys.dart';
import 'package:dive/repository/local_storage/cache_repo.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/utils/logger.dart';
import 'package:dive/utils/urls.dart';
import 'package:get_it/get_it.dart';

class QuestionsRepository {
  final UserRepository userRepository;
  final Dio client = GetIt.instance<Dio>();
  final CacheRepo cacheRepo = GetIt.instance<CacheRepo>();

  QuestionsRepository(this.userRepository);

  Future<QuestionsList> getUserQuestions({String page = '1'}) {
    getLogger().d(fetchingUserQuestions);

    var cachedQuestionsList = cacheRepo.getData(CacheKeys.userQuestions);

    if (cachedQuestionsList != null) {
      getLogger().i(cachedQuestionsFound);
      return Future.value(QuestionsList.fromJson(cachedQuestionsList));
    } else {
      Map<String, String> header = {'Content-Type': 'application/json'};
      Map<String, String> query = {'page': '$page'};

      return userRepository.getAuthToken().then((idToken) {
        header['uid_token'] = idToken;
        return client.get(GET_QUESTIONS_FOR_USER,
            queryParameters: query, options: Options(headers: header));
      }).then((response) {
        if (response.statusCode == 200) {
          getLogger().d(fetchingUserQuestionsSuccess);
          QuestionsList questionsList = _composeQuestionsList(
              DiveQuestionsResponse.fromJson(response.data).data);
          cacheRepo.putData(
              key: CacheKeys.userQuestions,
              data: questionsList,
              expiryInHours: CacheKeys.userQuestionsExpiryInHours,
              shouldEraseOnSignout: true);
          return questionsList;
        } else {
          getLogger().e(fetchingUserQuestionsError);
          throw GenericError('Error fetching user questions ' +
              response.statusCode.toString());
        }
      }).catchError((onError) {
        getLogger().e(onError);
        throw onError;
      });
    }
  }

  Future<QuestionsList> getFrequentlyAskedQuestions({String page = '1'}) {
    getLogger().d(fetchingFrequentlyAskedQuestions);

    var cachedQuestionsList =
        cacheRepo.getData(CacheKeys.frequentlyAskedQuestions);

    if (cachedQuestionsList != null) {
      getLogger().i(cachedFrequentlyAskedFound);
      return Future.value(QuestionsList.fromJson(cachedQuestionsList));
    } else {
      Map<String, String> header = {'Content-Type': 'application/json'};
      Map<String, String> query = {'page': '$page'};

      return userRepository.getAuthToken().then((idToken) {
        header['uid_token'] = idToken;
        return client.get(GET_FREQUENTLY_ASKED_QUESTIONS,
            queryParameters: query, options: Options(headers: header));
      }).then((response) {
        if (response.statusCode == 200) {
          getLogger().d(fetchingFrequentlyAskedQuestionsSuccess);
          QuestionsList questionsList = _composeQuestionsList(
              DiveQuestionsResponse.fromJson(response.data).data);
          cacheRepo.putData(
              key: CacheKeys.frequentlyAskedQuestions,
              data: questionsList,
              expiryInHours: CacheKeys.frequentlyAskedQuestionsExpiryInHours);
          return questionsList;
        } else {
          getLogger().e(fetchingFrequentlyAskedQuestionsError);
          throw GenericError('Error fetching frequently asked questions ' +
              response.statusCode.toString());
        }
      }).catchError((onError) {
        getLogger().e(onError);
        throw onError;
      });
    }
  }

  Future<Question> getQuestionDetails({int qid, bool isGolden}) {
    getLogger().d(fetchingQuestionDetails);

    var cachedQuestionDetails =
        cacheRepo.getData(getCacheKeyForQuestionDetails(qid, isGolden));

    if (cachedQuestionDetails != null) {
      getLogger().i(cachedAnswerFound);
      return Future.value(Question.fromJson(cachedQuestionDetails));
    } else {
      Map<String, String> header = {'Content-Type': 'application/json'};
      Map<String, dynamic> query = {'qid': qid, 'is_golden': isGolden};

      return userRepository.getAuthToken().then((idToken) {
        header['uid_token'] = idToken;
        return client.get(GET_QUESTION_DETAILS,
            queryParameters: query, options: Options(headers: header));
      }).then((response) {
        if (response.statusCode == 200) {
          getLogger().d(fetchingQuestionDetailsSuccess);
          Question question = _composeQuestion(
              DiveQuestionDetailsResponse.fromJson(response.data).data);

          cacheRepo.putData(
              key: getCacheKeyForQuestionDetails(qid, isGolden),
              data: question);

          return question;
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
  }

  String getCacheKeyForQuestionDetails(int qid, bool isGolden) {
    return (CacheKeys.questionDetails + ", qid=$qid, isGolden=$isGolden");
  }

  Future<Question> askQuestion(String question) {
    getLogger().d(askingANewQuestion);
    Map<String, String> header = {};
    Map<String, dynamic> body = {'question_text': question};

    return userRepository.getAuthToken().then((idToken) {
      cacheRepo.delete(CacheKeys.userQuestions);

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
