import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:dive/utils/urls.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements Client {}

class MockResponse extends Mock implements Response {}

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
    test('should return error if fetching questions fails', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Client>(client);
      MockResponse mockResponse = MockResponse();

      when(client.get(GET_QUESTIONS_FOR_USER))
          .thenAnswer((_) async => mockResponse);

      expectLater(QuestionsRepository().getQuestions(), throwsException);

      verify(client.get(GET_QUESTIONS_FOR_USER)).called(1);
      verifyNoMoreInteractions(client);
      verifyNoMoreInteractions(mockResponse);
    });

    test('should return questions from backend', () async {
      MockClient client = MockClient();
      GetIt.instance.registerSingleton<Client>(client);
      MockResponse mockResponse = MockResponse();

      when(client.get(GET_QUESTIONS_FOR_USER))
          .thenAnswer((_) async => mockResponse);
      when(mockResponse.body).thenReturn(questionsList);
      when(mockResponse.statusCode).thenReturn(200);

      expectLater(await QuestionsRepository().getQuestions(),
          isInstanceOf<List<QuestionTree>>());

      verify(client.get(GET_QUESTIONS_FOR_USER)).called(1);
      verify(mockResponse.body).called(1);
      verify(mockResponse.statusCode).called(1);
      verifyNoMoreInteractions(client);
      verifyNoMoreInteractions(mockResponse);
    });
  });
}
