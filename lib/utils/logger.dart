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
const String openedRoot = "Opened Root";

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
const String chatDetailsLoaded = 'chat details loaded';
const String errorLoadingChatDetails = 'Error loading chat details';
const String loadingChatDetails = 'loading chat details';

// ask question
const String initializingAskQuestion = initializing + ' ask question screen';
const String disposingAskQuestion = disposing + ' ask question screen';

// question answer
const String initializingQuestionAnswer =
    initializing + ' question answer screen';
const String disposingQuestionAnswer = disposing + ' question answer screen';
const String questionDetailsLoaded = 'question and answer loaded';
const String errorLoadingQuestionDetails = 'Error loading question and answer';
const String loadingQuestionDetails = 'loading question and answer';

// question with related questions
const String initializingQuestionWithRelatedQuestions =
    initializing + ' question with related questions';
const String disposingQuestionWithRelatedQuestions =
    disposing + ' question with related questions screen';

// fetching user questions from backend
const String fetchingUserQuestions = 'Fetching user questions from the backend';
const String fetchingUserQuestionsSuccess =
    'Successfully fetched user questions from the backend';
const String fetchingUserQuestionsError =
    'Error fetching user questions from the backend';

// fetching question details from backend
const String fetchingQuestionDetails =
    'Fetching question details from the backend';
const String fetchingQuestionDetailsSuccess =
    'Successfully fetched question details from the backend';
const String fetchingQuestionDetailsError =
    'Error fetching question details from the backend';

// registering users to backend
const String registerUserInitiation =
    'Initiating user registration to dive backend';
const String registerUserSuccess =
    'User registration to dive backend is successful';
const String registerUserError = 'Signup failed';
const String registerUserBackendError =
    'User registration to dive backend failed at the dive backend';

// asking a new question
const String askingANewQuestion = 'Asking a new question to dive backend';
const String askingNewQuestionError =
    'Error asking a new question to the backend';

// deep link
const String openingDeepLink = "Here's the deep link that was opened : \n";
const String openingLinkFailed = "Opening deep link failed with the"
    " following error :";
const String noRegisteredRoutesForTheLink = "No registered routes for"
    " the opened link";

// push notifications
const String receivedPushNotificationWhenAppOpen =
    "Received the following notification when app is in foreground : ";
const String receivedPushNotificationWhenAppIsInBackground =
    "Received the following notification when app is in the background : ";
const String receivedPushNotificationWhenAppIsClosed =
    "Received the following notification when app is closed : ";
const String failedToOpenNotification =
    "Failed to open notification with the following error :";

// updating fcm token
const String updatingFcmTokenForUser = "Updating fcm token for the user";
const String successfullyUpdatedFcmTokenForUser =
    "Successfully updated fcm token for the user";
const String updatingFcmTokenForUserFailed =
    "Updating fcm token for the user failed with the following error code : ";
