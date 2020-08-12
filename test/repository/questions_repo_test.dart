import 'package:dio/dio.dart';
import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/urls.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

class MockAuth extends Mock implements Auth {}

String questionsList =
    '{ "questionslist" : [{"question": "How long will depression' +
        'last?", "answer": "answer", "relatedquestionanswer" : [' +
        '{"question": "When will depression end?", "answer": "3 months"}]}]}';

List<QuestionTree> questionTree = [
  QuestionTree(
      question: "How long will depression last?",
      answer: "answer",
      relatedQuestionAnswer: [
        RelatedQuestionAnswer(
            question: "When will depression end?", answer: "3 months")
      ])
];

void main() {
  setUpAll(() {
    GetIt.instance.allowReassignment = true;
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  group('questions repository', () {
    test('should return error if fetching token id fails', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockAuth auth = MockAuth();

      when(auth.getIdToken()).thenAnswer((_) => Future.error('error'));

      QuestionsRepository(auth).getQuestions().catchError((onError) {
        expect(onError.toString(), 'error');

        verify(auth.getIdToken()).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(auth);
      });
    });

    test('should return error if fetching questions fails', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockAuth auth = MockAuth();

      when(auth.getIdToken()).thenAnswer((_) => Future.value('id'));
      when(client.get(GET_QUESTIONS_FOR_USER,
              options: anyNamed("options"),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) => Future.error('error'));

      QuestionsRepository(auth).getQuestions().catchError((onError) {
        expect(onError.toString(), 'error');

        verify(client.get(GET_QUESTIONS_FOR_USER,
                options: anyNamed("options"),
                queryParameters: anyNamed('queryParameters')))
            .called(1);
        verify(auth.getIdToken()).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(auth);
      });
    });

    test('should return questions from backend', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockResponse mockResponse = MockResponse();
      MockAuth auth = MockAuth();

      when(auth.getIdToken()).thenAnswer((_) => Future.value('id'));
      when(client.get(GET_QUESTIONS_FOR_USER,
              options: anyNamed("options"),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) => Future.value(mockResponse));
      when(mockResponse.statusCode).thenReturn(200);
      when(mockResponse.data).thenReturn(questionsList);

      QuestionsRepository(auth).getQuestions().then((response) {
        expect(response, isInstanceOf<List<QuestionTree>>());
        expect(response.length, 1);

        verify(client.get(GET_QUESTIONS_FOR_USER,
                options: anyNamed("options"),
                queryParameters: anyNamed('queryParameters')))
            .called(1);
        verify(auth.getIdToken()).called(1);
        verify(mockResponse.statusCode).called(1);
        verify(mockResponse.data).called(1);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(mockResponse);
      });
    });

    test('should return error when backend call is not success', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Dio>(client);
      MockResponse mockResponse = MockResponse();
      MockAuth auth = MockAuth();

      when(auth.getIdToken()).thenAnswer((_) => Future.value('id'));
      when(client.get(GET_QUESTIONS_FOR_USER,
              options: anyNamed("options"),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) => Future.value(mockResponse));
      when(mockResponse.statusCode).thenReturn(401);

      QuestionsRepository(auth).getQuestions().catchError((onError) {
        expect(onError.toString(), 'Error fetching questions 401');

        verify(client.get(GET_QUESTIONS_FOR_USER,
                options: anyNamed("options"),
                queryParameters: anyNamed('queryParameters')))
            .called(1);
        verify(auth.getIdToken()).called(1);
        verify(mockResponse.statusCode).called(2);
        verifyNoMoreInteractions(client);
        verifyNoMoreInteractions(auth);
        verifyNoMoreInteractions(mockResponse);
      });
    });
  });
}
