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
  /// **'Mood {score}'**
  String dreamsListMoodLabel(String score);

  /// No description provided for @dreamsListMoodNoScore.
  ///
  /// In en, this message translates to:
  /// **'Mood -'**
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
  /// **'Mood score (1-5)'**
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
  /// **'Mood score is required'**
  String get dreamFormValidationMoodRequired;

  /// No description provided for @dreamFormValidationMoodRange.
  ///
  /// In en, this message translates to:
  /// **'Mood score must be between 1 and 5'**
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
  /// **'Mood score'**
  String get dreamDetailMoodScore;

  /// No description provided for @dreamDetailMoodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Your mood when you woke up,\nfrom 1 (very bad) to 5 (excellent).'**
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
  /// **'Avg. mood'**
  String get dashboardAvgMood;

  /// No description provided for @dashboardAiAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'AI analyzed'**
  String get dashboardAiAnalyzed;

  /// No description provided for @dashboardMoodEvolution.
  ///
  /// In en, this message translates to:
  /// **'Mood evolution'**
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
