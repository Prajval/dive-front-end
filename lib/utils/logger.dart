import 'package:logger/logger.dart';

final logger = Logger();

Logger getLogger() {
  return logger;
}

// Log strings
const String settingUpDependencies = 'Setting up dependencies';
const String startingTheApp = 'Starting the app';

// general
const String loading = 'Loading';
const String initializing = 'Initializing';
const String disposing = 'Disposing';

// fetching user
const String fetchingUser = 'fetching user';
const String userIsNotNull = 'user is not null';
const String userIsNull = 'user is null';
const String userIdIs = 'User id is ';
const String errorFetchingUser = 'Error fetching user';

// email verification
const String emailIsVerified = 'email is verified';
const String emailIsNotVerified = 'email not verified';
const String errorFetchingEmailVerificationStatus =
    'Fetching email verification status failed';

// root
const String initializingRoot =
    initializing + ' root, checking if user is logged in\nGetting current user';
const String userIsLoggedIn = 'user is logged in';
const String userIsNotLoggedIn = 'User is not logged in.';
const String disposingRoot = disposing + ' root';

// sign in
const String initializingSignInScreen = initializing + ' sign in screen';
const String disposingSignInScreen = disposing + ' sign in screen';
const String formIsValidSigningIn = 'form is valid, trying to sign in';
const String signInSuccessful = 'Sign in successful';
const String signInFailed = 'Sign in failed';

// register
const String initializingRegisterScreen = initializing + ' register screen';
const String disposingRegisterScreen = disposing + ' register screen';

// profile
const String initializingProfileScreen = initializing + ' profile screen';
const String disposingProfileScreen = disposing + ' profile screen';
const String userEmailIsNotVerified = 'user email is not verified';
const String userDetailsLoaded = 'user details loaded';
const String errorLoadingUserDetails = 'loading user details failed';

// email verification
const String initiatingEmailVerification = 'initiating email verification';
const String emailVerificationSent = 'email verification sent successfully';

// chat list
const String initializingChatList = initializing + ' chat list screen';
const String disposingChatList = disposing + ' chat list screen';

// ask question
const String initializingAskQuestion = initializing + ' ask question screen';
const String disposingAskQuestion = disposing + ' ask question screen';

// question answer
const String initializingQuestionAnswer =
    initializing + ' question answer screen';
const String disposingQuestionAnswer = disposing + ' question answer screen';

// question with related questions
const String initializingQuestionWithRelatedQuestions =
    initializing + ' question with related questions';
const String disposingQuestionWithRelatedQuestions =
    disposing + ' question with related questions screen';
