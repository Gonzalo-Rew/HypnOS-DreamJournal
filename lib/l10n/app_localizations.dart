import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Hypnos Dream Journal'**
  String get appName;

  /// Label for language selector
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get loginCreateAccount;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerButton;

  /// No description provided for @registerSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. Please login.'**
  String get registerSuccessMessage;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get fieldConfirmPassword;

  /// No description provided for @fieldDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get fieldDisplayName;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordTooShort;

  /// No description provided for @validationPasswordNoUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get validationPasswordNoUppercase;

  /// No description provided for @validationPasswordNoLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get validationPasswordNoLowercase;

  /// No description provided for @validationPasswordNoDigit.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get validationPasswordNoDigit;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsMismatch;

  /// No description provided for @validationDisplayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Display name is required'**
  String get validationDisplayNameRequired;

  /// No description provided for @validationDisplayNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Display name must be at least 2 characters'**
  String get validationDisplayNameTooShort;

  /// No description provided for @validationDisplayNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Display name must be less than 50 characters'**
  String get validationDisplayNameTooLong;

  /// No description provided for @validationDisplayNameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Display name contains unsupported characters'**
  String get validationDisplayNameInvalidChars;

  /// No description provided for @validationDisplayNameTaken.
  ///
  /// In en, this message translates to:
  /// **'This name is already taken, please choose another'**
  String get validationDisplayNameTaken;

  /// No description provided for @validationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String validationFieldRequired(String fieldName);

  /// No description provided for @validationFieldTooShort.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {min} characters'**
  String validationFieldTooShort(int min);

  /// No description provided for @validationFieldTooLong.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed {max} characters'**
  String validationFieldTooLong(int max);

  /// No description provided for @validationFieldRequired2.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationFieldRequired2;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture your dream in under a minute.'**
  String get homeSubtitle;

  /// No description provided for @homeCreateDream.
  ///
  /// In en, this message translates to:
  /// **'Create new dream'**
  String get homeCreateDream;

  /// No description provided for @homeListDreams.
  ///
  /// In en, this message translates to:
  /// **'List dreams'**
  String get homeListDreams;

  /// No description provided for @homeProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeProfile;

  /// No description provided for @homeTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeTodayLabel;

  /// No description provided for @homeNoDreamsToday.
  ///
  /// In en, this message translates to:
  /// **'No dreams registered today'**
  String get homeNoDreamsToday;

  /// No description provided for @dreamsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Dreams'**
  String get dreamsListTitle;

  /// No description provided for @dreamsListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dreams yet.'**
  String get dreamsListEmpty;

  /// No description provided for @dreamsListCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first dream'**
  String get dreamsListCreateFirst;

  /// No description provided for @dreamsListRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get dreamsListRetry;

  /// No description provided for @dreamsListMoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Intensity {score}'**
  String dreamsListMoodLabel(String score);

  /// No description provided for @dreamsListMoodNoScore.
  ///
  /// In en, this message translates to:
  /// **'Intensity -'**
  String get dreamsListMoodNoScore;

  /// No description provided for @dreamsListTooltipCreate.
  ///
  /// In en, this message translates to:
  /// **'Create new dream'**
  String get dreamsListTooltipCreate;

  /// No description provided for @dreamsListNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to view dreams.'**
  String get dreamsListNotLoggedIn;

  /// No description provided for @dreamFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New dream'**
  String get dreamFormNewTitle;

  /// No description provided for @dreamFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit dream'**
  String get dreamFormEditTitle;

  /// No description provided for @dreamFormFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Dream title'**
  String get dreamFormFieldTitle;

  /// No description provided for @dreamFormFieldText.
  ///
  /// In en, this message translates to:
  /// **'Dream text'**
  String get dreamFormFieldText;

  /// No description provided for @dreamFormFieldMood.
  ///
  /// In en, this message translates to:
  /// **'Emotional intensity (1-5)'**
  String get dreamFormFieldMood;

  /// No description provided for @dreamFormFieldContextNotes.
  ///
  /// In en, this message translates to:
  /// **'Context notes'**
  String get dreamFormFieldContextNotes;

  /// No description provided for @dreamFormFieldAiCategory.
  ///
  /// In en, this message translates to:
  /// **'AI category'**
  String get dreamFormFieldAiCategory;

  /// No description provided for @dreamFormValidationMoodRequired.
  ///
  /// In en, this message translates to:
  /// **'Emotional intensity is required'**
  String get dreamFormValidationMoodRequired;

  /// No description provided for @dreamFormValidationMoodRange.
  ///
  /// In en, this message translates to:
  /// **'Emotional intensity must be between 1 and 5'**
  String get dreamFormValidationMoodRange;

  /// No description provided for @dreamFormSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get dreamFormSaveButton;

  /// No description provided for @dreamFormCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create dream'**
  String get dreamFormCreateButton;

  /// No description provided for @dreamFormNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to save a dream.'**
  String get dreamFormNotLoggedIn;

  /// No description provided for @dreamDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Dream details'**
  String get dreamDetailTitle;

  /// No description provided for @dreamDetailMoodScore.
  ///
  /// In en, this message translates to:
  /// **'Emotional intensity'**
  String get dreamDetailMoodScore;

  /// No description provided for @dreamDetailMoodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Your emotional intensity when waking up:\n1 Calm, 2 Mild, 3 Moderate, 4 Intense, 5 Extreme.'**
  String get dreamDetailMoodTooltip;

  /// No description provided for @dreamDetailContextNotes.
  ///
  /// In en, this message translates to:
  /// **'Context notes'**
  String get dreamDetailContextNotes;

  /// No description provided for @dreamDetailAiCategory.
  ///
  /// In en, this message translates to:
  /// **'AI category'**
  String get dreamDetailAiCategory;

  /// No description provided for @dreamDetailAiCategoryPending.
  ///
  /// In en, this message translates to:
  /// **'Pending AI categorization'**
  String get dreamDetailAiCategoryPending;

  /// No description provided for @dreamDetailEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get dreamDetailEditButton;

  /// No description provided for @dreamDetailDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dreamDetailDeleteButton;

  /// No description provided for @dreamDetailDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete dream'**
  String get dreamDetailDeleteDialogTitle;

  /// No description provided for @dreamDetailDeleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get dreamDetailDeleteDialogContent;

  /// No description provided for @dreamDetailDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dreamDetailDeleteCancel;

  /// No description provided for @dreamDetailDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dreamDetailDeleteConfirm;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String profileEmail(String email);

  /// No description provided for @profileNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get profileNotificationsEnabled;

  /// No description provided for @profileNotificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification time'**
  String get profileNotificationTime;

  /// No description provided for @profileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get profileSaveButton;

  /// No description provided for @profileSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileSaveSuccess;

  /// No description provided for @profileLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogoutButton;

  /// No description provided for @profileIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Your profile is not complete. Save to finish setup.'**
  String get profileIncomplete;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile. Try logging out and back in.'**
  String get profileLoadError;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile.'**
  String get profileSaveError;

  /// No description provided for @profileLogoutError.
  ///
  /// In en, this message translates to:
  /// **'Error logging out. Please try again.'**
  String get profileLogoutError;

  /// No description provided for @profileFirestoreError.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile: {message}'**
  String profileFirestoreError(String message);

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @audioRecorderTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice recording'**
  String get audioRecorderTitle;

  /// No description provided for @audioRecorderStart.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get audioRecorderStart;

  /// No description provided for @audioRecorderStop.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get audioRecorderStop;

  /// No description provided for @audioRecorderDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get audioRecorderDelete;

  /// No description provided for @audioRecorderRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get audioRecorderRecording;

  /// No description provided for @audioRecorderDone.
  ///
  /// In en, this message translates to:
  /// **'Audio recorded'**
  String get audioRecorderDone;

  /// No description provided for @audioRecorderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get audioRecorderPermissionDenied;

  /// No description provided for @audioPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice recording'**
  String get audioPlayerTitle;

  /// No description provided for @audioPlayerError.
  ///
  /// In en, this message translates to:
  /// **'Error loading audio'**
  String get audioPlayerError;

  /// No description provided for @dreamFormAudioSection.
  ///
  /// In en, this message translates to:
  /// **'Voice recording (optional)'**
  String get dreamFormAudioSection;

  /// No description provided for @dreamFormAnalyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze with AI'**
  String get dreamFormAnalyzeButton;

  /// No description provided for @dreamFormAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing dream...'**
  String get dreamFormAnalyzing;

  /// No description provided for @dreamFormAnalysisSuccess.
  ///
  /// In en, this message translates to:
  /// **'AI analysis complete'**
  String get dreamFormAnalysisSuccess;

  /// No description provided for @dreamFormAnalysisError.
  ///
  /// In en, this message translates to:
  /// **'AI analysis failed'**
  String get dreamFormAnalysisError;

  /// No description provided for @dreamDetailAudioSection.
  ///
  /// In en, this message translates to:
  /// **'Voice recording'**
  String get dreamDetailAudioSection;

  /// No description provided for @dreamDetailTranscription.
  ///
  /// In en, this message translates to:
  /// **'Transcription'**
  String get dreamDetailTranscription;

  /// No description provided for @dreamDetailAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get dreamDetailAiAnalysis;

  /// No description provided for @dreamDetailAiSentiment.
  ///
  /// In en, this message translates to:
  /// **'Sentiment'**
  String get dreamDetailAiSentiment;

  /// No description provided for @dreamDetailAiEmotions.
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get dreamDetailAiEmotions;

  /// No description provided for @dreamDetailAiCharacters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get dreamDetailAiCharacters;

  /// No description provided for @dreamDetailAiPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get dreamDetailAiPlaces;

  /// No description provided for @dreamDetailAiThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get dreamDetailAiThemes;

  /// No description provided for @dreamDetailAiPsychNote.
  ///
  /// In en, this message translates to:
  /// **'Psychological note'**
  String get dreamDetailAiPsychNote;

  /// No description provided for @dreamDetailAiSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get dreamDetailAiSummary;

  /// No description provided for @dreamDetailAnalyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Run AI analysis'**
  String get dreamDetailAnalyzeButton;

  /// No description provided for @dreamDetailAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get dreamDetailAnalyzing;

  /// No description provided for @dreamDetailAnalysisNoKey.
  ///
  /// In en, this message translates to:
  /// **'Add a Gemini API key in your profile to enable AI analysis.'**
  String get dreamDetailAnalysisNoKey;

  /// No description provided for @profileGeminiApiKey.
  ///
  /// In en, this message translates to:
  /// **'Gemini API key'**
  String get profileGeminiApiKey;

  /// No description provided for @profileGeminiApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your Google AI Studio key here'**
  String get profileGeminiApiKeyHint;

  /// No description provided for @profileGeminiApiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'Gemini API key saved'**
  String get profileGeminiApiKeySaved;

  /// No description provided for @profileGeminiApiKeyCleared.
  ///
  /// In en, this message translates to:
  /// **'Gemini API key removed'**
  String get profileGeminiApiKeyCleared;

  /// No description provided for @profileAiEnabled.
  ///
  /// In en, this message translates to:
  /// **'AI analysis enabled'**
  String get profileAiEnabled;

  /// No description provided for @profileAiEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Enable Gemini AI analysis for your dreams'**
  String get profileAiEnabledHint;

  /// No description provided for @homeDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeDashboard;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardTotalDreams.
  ///
  /// In en, this message translates to:
  /// **'Total dreams'**
  String get dashboardTotalDreams;

  /// No description provided for @dashboardThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get dashboardThisMonth;

  /// No description provided for @dashboardAvgMood.
  ///
  /// In en, this message translates to:
  /// **'Avg. intensity'**
  String get dashboardAvgMood;

  /// No description provided for @dashboardAiAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'AI analyzed'**
  String get dashboardAiAnalyzed;

  /// No description provided for @dashboardMoodEvolution.
  ///
  /// In en, this message translates to:
  /// **'Intensity evolution'**
  String get dashboardMoodEvolution;

  /// No description provided for @dashboardDreamsPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Dreams per week'**
  String get dashboardDreamsPerWeek;

  /// No description provided for @dashboardTopCategories.
  ///
  /// In en, this message translates to:
  /// **'Top AI categories'**
  String get dashboardTopCategories;

  /// No description provided for @dashboardTopTags.
  ///
  /// In en, this message translates to:
  /// **'Most used tags'**
  String get dashboardTopTags;

  /// No description provided for @dashboardNoData.
  ///
  /// In en, this message translates to:
  /// **'No dreams yet. Start recording your dreams!'**
  String get dashboardNoData;

  /// No description provided for @dashboardNoDreamsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'None this month'**
  String get dashboardNoDreamsThisMonth;

  /// No description provided for @welcomeMorpheusTitle.
  ///
  /// In en, this message translates to:
  /// **'Morpheus'**
  String get welcomeMorpheusTitle;

  /// No description provided for @welcomeMorpheusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal dream journal'**
  String get welcomeMorpheusSubtitle;

  /// No description provided for @welcomeBeginJourney.
  ///
  /// In en, this message translates to:
  /// **'Begin your journey'**
  String get welcomeBeginJourney;

  /// No description provided for @welcomeAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get welcomeAlreadyHaveAccount;

  /// No description provided for @welcomeLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get welcomeLogIn;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Explore the depths of your dreams'**
  String get welcomeTagline;

  /// No description provided for @loginPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the Dream Portal'**
  String get loginPortalTitle;

  /// No description provided for @loginPortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your dream journal'**
  String get loginPortalSubtitle;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignIn;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @registerPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your Dream Portal'**
  String get registerPortalTitle;

  /// No description provided for @registerPortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey into your subconscious'**
  String get registerPortalSubtitle;

  /// No description provided for @registerDreamerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your dreamer name'**
  String get registerDreamerNameHint;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Your email address'**
  String get registerEmailHint;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerCreateAccount;

  /// No description provided for @registerOrSecureAccess.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get registerOrSecureAccess;

  /// No description provided for @registerContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get registerContinueApple;

  /// No description provided for @registerContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get registerContinueGoogle;

  /// No description provided for @registerTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By registering you agree to our'**
  String get registerTermsPrefix;

  /// No description provided for @registerTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get registerTermsLink;

  /// No description provided for @registerTermsSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get registerTermsSuffix;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is incorrect'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with that email'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please try again later'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection'**
  String get authErrorNetworkFailed;

  /// No description provided for @authErrorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is not available'**
  String get authErrorOperationNotAllowed;

  /// No description provided for @authErrorGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Google. Please try again'**
  String get authErrorGoogleFailed;

  /// No description provided for @authErrorAppleFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Apple. Please try again'**
  String get authErrorAppleFailed;

  /// No description provided for @authErrorAppleNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Apple sign in is not available on this device'**
  String get authErrorAppleNotSupported;

  /// No description provided for @authErrorAppleNotInteractive.
  ///
  /// In en, this message translates to:
  /// **'Apple sign in requires user interaction'**
  String get authErrorAppleNotInteractive;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again'**
  String get authErrorGeneric;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'PROFILE & ACCOUNT'**
  String get settingsSectionAccount;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get settingsEditProfile;

  /// No description provided for @settingsAccountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & security'**
  String get settingsAccountSecurity;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get settingsSectionPreferences;

  /// No description provided for @settingsSectionAi.
  ///
  /// In en, this message translates to:
  /// **'ARTIFICIAL INTELLIGENCE'**
  String get settingsSectionAi;

  /// No description provided for @settingsAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Morpheus - AI Analysis'**
  String get settingsAiTitle;

  /// No description provided for @settingsAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get settingsAiSubtitle;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get settingsSectionLegal;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get settingsTermsAndConditions;

  /// No description provided for @dreamsListFilterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get dreamsListFilterByDate;

  /// No description provided for @dreamsListResults.
  ///
  /// In en, this message translates to:
  /// **'{count} dream{count, plural, =1{} other{s}} found'**
  String dreamsListResults(int count);

  /// No description provided for @dreamsListNoDreamsInRange.
  ///
  /// In en, this message translates to:
  /// **'No dreams in this date range'**
  String get dreamsListNoDreamsInRange;

  /// No description provided for @dreamsListClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get dreamsListClearFilter;

  /// No description provided for @dreamsListMoodUnrated.
  ///
  /// In en, this message translates to:
  /// **'Unrated'**
  String get dreamsListMoodUnrated;

  /// No description provided for @dreamsListMoodPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get dreamsListMoodPositive;

  /// No description provided for @dreamsListMoodNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get dreamsListMoodNeutral;

  /// No description provided for @dreamsListMoodIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get dreamsListMoodIntense;

  /// No description provided for @dreamsListUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get dreamsListUntitled;

  /// No description provided for @dreamFormNeedTextOrAudio.
  ///
  /// In en, this message translates to:
  /// **'Add a description or an audio recording.'**
  String get dreamFormNeedTextOrAudio;

  /// No description provided for @dreamFormDescriptionMin.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least {min} characters for useful analysis.'**
  String dreamFormDescriptionMin(int min);

  /// No description provided for @dreamFormAudioLimit.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to {max} recordings.'**
  String dreamFormAudioLimit(int max);

  /// No description provided for @dreamFormDateSection.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get dreamFormDateSection;

  /// No description provided for @dreamFormTitleSection.
  ///
  /// In en, this message translates to:
  /// **'TITLE'**
  String get dreamFormTitleSection;

  /// No description provided for @dreamFormTitleHint.
  ///
  /// In en, this message translates to:
  /// **'The neon forest...'**
  String get dreamFormTitleHint;

  /// No description provided for @dreamFormTellItSection.
  ///
  /// In en, this message translates to:
  /// **'TELL IT'**
  String get dreamFormTellItSection;

  /// No description provided for @dreamFormDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Write what you remember...'**
  String get dreamFormDescriptionHint;

  /// No description provided for @dreamFormIntensitySection.
  ///
  /// In en, this message translates to:
  /// **'EMOTIONAL INTENSITY'**
  String get dreamFormIntensitySection;

  /// No description provided for @dreamFormNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next ->'**
  String get dreamFormNextButton;

  /// No description provided for @dreamFormPrivateSaveHint.
  ///
  /// In en, this message translates to:
  /// **'Your dream will be saved privately'**
  String get dreamFormPrivateSaveHint;

  /// No description provided for @dreamFormVoiceRecordingsSection.
  ///
  /// In en, this message translates to:
  /// **'Voice recordings'**
  String get dreamFormVoiceRecordingsSection;

  /// No description provided for @dreamFormAudioLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit reached (max. {max})'**
  String dreamFormAudioLimitReached(int max);

  /// No description provided for @dreamFormRecordAudio.
  ///
  /// In en, this message translates to:
  /// **'Record audio'**
  String get dreamFormRecordAudio;

  /// No description provided for @dreamFormIntensityCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get dreamFormIntensityCalm;

  /// No description provided for @dreamFormIntensityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get dreamFormIntensityMild;

  /// No description provided for @dreamFormIntensityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get dreamFormIntensityModerate;

  /// No description provided for @dreamFormIntensityIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get dreamFormIntensityIntense;

  /// No description provided for @dreamFormIntensityExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get dreamFormIntensityExtreme;

  /// No description provided for @dreamFormContextTags.
  ///
  /// In en, this message translates to:
  /// **'Context tags'**
  String get dreamFormContextTags;

  /// No description provided for @dreamFormContextTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Morpheus will generate them automatically after saving'**
  String get dreamFormContextTagsHint;

  /// No description provided for @dashboardNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Session not started. Please sign in again.'**
  String get dashboardNotLoggedIn;

  /// No description provided for @dashboardInsightAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Morpheus is analyzing your dreams.'**
  String get dashboardInsightAnalyzing;

  /// No description provided for @dashboardInsightNeedMood.
  ///
  /// In en, this message translates to:
  /// **'Record emotional intensity in your dreams to get correlations.'**
  String get dashboardInsightNeedMood;

  /// No description provided for @dashboardInsightTrendUp.
  ///
  /// In en, this message translates to:
  /// **'Your emotional state in dreams has improved this week. Morpheus detects a positive trend.'**
  String get dashboardInsightTrendUp;

  /// No description provided for @dashboardInsightTrendDown.
  ///
  /// In en, this message translates to:
  /// **'Your recent dreams show higher emotional intensity. Consider reviewing your sleep habits.'**
  String get dashboardInsightTrendDown;

  /// No description provided for @dashboardInsightPositive.
  ///
  /// In en, this message translates to:
  /// **'Your dreams consistently reflect a positive emotional state.'**
  String get dashboardInsightPositive;

  /// No description provided for @dashboardInsightNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral emotional state in your dreams. Morpheus does not detect alert patterns.'**
  String get dashboardInsightNeutral;

  /// No description provided for @dashboardInsightTense.
  ///
  /// In en, this message translates to:
  /// **'Morpheus detects recurring emotional tension. Consider relaxation routines before sleep.'**
  String get dashboardInsightTense;

  /// No description provided for @dashboardDayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dashboardDayMon;

  /// No description provided for @dashboardDayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dashboardDayTue;

  /// No description provided for @dashboardDayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dashboardDayWed;

  /// No description provided for @dashboardDayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dashboardDayThu;

  /// No description provided for @dashboardDayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dashboardDayFri;

  /// No description provided for @dashboardDaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get dashboardDaySat;

  /// No description provided for @dashboardDaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get dashboardDaySun;

  /// No description provided for @dashboardMoodTone7d.
  ///
  /// In en, this message translates to:
  /// **'EMOTIONAL TONE (7 DAYS)'**
  String get dashboardMoodTone7d;

  /// No description provided for @dashboardRecurringElements.
  ///
  /// In en, this message translates to:
  /// **'RECURRING ELEMENTS'**
  String get dashboardRecurringElements;

  /// No description provided for @dashboardCorrelationNeedMore.
  ///
  /// In en, this message translates to:
  /// **'You need more records to detect correlations. Keep adding dreams every day.'**
  String get dashboardCorrelationNeedMore;

  /// No description provided for @dashboardCorrelationNeedMood.
  ///
  /// In en, this message translates to:
  /// **'Rate your dream emotional intensity to enable correlation analysis.'**
  String get dashboardCorrelationNeedMood;

  /// No description provided for @dashboardCorrelationHigh.
  ///
  /// In en, this message translates to:
  /// **'Your intense dreams match days with high energy and positive activity.'**
  String get dashboardCorrelationHigh;

  /// No description provided for @dashboardCorrelationStable.
  ///
  /// In en, this message translates to:
  /// **'Morpheus detects emotional stability. Your dreams reflect your daily rhythm.'**
  String get dashboardCorrelationStable;

  /// No description provided for @dashboardCorrelationStress.
  ///
  /// In en, this message translates to:
  /// **'Your intense dreams match days of high activity or stress. Consider nighttime relaxation routines.'**
  String get dashboardCorrelationStress;

  /// No description provided for @dashboardCorrelationTitle.
  ///
  /// In en, this message translates to:
  /// **'CORRELATION'**
  String get dashboardCorrelationTitle;

  /// No description provided for @editProfileAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated'**
  String get editProfileAvatarUpdated;

  /// No description provided for @editProfileAvatarRemoved.
  ///
  /// In en, this message translates to:
  /// **'Avatar removed'**
  String get editProfileAvatarRemoved;

  /// No description provided for @editProfileAvatarRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Error removing avatar'**
  String get editProfileAvatarRemoveError;

  /// No description provided for @editProfileAvatarUploadError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading avatar'**
  String get editProfileAvatarUploadError;

  /// No description provided for @editProfileNameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Could not validate name'**
  String get editProfileNameValidationError;

  /// No description provided for @editProfileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile update failed'**
  String get editProfileUpdateFailed;

  /// No description provided for @editProfileChangeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get editProfileChangeAvatar;

  /// No description provided for @editProfileRemoveAvatar.
  ///
  /// In en, this message translates to:
  /// **'Remove avatar'**
  String get editProfileRemoveAvatar;

  /// No description provided for @editProfileUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get editProfileUsername;

  /// No description provided for @profilePublishedDreams.
  ///
  /// In en, this message translates to:
  /// **'Published dreams'**
  String get profilePublishedDreams;

  /// No description provided for @profileNoPublishedDreams.
  ///
  /// In en, this message translates to:
  /// **'You have not published any dreams yet'**
  String get profileNoPublishedDreams;

  /// No description provided for @profileFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profileFollowers;

  /// No description provided for @profileFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profileFollowing;

  /// No description provided for @dreamAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze dream'**
  String get dreamAnalysisTitle;

  /// No description provided for @dreamAnalysisUploadingRecordings.
  ///
  /// In en, this message translates to:
  /// **'Uploading recordings...'**
  String get dreamAnalysisUploadingRecordings;

  /// No description provided for @dreamAnalysisAudioUploadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio upload failed'**
  String get dreamAnalysisAudioUploadFailedTitle;

  /// No description provided for @dreamAnalysisAudioUploadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t upload your recordings. Check your connection and try again before saving.'**
  String get dreamAnalysisAudioUploadFailedMessage;

  /// No description provided for @dreamAnalysisMissingContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Missing content'**
  String get dreamAnalysisMissingContentTitle;

  /// No description provided for @dreamAnalysisMissingContentMessage.
  ///
  /// In en, this message translates to:
  /// **'To save without analysis you need a title and at least valid text or audio. Record again or add a description.'**
  String get dreamAnalysisMissingContentMessage;

  /// No description provided for @dreamAnalysisMorfeoListening.
  ///
  /// In en, this message translates to:
  /// **'Morpheus is listening...'**
  String get dreamAnalysisMorfeoListening;

  /// No description provided for @dreamAnalysisMorfeoTranscriptionFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Morpheus could not transcribe'**
  String get dreamAnalysisMorfeoTranscriptionFailedTitle;

  /// No description provided for @dreamAnalysisMorfeoTranscriptionFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'There was a problem processing your recordings. This can happen when audio is unclear or too short. Try recording again with more detail or use \"Save without analysis\".'**
  String get dreamAnalysisMorfeoTranscriptionFailedMessage;

  /// No description provided for @dreamAnalysisMorfeoTranscriptionReadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'The recorded audio could not be read correctly. This can happen when audio is unclear or too short. Try recording again with more detail or use \"Save without analysis\".'**
  String get dreamAnalysisMorfeoTranscriptionReadFailedMessage;

  /// No description provided for @dreamAnalysisInsufficientInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Insufficient information'**
  String get dreamAnalysisInsufficientInfoTitle;

  /// No description provided for @dreamAnalysisInsufficientInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Your audio transcription is too short for Morpheus to analyze the dream well. This can happen when audio is unclear or too short. Try recording again with more detail or use \"Save without analysis\".'**
  String get dreamAnalysisInsufficientInfoMessage;

  /// No description provided for @dreamAnalysisMorfeoInterpreting.
  ///
  /// In en, this message translates to:
  /// **'Morpheus is interpreting your dream...'**
  String get dreamAnalysisMorfeoInterpreting;

  /// No description provided for @dreamAnalysisMorfeoAnalyzeFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Morpheus could not analyze'**
  String get dreamAnalysisMorfeoAnalyzeFailedTitle;

  /// No description provided for @dreamAnalysisMorfeoAnalyzeFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'The analysis couldn\'t be completed right now. This can happen when audio is unclear or too short. Try recording again with more detail or use \"Save without analysis\".'**
  String get dreamAnalysisMorfeoAnalyzeFailedMessage;

  /// No description provided for @dreamAnalysisMorfeoAnalyzeUnexpectedMessage.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while analyzing the dream. This can happen when audio is unclear or too short. Try recording again with more detail or use \"Save without analysis\".'**
  String get dreamAnalysisMorfeoAnalyzeUnexpectedMessage;

  /// No description provided for @dreamAnalysisSavingToJournal.
  ///
  /// In en, this message translates to:
  /// **'Saving to your journal...'**
  String get dreamAnalysisSavingToJournal;

  /// No description provided for @dreamAnalysisSaveFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not save dream'**
  String get dreamAnalysisSaveFailedTitle;

  /// No description provided for @dreamAnalysisSaveFailedAudioMessage.
  ///
  /// In en, this message translates to:
  /// **'Saving could not be completed. It may be due to an incomplete audio upload or a connection issue. Check your connection and try again.'**
  String get dreamAnalysisSaveFailedAudioMessage;

  /// No description provided for @dreamAnalysisSaveFailedConnectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Saving could not be completed due to a connection or permissions issue. Please try again.'**
  String get dreamAnalysisSaveFailedConnectionMessage;

  /// No description provided for @dreamAnalysisSaveErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Error saving dream. Please try again.'**
  String get dreamAnalysisSaveErrorRetry;

  /// No description provided for @dreamAnalysisUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get dreamAnalysisUnderstood;

  /// No description provided for @dreamAnalysisSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get dreamAnalysisSomethingWentWrong;

  /// No description provided for @dreamAnalysisMorfeoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI dream interpreter'**
  String get dreamAnalysisMorfeoSubtitle;

  /// No description provided for @dreamAnalysisCardBodyWithAudio.
  ///
  /// In en, this message translates to:
  /// **'I will transcribe your recordings and analyze key emotions, places, and themes from your dream.'**
  String get dreamAnalysisCardBodyWithAudio;

  /// No description provided for @dreamAnalysisCardBodyWithoutAudio.
  ///
  /// In en, this message translates to:
  /// **'I will analyze key emotions, places, and themes from your dream and return a useful summary.'**
  String get dreamAnalysisCardBodyWithoutAudio;

  /// No description provided for @dreamAnalysisAnalyzeWithMorfeo.
  ///
  /// In en, this message translates to:
  /// **'Analyze with Morpheus'**
  String get dreamAnalysisAnalyzeWithMorfeo;

  /// No description provided for @dreamAnalysisSaveWithoutAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Save without analysis'**
  String get dreamAnalysisSaveWithoutAnalysis;

  /// No description provided for @dreamAnalysisAudioRecordingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recording{count, plural, =1{} other{s}}'**
  String dreamAnalysisAudioRecordingsCount(int count);

  /// No description provided for @dreamSavedMorfeoAnalyzeFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Morpheus could not analyze the dream'**
  String get dreamSavedMorfeoAnalyzeFailedTitle;

  /// No description provided for @dreamSavedShareWithBody.
  ///
  /// In en, this message translates to:
  /// **'✨ \"{title}\"\n\n{body}\n\n— Saved in Hypnos Dream Journal'**
  String dreamSavedShareWithBody(String title, String body);

  /// No description provided for @dreamSavedShareWithoutBody.
  ///
  /// In en, this message translates to:
  /// **'✨ \"{title}\"\n\n— Saved in Hypnos Dream Journal'**
  String dreamSavedShareWithoutBody(String title);

  /// No description provided for @dreamSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Dream saved!'**
  String get dreamSavedTitle;

  /// No description provided for @dreamSavedPublishDream.
  ///
  /// In en, this message translates to:
  /// **'Publish dream'**
  String get dreamSavedPublishDream;

  /// No description provided for @dreamSavedVisibleOnlyYou.
  ///
  /// In en, this message translates to:
  /// **'Visible only to you'**
  String get dreamSavedVisibleOnlyYou;

  /// No description provided for @dreamSavedShareSection.
  ///
  /// In en, this message translates to:
  /// **'SHARE'**
  String get dreamSavedShareSection;

  /// No description provided for @dreamSavedShareWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get dreamSavedShareWhatsapp;

  /// No description provided for @dreamSavedShareMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get dreamSavedShareMore;

  /// No description provided for @dreamSavedGoToJournal.
  ///
  /// In en, this message translates to:
  /// **'Go to journal'**
  String get dreamSavedGoToJournal;

  /// No description provided for @dreamSavedVisibleForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Visible to everyone'**
  String get dreamSavedVisibleForEveryone;

  /// No description provided for @dreamSavedVisibleForFollowers.
  ///
  /// In en, this message translates to:
  /// **'Visible to followers'**
  String get dreamSavedVisibleForFollowers;

  /// No description provided for @dreamSavedMorfeoInterpretation.
  ///
  /// In en, this message translates to:
  /// **'MORPHEUS INTERPRETATION'**
  String get dreamSavedMorfeoInterpretation;

  /// No description provided for @dreamMorfeoResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Morpheus result'**
  String get dreamMorfeoResultTitle;

  /// No description provided for @dreamMorfeoResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the full analysis before deciding how to publish your dream.'**
  String get dreamMorfeoResultSubtitle;

  /// No description provided for @dreamMorfeoResultContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to publishing'**
  String get dreamMorfeoResultContinue;

  /// No description provided for @dreamMorfeoResultEmpty.
  ///
  /// In en, this message translates to:
  /// **'Morpheus did not return enough analysis details for this dream.'**
  String get dreamMorfeoResultEmpty;

  /// No description provided for @dreamMorfeoResultEmptyField.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get dreamMorfeoResultEmptyField;

  /// No description provided for @accountSecurityBiometricDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable biometric unlock'**
  String get accountSecurityBiometricDialogTitle;

  /// No description provided for @accountSecurityBiometricDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to save this access on this device.'**
  String get accountSecurityBiometricDialogMessage;

  /// No description provided for @accountSecurityCurrentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get accountSecurityCurrentPasswordLabel;

  /// No description provided for @accountSecurityActivate.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get accountSecurityActivate;

  /// No description provided for @accountSecurityBiometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock disabled'**
  String get accountSecurityBiometricDisabled;

  /// No description provided for @accountSecurityBiometricPasswordOnly.
  ///
  /// In en, this message translates to:
  /// **'Can only be enabled for email/password accounts'**
  String get accountSecurityBiometricPasswordOnly;

  /// No description provided for @accountSecurityBiometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock enabled'**
  String get accountSecurityBiometricEnabled;

  /// No description provided for @accountSecurityBiometricEnableFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not enable biometrics'**
  String get accountSecurityBiometricEnableFailed;

  /// No description provided for @accountSecurityVisibilityEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get accountSecurityVisibilityEveryone;

  /// No description provided for @accountSecurityVisibilityFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers only'**
  String get accountSecurityVisibilityFollowers;

  /// No description provided for @accountSecurityVisibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get accountSecurityVisibilityPrivate;

  /// No description provided for @accountSecurityResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get accountSecurityResetPasswordTitle;

  /// No description provided for @accountSecurityResetPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a link to {email}.'**
  String accountSecurityResetPasswordMessage(String email);

  /// No description provided for @accountSecurityResetPasswordSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get accountSecurityResetPasswordSendLink;

  /// No description provided for @accountSecurityResetPasswordSendError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send link'**
  String get accountSecurityResetPasswordSendError;

  /// No description provided for @accountSecurityEmailSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Email sent!'**
  String get accountSecurityEmailSentTitle;

  /// No description provided for @accountSecurityEmailSentPrefix.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a reset link to '**
  String get accountSecurityEmailSentPrefix;

  /// No description provided for @accountSecurityEmailSentSuffix.
  ///
  /// In en, this message translates to:
  /// **'\n\nAlso check your spam folder.'**
  String get accountSecurityEmailSentSuffix;

  /// No description provided for @accountSecurityVisibilityUpdated.
  ///
  /// In en, this message translates to:
  /// **'Visibility updated'**
  String get accountSecurityVisibilityUpdated;

  /// No description provided for @accountSecurityLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get accountSecurityLogoutConfirmMessage;

  /// No description provided for @accountSecurityDeleteWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is incorrect'**
  String get accountSecurityDeleteWrongPassword;

  /// No description provided for @accountSecurityDeleteRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For security, log in again and retry'**
  String get accountSecurityDeleteRequiresRecentLogin;

  /// No description provided for @accountSecurityDeleteReauthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This account does not use a password. Sign in with your provider and retry'**
  String get accountSecurityDeleteReauthUnavailable;

  /// No description provided for @accountSecurityDeleteGenericError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account. Please try again'**
  String get accountSecurityDeleteGenericError;

  /// No description provided for @accountSecurityDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountSecurityDeleteTitle;

  /// No description provided for @accountSecurityDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. Enter your password to confirm.'**
  String get accountSecurityDeleteDialogMessage;

  /// No description provided for @accountSecurityDeletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get accountSecurityDeletePermanently;

  /// No description provided for @accountSecurityCredentialsSection.
  ///
  /// In en, this message translates to:
  /// **'CREDENTIALS'**
  String get accountSecurityCredentialsSection;

  /// No description provided for @accountSecurityNoData.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get accountSecurityNoData;

  /// No description provided for @accountSecurityChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get accountSecurityChangePassword;

  /// No description provided for @accountSecurityPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY'**
  String get accountSecurityPrivacySection;

  /// No description provided for @accountSecurityBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get accountSecurityBiometricTitle;

  /// No description provided for @accountSecurityBiometricSupported.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint to sign in on this device.'**
  String get accountSecurityBiometricSupported;

  /// No description provided for @accountSecurityBiometricUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This device does not support biometrics.'**
  String get accountSecurityBiometricUnsupported;

  /// No description provided for @accountSecurityDreamVisibility.
  ///
  /// In en, this message translates to:
  /// **'Dream visibility'**
  String get accountSecurityDreamVisibility;

  /// No description provided for @accountSecurityAccountActionsSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT ACTIONS'**
  String get accountSecurityAccountActionsSection;

  /// No description provided for @accountSecurityPermanentActionsHint.
  ///
  /// In en, this message translates to:
  /// **'These actions are permanent and cannot be undone.'**
  String get accountSecurityPermanentActionsHint;

  /// No description provided for @accountSecurityVisibilityEveryoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your dreams are publicly available.'**
  String get accountSecurityVisibilityEveryoneSubtitle;

  /// No description provided for @accountSecurityVisibilityFollowersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only people who follow you can see your dreams.'**
  String get accountSecurityVisibilityFollowersSubtitle;

  /// No description provided for @accountSecurityVisibilityPrivateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No one can see your dreams.'**
  String get accountSecurityVisibilityPrivateSubtitle;

  /// No description provided for @socialFollowRequestsNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Session not started'**
  String get socialFollowRequestsNotLoggedIn;

  /// No description provided for @socialFollowRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow requests'**
  String get socialFollowRequestsTitle;

  /// No description provided for @socialFollowRequestsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load requests. Please try again.'**
  String get socialFollowRequestsLoadError;

  /// No description provided for @socialFollowRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get socialFollowRequestsEmpty;

  /// No description provided for @socialFollowRequestsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get socialFollowRequestsAccept;

  /// No description provided for @socialFollowRequestsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get socialFollowRequestsDecline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
