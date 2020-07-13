import 'package:dive/utils/auth.dart';
import 'package:dive/utils/keys.dart';
import 'package:dive/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuth extends Mock implements Auth {}

void main() {
  testWidgets('should build standard app bar', (WidgetTester tester) async {
    String title = 'title';

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ReusableWidgets.getAppBar(title, context);
        },
      ),
    ));

    expect(find.widgetWithText(AppBar, '$title'), findsOneWidget);
  });

  testWidgets('should build app bar with avatar', (WidgetTester tester) async {
    String title = 'title';

    MockAuth auth = MockAuth();

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return ReusableWidgets.getAppBarWithAvatar(
              title, context, auth, Key(Keys.profileButton), () {});
        },
      ),
    ));

    expect(find.widgetWithText(AppBar, '$title'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.widgetWithIcon(FlatButton, Icons.person), findsOneWidget);
  });

  testWidgets('description', (WidgetTester tester) async {
    String hintText = 'hintText';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ReusableWidgets.getForm(
            Key(Keys.emailFormForSignUp),
            TextEditingController(),
            hintText,
            (value) => null,
            Icon(Icons.email)),
      ),
    ));

    expect(find.widgetWithIcon(TextFormField, Icons.email), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '$hintText'), findsOneWidget);
  });
}
