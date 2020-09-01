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

// sign in error codes
const String invalidEmail = "invalid-email";
const String wrongPassword = "wrong-password";
const String userNotFound = "user-not-found";
const String userDisabled = "user-disabled";
const String operationNotAllowed = "operation-not-allowed";
const String defaultError = "DEFAULT_ERROR";

// register error codes;
const String weakPassword = "weak-password";
const String emailAlreadyInUse = "email-already-in-use";
const String malformedEmail = "invalid-email";

// error codes
const String badRequestCode = "BAD_REQUEST";
const String serverErrorCode = "SERVER_ERROR";

// other error codes
const String userIsNullCode = "User is null";
