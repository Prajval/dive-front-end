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
const String invalidEmail = "ERROR_INVALID_EMAIL";
const String wrongPassword = "ERROR_WRONG_PASSWORD";
const String userNotFound = "ERROR_USER_NOT_FOUND";
const String userDisabled = "ERROR_USER_DISABLED";
const String tooManyRequests = "ERROR_TOO_MANY_REQUESTS";
const String operationNotAllowed = "ERROR_OPERATION_NOT_ALLOWED";
const String defaultError = "DEFAULT_ERROR";

// register error codes;
const String weakPassword = "ERROR_WEAK_PASSWORD";
const String emailAlreadyInUse = "ERROR_EMAIL_ALREADY_IN_USE";
const String malformedEmail = "ERROR_INVALID_EMAIL";

// error codes
const String badRequestCode = "BAD_REQUEST";
const String serverErrorCode = "SERVER_ERROR";

// other error codes
const String userIsNullCode = "User is null";
