import 'package:dio/dio.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/repository/user_repo.dart';
import 'package:dive/utils/urls.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

class MockUserRepository extends Mock implements UserRepository {}

Map<String, dynamic> questionsList = {
  "data": {
    "questionslist": [
      {
        "question": "How long will depressionlast?",
        "answer": "answer",
        "relatedquestionanswer": [
          {"question": "When will depression end?", "answer": "3 months"}
        ]
      }
    ],
    "no_questions_asked_so_far": true
  },
  "message": "success",
  "status": 200
};

Map<String, dynamic> noQuestionsAskedList = {
  "data": {"no_questions_asked_so_far": true, "questionslist": []},
  "message": "success",
  "status": 200
};

Map<String, dynamic> newQuestion = {
  "data": {
    "qid": 4,
    "question": "How long will depression last?",
    "answer": "answer",
    "relatedquestionanswer": [
      {"question": "When will depression end?", "answer": "3 months"}
    ]
  },
  "message": "success",
  "status": 200
};

void main() {
  setUpAll(() {
    GetIt.instance.allowReassignment = true;
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  group('get questions', () {
    test('should return error if fetching token id fails', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockUserRepository userRepository = MockUserRepository();

      when(userRepository.getAuthToken())
          .thenAnswer((_) => Future.error('error'));

      QuestionsRepository(userRepository)
          .getUserQuestions()
          .catchError((onError) {
        expect(onError.toString(), 'error');

        verify(userRepository.getAuthToken()).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
      });
    });

    test('should return error if fetching questions fails', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockUserRepository userRepository = MockUserRepository();

      when(userRepository.getAuthToken()).thenAnswer((_) => Future.value('id'));
      when(client.get(GET_QUESTIONS_FOR_USER,
              options: anyNamed("options"),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) => Future.error('error'));

      QuestionsRepository(userRepository)
          .getUserQuestions()
          .catchError((onError) {
        expect(onError.toString(), 'error');

        verify(client.get(GET_QUESTIONS_FOR_USER,
                options: anyNamed("options"),
                queryParameters: anyNamed('queryParameters')))
            .called(1);
        verify(userRepository.getAuthToken()).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
      });
    });

    test('should return questions from backend', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockResponse mockResponse = MockResponse();
      MockUserRepository userRepository = MockUserRepository();

      when(userRepository.getAuthToken()).thenAnswer((_) => Future.value('id'));
      when(client.get(GET_QUESTIONS_FOR_USER,
              options: anyNamed("options"),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) => Future.value(mockResponse));
      when(mockResponse.statusCode).thenReturn(200);
      when(mockResponse.data).thenReturn(questionsList);

      QuestionsRepository(userRepository).getUserQuestions().then((response) {
        expect(response.list, isInstanceOf<List<Question>>());
        expect(response.list.length, 1);

        verify(client.get(GET_QUESTIONS_FOR_USER,
                options: anyNamed("options"),
                queryParameters: anyNamed('queryParameters')))
            .called(1);
        verify(userRepository.getAuthToken()).called(1);
        verify(mockResponse.statusCode).called(1);
        verify(mockResponse.data).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
        verifyNoMoreInteractions(mockResponse);
      });
    });

    test('should return no questions asked true from backend', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockResponse mockResponse = MockResponse();
      MockUserRepository userRepository = MockUserRepository();

      when(userRepository.getAuthToken()).thenAnswer((_) => Future.value('id'));
      when(client.get(GET_QUESTIONS_FOR_USER,
              options: anyNamed("options"),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) => Future.value(mockResponse));
      when(mockResponse.statusCode).thenReturn(200);
      when(mockResponse.data).thenReturn(noQuestionsAskedList);

      QuestionsRepository(userRepository).getUserQuestions().then((response) {
        expect(response.list, isInstanceOf<List<Question>>());
        expect(response.list.length, 0);
        expect(response.noQuestionsAskedSoFar, true);

        verify(client.get(GET_QUESTIONS_FOR_USER,
                options: anyNamed("options"),
                queryParameters: anyNamed('queryParameters')))
            .called(1);
        verify(userRepository.getAuthToken()).called(1);
        verify(mockResponse.statusCode).called(1);
        verify(mockResponse.data).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
        verifyNoMoreInteractions(mockResponse);
      });
    });

    test('should return error when backend call is not success', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockResponse mockResponse = MockResponse();
      MockUserRepository userRepository = MockUserRepository();

      when(userRepository.getAuthToken()).thenAnswer((_) => Future.value('id'));
      when(client.get(GET_QUESTIONS_FOR_USER,
              options: anyNamed("options"),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) => Future.value(mockResponse));
      when(mockResponse.statusCode).thenReturn(401);

      QuestionsRepository(userRepository)
          .getUserQuestions()
          .catchError((onError) {
        expect(onError.toString(), 'Error fetching user questions 401');

        verify(client.get(GET_QUESTIONS_FOR_USER,
                options: anyNamed("options"),
                queryParameters: anyNamed('queryParameters')))
            .called(1);
        verify(userRepository.getAuthToken()).called(1);
        verify(mockResponse.statusCode).called(2);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
        verifyNoMoreInteractions(mockResponse);
      });
    });
  });

  group('ask a new question', () {
    test('should return error if fetching token id fails', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockUserRepository userRepository = MockUserRepository();
      String question = "How long will depression last?";

      when(userRepository.getAuthToken())
          .thenAnswer((_) => Future.error('error'));

      QuestionsRepository(userRepository)
          .askQuestion(question)
          .catchError((onError) {
        expect(onError.toString(), 'error');

        verify(userRepository.getAuthToken()).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
      });
    });

    test('should return error if asking new question fails', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockUserRepository userRepository = MockUserRepository();
      String question = "How long will depression last?";
      Map<String, dynamic> body = {'question_text': question};

      when(userRepository.getAuthToken()).thenAnswer((_) => Future.value('id'));
      when(client.post(ASK_QUESTION, options: anyNamed("options"), data: body))
          .thenAnswer((_) => Future.error('error'));

      QuestionsRepository(userRepository)
          .askQuestion(question)
          .catchError((onError) {
        expect(onError.toString(), 'error');

        verify(client.post(ASK_QUESTION,
                options: anyNamed("options"), data: body))
            .called(1);
        verify(userRepository.getAuthToken()).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
      });
    });

    test('should return new question with answer from backend', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockResponse mockResponse = MockResponse();
      MockUserRepository userRepository = MockUserRepository();
      String question = "How long will depression last?";
      Map<String, dynamic> body = {'question_text': question};

      when(userRepository.getAuthToken()).thenAnswer((_) => Future.value('id'));
      when(client.post(ASK_QUESTION, options: anyNamed("options"), data: body))
          .thenAnswer((_) => Future.value(mockResponse));
      when(mockResponse.statusCode).thenReturn(200);
      when(mockResponse.data).thenReturn(newQuestion);

      QuestionsRepository(userRepository)
          .askQuestion(question)
          .then((response) {
        expect(response, isInstanceOf<Question>());
        expect(response.question, question);

        verify(client.post(ASK_QUESTION,
                options: anyNamed("options"), data: body))
            .called(1);
        verify(userRepository.getAuthToken()).called(1);
        verify(mockResponse.statusCode).called(1);
        verify(mockResponse.data).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
        verifyNoMoreInteractions(mockResponse);
      });
    });

    test('should return error when backend call is not success', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockResponse mockResponse = MockResponse();
      MockUserRepository userRepository = MockUserRepository();
      String question = "How long will depression last?";
      Map<String, dynamic> body = {'question_text': question};

      when(userRepository.getAuthToken()).thenAnswer((_) => Future.value('id'));
      when(client.post(ASK_QUESTION, options: anyNamed("options"), data: body))
          .thenAnswer((_) => Future.value(mockResponse));
      when(mockResponse.statusCode).thenReturn(401);

      QuestionsRepository(userRepository)
          .askQuestion(question)
          .catchError((onError) {
        expect(onError.toString(), 'Error asking new question 401');

        verify(client.post(ASK_QUESTION,
                options: anyNamed("options"), data: body))
            .called(1);
        verify(userRepository.getAuthToken()).called(1);
        verify(mockResponse.statusCode).called(2);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
        verifyNoMoreInteractions(mockResponse);
      });
    });
  });

  group('get question details', () {
    test('should return error if fetching token id fails', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockUserRepository userRepository = MockUserRepository();
      int qid = 1;
      bool isGolden = false;

      when(userRepository.getAuthToken())
          .thenAnswer((_) => Future.error('error'));

      QuestionsRepository(userRepository)
          .getQuestionDetails(qid: qid, isGolden: isGolden)
          .catchError((onError) {
        expect(onError.toString(), 'error');

        verify(userRepository.getAuthToken()).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
      });
    });

    test('should return error if fetching question details', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockUserRepository userRepository = MockUserRepository();
      int qid = 1;
      bool isGolden = false;

      when(userRepository.getAuthToken()).thenAnswer((_) => Future.value('id'));
      when(client.get(GET_QUESTION_DETAILS,
              options: anyNamed("options"),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) => Future.error('error'));

      QuestionsRepository(userRepository)
          .getQuestionDetails(qid: qid, isGolden: isGolden)
          .catchError((onError) {
        expect(onError.toString(), 'error');

        verify(client.get(GET_QUESTION_DETAILS,
                options: anyNamed("options"),
                queryParameters: anyNamed('queryParameters')))
            .called(1);
        verify(userRepository.getAuthToken()).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
      });
    });

    test('should return new question with answer from backend', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockResponse mockResponse = MockResponse();
      MockUserRepository userRepository = MockUserRepository();
      int qid = 4;
      bool isGolden = false;

      when(userRepository.getAuthToken()).thenAnswer((_) => Future.value('id'));
      when(client.get(GET_QUESTION_DETAILS,
              options: anyNamed("options"),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) => Future.value(mockResponse));
      when(mockResponse.statusCode).thenReturn(200);
      when(mockResponse.data).thenReturn(newQuestion);

      QuestionsRepository(userRepository)
          .getQuestionDetails(qid: qid, isGolden: isGolden)
          .then((response) {
        expect(response, isInstanceOf<Question>());
        expect(response.qid, qid);

        verify(client.get(GET_QUESTION_DETAILS,
                options: anyNamed("options"),
                queryParameters: anyNamed('queryParameters')))
            .called(1);
        verify(userRepository.getAuthToken()).called(1);
        verify(mockResponse.statusCode).called(1);
        verify(mockResponse.data).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
        verifyNoMoreInteractions(mockResponse);
      });
    });

    test('should return error when backend call is fails', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockResponse mockResponse = MockResponse();
      MockUserRepository userRepository = MockUserRepository();
      int qid = 4;
      bool isGolden = false;

      when(userRepository.getAuthToken()).thenAnswer((_) => Future.value('id'));
      when(client.get(GET_QUESTION_DETAILS,
              options: anyNamed("options"),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) => Future.value(mockResponse));
      when(mockResponse.statusCode).thenReturn(401);

      QuestionsRepository(userRepository)
          .getQuestionDetails(qid: qid, isGolden: isGolden)
          .catchError((error) {
        expect(error.toString(), 'Error fetching question details 401');

        verify(client.get(GET_QUESTION_DETAILS,
                options: anyNamed("options"),
                queryParameters: anyNamed('queryParameters')))
            .called(1);
        verify(userRepository.getAuthToken()).called(1);
        verify(mockResponse.statusCode).called(2);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(userRepository);
        verifyNoMoreInteractions(mockResponse);
      });
    });
  });
}
