import 'package:dive/models/questions.dart';
import 'package:dive/repository/questions_repo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('questions repository', () {
    test('should fetch question tree', () async {
      expect(QuestionsRepository().getQuestionTree(),
          isInstanceOf<List<QuestionTree>>());
    });
  });
}
