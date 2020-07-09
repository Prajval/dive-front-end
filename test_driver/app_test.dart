import 'package:dive/keys.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('dive app', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('should sign in and sign out', () async {
      final emailForm = find.byValueKey(Keys.emailFormForSignIn);
      final passwordForm = find.byValueKey(Keys.passwordFormForSignIn);
      final signInButton = find.byValueKey(Keys.signInButton);

      await driver.waitFor(emailForm);
      await driver.tap(emailForm);
      await driver.enterText('prajval0016@gmail.com');
      await driver.waitFor(passwordForm);
      await driver.tap(passwordForm);
      await driver.enterText('qwerty');
      await driver.tap(signInButton);

      final logOutButton = find.byValueKey(Keys.signOutButton);
      await driver.waitFor(logOutButton);
      await driver.tap(logOutButton);

      await driver.waitFor(signInButton);
    });

    test('should register and send email verification and signout', () async {
      final signUpButton = find.byValueKey(Keys.signUpButton);

      await driver.waitFor(signUpButton);
      await driver.tap(signUpButton);

      final nameForm = find.byValueKey(Keys.nameFormForSignUp);
      final emailForm = find.byValueKey(Keys.emailFormForSignUp);
      final passwordForm = find.byValueKey(Keys.passwordFormForSignUp);
      final registerButton = find.byValueKey(Keys.registerButton);

      await driver.waitFor(emailForm);
      await driver.tap(emailForm);
      await driver.enterText('somethingnew2@gmail.com');

      await driver.waitFor(passwordForm);
      await driver.tap(passwordForm);
      await driver.enterText('qwerty');

      await driver.waitFor(nameForm);
      await driver.tap(nameForm);
      await driver.enterText('someoneElse');

      await driver.waitFor(registerButton);
      await driver.tap(registerButton);

      final verifyEmailButton = find.byValueKey(Keys.verifyEmailButton);
      await driver.waitFor(verifyEmailButton);
      await driver.tap(verifyEmailButton);

      final logOutButton = find.byValueKey(Keys.signOutButton);
      await driver.waitFor(logOutButton);
      await driver.tap(logOutButton);

      final signInButton = find.byValueKey(Keys.signInButton);
      await driver.waitFor(signInButton);
    });
  });
}
