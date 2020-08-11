import 'package:flutter/material.dart';

// Colors
final Color appWhiteColor = Colors.white;
final Color signUpGreyColor = Colors.grey;
final Color appPrimaryColor = Color(0xFF0BBFD6);
final Color appBarColor = Color(0xFF0BBFD6);
final Color answerBubbleColor = Colors.grey[200];
final Color backgroundColor = Colors.grey[50];
final Color hintColor = Colors.grey[350];
final Color whiteTextColor = Colors.white;
final Color blackTextColor = Colors.black87;
final Color exclamationMessageColor = Colors.grey[700];

final radiusBubble = BorderRadius.only(
  topLeft: Radius.circular(10.0),
  topRight: Radius.circular(10.0),
  bottomLeft: Radius.circular(10.0),
  bottomRight: Radius.circular(10.0),
);

// Strings

// general
final String typeQuestionHere = "Type a question";
final String questionUnavailableMessage =
    "Sorry, we don't have that question. Here are some related questions we found.";
final String tapHereIfUnsatisfiedMessage =
    "Tap here if this doesn't answer your question. We will get back to you with an answer shortly.";
const String errorTitle = 'Error';
const String ok = 'Ok';
const String emailRegex =
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
const String dontHaveAnAccount = 'Don\'t have an account ?';
const String failedToFetchUserDetails =
    'Failed to fetch user details. Please try again after some time.';
const String failedToSendVerificationEmail =
    'Failed to send verification email.';
const String failedToSendVerificationEmailMessage =
    'Sending verification email failed. Please try again.';
const String emailNotVerified = 'Your email is not verified.';
const String signOutSuccess = 'Sign out success';
const String signOutFailed = 'Signing out failed. Please try again.';
const String initiatingSignOut = 'initiating signout';
const String welcome = 'Welcome';
const String welcomeMessage = 'We are here to help you!';
const String failedToFetchChatList =
    'Failed to fetch chat list. Please try again.';

//AppBar strings
const String loginAppBar = 'Login';
const String registerAppBar = 'Register';
const String errorAppBar = 'Error';
const String emailVerificationAppBar = 'Email verification';
const String profileAppBar = 'Profile';
const String chatListAppBar = 'Questions';
const String questionAnswerAppBar = 'Questions';
const String newQuestionAppBar = 'New Question';
const String relatedQuestionsAppBar = 'Related Questions';

// Form strings
const String emailHint = 'Enter your email';
const String emailEmptyValidatorError = 'Please enter some text';
const String invalidEmailValidatorError = 'Please enter a valid email';
const String enterPasswordHint = 'Please enter your password';
const String passwordEmptyValidationError = 'Please enter some password';
const String chooseAPasswordHint = 'Choose a password';
const String nameHint = 'Enter your full name';
const String nameEmptyValidatorError = 'Please enter some text';

// Flat button strings
const String loginButton = 'Login';
const String forgotPasswordButton = 'Forgot password';
const String signUpButton = 'SIGN UP';
const String registerButton = 'Register';
const String verifyEmailButton = 'Verify email';
const String signOutButton = 'Sign out';

// sign in error codes
const String invalidEmail = "ERROR_INVALID_EMAIL";
const String wrongPassword = "ERROR_WRONG_PASSWORD";
const String userNotFound = "ERROR_USER_NOT_FOUND";
const String userDisabled = "ERROR_USER_DISABLED";
const String tooManyRequests = "ERROR_TOO_MANY_REQUESTS";
const String operationNotAllowed = "ERROR_OPERATION_NOT_ALLOWED";
const String defaultError = "DEFAULT_ERROR";

// sign in user side displayed error messages
const String invalidEmailMessage =
    'Your email address appears to be incorrect. Please try again.';
const String wrongPasswordMessage = 'Your password is wrong. Please try again.';
const String userNotFoundMessage =
    'User with this email doesn\'t exist. Please try again.';
const String userDisabledMessage =
    'User with this email has been disabled. Please try logging in with a different user.';
const String tooManyRequestsMessage =
    'You have tried to login too many times. Please try again later.';
const String operationNotAllowedMessage =
    'An error occurred while trying to login. Please try again later.';
const String defaultErrorMessageForSignIn =
    'An error occurred while trying to login. Please try again.';

// register error codes;
const String weakPassword = "ERROR_WEAK_PASSWORD";
const String emailAlreadyInUse = "ERROR_EMAIL_ALREADY_IN_USE";
const String malformedEmail = "ERROR_INVALID_EMAIL";

// register user side displayed error messages
const String weakPasswordMessage =
    'Your password is weak. Please enter at least six characters';
const String malformedEmailMessage =
    'The email address is malformed. Please try again.';
const String emailAlreadyInUseMessage =
    'Email already in use. Please try with a different email.';
const String defaultErrorMessageForRegistration =
    'An error occurred while trying to register. Please try again.';

// error codes
const String badRequestCode = "BAD_REQUEST";
const String serverErrorCode = "SERVER_ERROR";
