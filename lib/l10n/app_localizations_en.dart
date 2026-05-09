// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Hypnos Dream Journal';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginButton => 'Login';

  @override
  String get loginCreateAccount => 'Create account';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerButton => 'Create account';

  @override
  String get registerSuccessMessage =>
      'Account created successfully. Please login.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldConfirmPassword => 'Confirm password';

  @override
  String get fieldDisplayName => 'Display name';

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationEmailInvalid => 'Enter a valid email address';

  @override
  String get validationPasswordRequired => 'Password is required';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get validationPasswordNoUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get validationPasswordNoLowercase =>
      'Password must contain at least one lowercase letter';

  @override
  String get validationPasswordNoDigit =>
      'Password must contain at least one number';

  @override
  String get validationConfirmPasswordRequired => 'Confirm your password';

  @override
  String get validationPasswordsMismatch => 'Passwords do not match';

  @override
  String get validationDisplayNameRequired => 'Display name is required';

  @override
  String get validationDisplayNameTooShort =>
      'Display name must be at least 2 characters';

  @override
  String get validationDisplayNameTooLong =>
      'Display name must be less than 50 characters';

  @override
  String validationFieldRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String validationFieldTooShort(int min) {
    return 'Must be at least $min characters';
  }

  @override
  String validationFieldTooLong(int max) {
    return 'Cannot exceed $max characters';
  }

  @override
  String get validationFieldRequired2 => 'This field is required';

  @override
  String get homeTitle => 'Home';

  @override
  String homeGreeting(String name) {
    return 'Hello $name';
  }

  @override
  String get homeSubtitle => 'Capture your dream in under a minute.';

  @override
  String get homeCreateDream => 'Create new dream';

  @override
  String get homeListDreams => 'List dreams';

  @override
  String get homeProfile => 'Profile';

  @override
  String get dreamsListTitle => 'Dreams';

  @override
  String get dreamsListEmpty => 'No dreams yet.';

  @override
  String get dreamsListCreateFirst => 'Create your first dream';

  @override
  String get dreamsListRetry => 'Retry';

  @override
  String dreamsListMoodLabel(String score) {
    return 'Mood $score';
  }

  @override
  String get dreamsListMoodNoScore => 'Mood -';

  @override
  String get dreamsListTooltipCreate => 'Create new dream';

  @override
  String get dreamsListNotLoggedIn => 'You must be logged in to view dreams.';

  @override
  String get dreamFormNewTitle => 'New dream';

  @override
  String get dreamFormEditTitle => 'Edit dream';

  @override
  String get dreamFormFieldTitle => 'Dream title';

  @override
  String get dreamFormFieldText => 'Dream text';

  @override
  String get dreamFormFieldMood => 'Mood score (1-5)';

  @override
  String get dreamFormFieldContextNotes => 'Context notes';

  @override
  String get dreamFormFieldAiCategory => 'AI category';

  @override
  String get dreamFormValidationMoodRequired => 'Mood score is required';

  @override
  String get dreamFormValidationMoodRange =>
      'Mood score must be between 1 and 5';

  @override
  String get dreamFormSaveButton => 'Save changes';

  @override
  String get dreamFormCreateButton => 'Create dream';

  @override
  String get dreamFormNotLoggedIn => 'You must be logged in to save a dream.';

  @override
  String get dreamDetailTitle => 'Dream details';

  @override
  String get dreamDetailMoodScore => 'Mood score';

  @override
  String get dreamDetailMoodTooltip =>
      'Your mood when you woke up,\nfrom 1 (very bad) to 5 (excellent).';

  @override
  String get dreamDetailContextNotes => 'Context notes';

  @override
  String get dreamDetailAiCategory => 'AI category';

  @override
  String get dreamDetailAiCategoryPending => 'Pending AI categorization';

  @override
  String get dreamDetailEditButton => 'Edit';

  @override
  String get dreamDetailDeleteButton => 'Delete';

  @override
  String get dreamDetailDeleteDialogTitle => 'Delete dream';

  @override
  String get dreamDetailDeleteDialogContent => 'This action cannot be undone.';

  @override
  String get dreamDetailDeleteCancel => 'Cancel';

  @override
  String get dreamDetailDeleteConfirm => 'Delete';

  @override
  String get profileTitle => 'Profile';

  @override
  String profileEmail(String email) {
    return 'Email: $email';
  }

  @override
  String get profileNotificationsEnabled => 'Notifications enabled';

  @override
  String get profileNotificationTime => 'Notification time';

  @override
  String get profileSaveButton => 'Save profile';

  @override
  String get profileSaveSuccess => 'Profile updated';

  @override
  String get profileLogoutButton => 'Logout';

  @override
  String get profileIncomplete =>
      'Your profile is not complete. Save to finish setup.';

  @override
  String get profileLoadError =>
      'Could not load profile. Try logging out and back in.';

  @override
  String get profileSaveError => 'Could not update profile.';

  @override
  String get profileLogoutError => 'Error logging out. Please try again.';

  @override
  String profileFirestoreError(String message) {
    return 'Error saving profile: $message';
  }

  @override
  String get profileLanguage => 'Language';

  @override
  String get audioRecorderTitle => 'Voice recording';

  @override
  String get audioRecorderStart => 'Start recording';

  @override
  String get audioRecorderStop => 'Stop recording';

  @override
  String get audioRecorderDelete => 'Delete';

  @override
  String get audioRecorderRecording => 'Recording';

  @override
  String get audioRecorderDone => 'Audio recorded';

  @override
  String get audioRecorderPermissionDenied => 'Microphone permission denied';

  @override
  String get audioPlayerTitle => 'Voice recording';

  @override
  String get audioPlayerError => 'Error loading audio';

  @override
  String get dreamFormAudioSection => 'Voice recording (optional)';

  @override
  String get dreamFormAnalyzeButton => 'Analyze with AI';

  @override
  String get dreamFormAnalyzing => 'Analyzing dream...';

  @override
  String get dreamFormAnalysisSuccess => 'AI analysis complete';

  @override
  String get dreamFormAnalysisError => 'AI analysis failed';

  @override
  String get dreamDetailAudioSection => 'Voice recording';

  @override
  String get dreamDetailTranscription => 'Transcription';

  @override
  String get dreamDetailAiAnalysis => 'AI Analysis';

  @override
  String get dreamDetailAiSentiment => 'Sentiment';

  @override
  String get dreamDetailAiEmotions => 'Emotions';

  @override
  String get dreamDetailAiCharacters => 'Characters';

  @override
  String get dreamDetailAiPlaces => 'Places';

  @override
  String get dreamDetailAiThemes => 'Themes';

  @override
  String get dreamDetailAiPsychNote => 'Psychological note';

  @override
  String get dreamDetailAiSummary => 'Summary';

  @override
  String get dreamDetailAnalyzeButton => 'Run AI analysis';

  @override
  String get dreamDetailAnalyzing => 'Analyzing...';

  @override
  String get dreamDetailAnalysisNoKey =>
      'Add a Gemini API key in your profile to enable AI analysis.';

  @override
  String get profileGeminiApiKey => 'Gemini API key';

  @override
  String get profileGeminiApiKeyHint => 'Paste your Google AI Studio key here';

  @override
  String get profileGeminiApiKeySaved => 'Gemini API key saved';

  @override
  String get profileGeminiApiKeyCleared => 'Gemini API key removed';

  @override
  String get profileAiEnabled => 'AI analysis enabled';

  @override
  String get profileAiEnabledHint =>
      'Enable Gemini AI analysis for your dreams';

  @override
  String get homeDashboard => 'Dashboard';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardTotalDreams => 'Total dreams';

  @override
  String get dashboardThisMonth => 'This month';

  @override
  String get dashboardAvgMood => 'Avg. mood';

  @override
  String get dashboardAiAnalyzed => 'AI analyzed';

  @override
  String get dashboardMoodEvolution => 'Mood evolution';

  @override
  String get dashboardDreamsPerWeek => 'Dreams per week';

  @override
  String get dashboardTopCategories => 'Top AI categories';

  @override
  String get dashboardTopTags => 'Most used tags';

  @override
  String get dashboardNoData => 'No dreams yet. Start recording your dreams!';

  @override
  String get dashboardNoDreamsThisMonth => 'None this month';
}
