import 'package:dive/main.dart';
import 'package:dive/root.dart';
import 'package:dive/utils/auth.dart';
import 'package:dive/utils/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

void main() {
  setUpAll(() {
    setUpDependencies();
    GetIt.instance.allowReassignment = true;
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  testWidgets('should open Root screen when app is opened',
      (WidgetTester tester) async {
    MockAuth auth = MockAuth();
    GetIt.instance.registerSingleton<BaseAuth>(auth);

    when(auth.getCurrentUser()).thenAnswer((_) async => null);

    await tester.pumpWidget(DiveApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Root), findsOneWidget);

    verify(auth.getCurrentUser()).called(1);
    verifyNoMoreInteractions(auth);
  });
}
