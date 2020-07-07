import 'package:dive/main.dart';
import 'package:dive/root_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should open RootPage when app is opened',
      (WidgetTester tester) async {
    await tester.pumpWidget(DiveApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(RootPage), findsOneWidget);
  });
}
