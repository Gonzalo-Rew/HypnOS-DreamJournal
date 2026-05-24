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
  String get validationDisplayNameInvalidChars =>
      'Display name contains unsupported characters';

  @override
  String get validationDisplayNameTaken =>
      'This name is already taken, please choose another';

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
  String get homeTodayLabel => 'Today';

  @override
  String get homeNoDreamsToday => 'No dreams registered today';

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
    return 'Intensity $score';
  }

  @override
  String get dreamsListMoodNoScore => 'Intensity -';

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
  String get dreamFormFieldMood => 'Emotional intensity (1-5)';

  @override
  String get dreamFormFieldContextNotes => 'Context notes';

  @override
  String get dreamFormFieldAiCategory => 'AI category';

  @override
  String get dreamFormValidationMoodRequired =>
      'Emotional intensity is required';

  @override
  String get dreamFormValidationMoodRange =>
      'Emotional intensity must be between 1 and 5';

  @override
  String get dreamFormSaveButton => 'Save changes';

  @override
  String get dreamFormCreateButton => 'Create dream';

  @override
  String get dreamFormNotLoggedIn => 'You must be logged in to save a dream.';

  @override
  String get dreamDetailTitle => 'Dream details';

  @override
  String get dreamDetailMoodScore => 'Emotional intensity';

  @override
  String get dreamDetailMoodTooltip =>
      'Your emotional intensity when waking up:\n1 Calm, 2 Mild, 3 Moderate, 4 Intense, 5 Extreme.';

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
  String get dashboardAvgMood => 'Avg. intensity';

  @override
  String get dashboardAiAnalyzed => 'AI analyzed';

  @override
  String get dashboardMoodEvolution => 'Intensity evolution';

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

  @override
  String get welcomeMorpheusTitle => 'Morpheus';

  @override
  String get welcomeMorpheusSubtitle => 'Your personal dream journal';

  @override
  String get welcomeBeginJourney => 'Begin your journey';

  @override
  String get welcomeAlreadyHaveAccount => 'Already have an account?';

  @override
  String get welcomeLogIn => 'Log in';

  @override
  String get welcomeTagline => 'Explore the depths of your dreams';

  @override
  String get loginPortalTitle => 'Enter the Dream Portal';

  @override
  String get loginPortalSubtitle => 'Sign in to access your dream journal';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get registerPortalTitle => 'Create your Dream Portal';

  @override
  String get registerPortalSubtitle =>
      'Start your journey into your subconscious';

  @override
  String get registerDreamerNameHint => 'Your dreamer name';

  @override
  String get registerEmailHint => 'Your email address';

  @override
  String get registerCreateAccount => 'Create account';

  @override
  String get registerOrSecureAccess => 'Or continue with';

  @override
  String get registerContinueApple => 'Continue with Apple';

  @override
  String get registerContinueGoogle => 'Continue with Google';

  @override
  String get registerTermsPrefix => 'By registering you agree to our';

  @override
  String get registerTermsLink => 'Terms & Conditions';

  @override
  String get registerTermsSuffix => '.';

  @override
  String get authErrorEmailInUse => 'This email is already registered';

  @override
  String get authErrorInvalidEmail => 'The email address is not valid';

  @override
  String get authErrorWeakPassword => 'The password is too weak';

  @override
  String get authErrorWrongPassword => 'The password is incorrect';

  @override
  String get authErrorUserNotFound => 'No account found with that email';

  @override
  String get authErrorUserDisabled => 'This account has been disabled';

  @override
  String get authErrorTooManyRequests =>
      'Too many failed attempts. Please try again later';

  @override
  String get authErrorNetworkFailed =>
      'Network error. Please check your internet connection';

  @override
  String get authErrorOperationNotAllowed =>
      'This sign-in method is not available';

  @override
  String get authErrorGoogleFailed =>
      'Could not sign in with Google. Please try again';

  @override
  String get authErrorAppleFailed =>
      'Could not sign in with Apple. Please try again';

  @override
  String get authErrorAppleNotSupported =>
      'Apple sign in is not available on this device';

  @override
  String get authErrorAppleNotInteractive =>
      'Apple sign in requires user interaction';

  @override
  String get authErrorGeneric => 'An error occurred. Please try again';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAccount => 'PROFILE & ACCOUNT';

  @override
  String get settingsEditProfile => 'Edit profile';

  @override
  String get settingsAccountSecurity => 'Account & security';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsSectionPreferences => 'PREFERENCES';

  @override
  String get settingsSectionAi => 'ARTIFICIAL INTELLIGENCE';

  @override
  String get settingsAiTitle => 'Morpheus - AI Analysis';

  @override
  String get settingsAiSubtitle => 'Active';

  @override
  String get settingsSectionLegal => 'LEGAL';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsTermsAndConditions => 'Terms and conditions';

  @override
  String get dreamsListFilterByDate => 'Filter by date';

  @override
  String dreamsListResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count dream$_temp0 found';
  }

  @override
  String get dreamsListNoDreamsInRange => 'No dreams in this date range';

  @override
  String get dreamsListClearFilter => 'Clear filter';

  @override
  String get dreamsListMoodUnrated => 'Unrated';

  @override
  String get dreamsListMoodPositive => 'Positive';

  @override
  String get dreamsListMoodNeutral => 'Neutral';

  @override
  String get dreamsListMoodIntense => 'Intense';

  @override
  String get dreamsListUntitled => 'Untitled';

  @override
  String get dreamFormNeedTextOrAudio =>
      'Add a description or an audio recording.';

  @override
  String dreamFormDescriptionMin(int min) {
    return 'Description must be at least $min characters for useful analysis.';
  }

  @override
  String dreamFormAudioLimit(int max) {
    return 'You can attach up to $max recordings.';
  }

  @override
  String get dreamFormDateSection => 'DATE';

  @override
  String get dreamFormTitleSection => 'TITLE';

  @override
  String get dreamFormTitleHint => 'The neon forest...';

  @override
  String get dreamFormTellItSection => 'TELL IT';

  @override
  String get dreamFormDescriptionHint => 'Write what you remember...';

  @override
  String get dreamFormIntensitySection => 'EMOTIONAL INTENSITY';

  @override
  String get dreamFormNextButton => 'Next ->';

  @override
  String get dreamFormPrivateSaveHint => 'Your dream will be saved privately';

  @override
  String get dreamFormVoiceRecordingsSection => 'Voice recordings';

  @override
  String dreamFormAudioLimitReached(int max) {
    return 'Limit reached (max. $max)';
  }

  @override
  String get dreamFormRecordAudio => 'Record audio';

  @override
  String get dreamFormIntensityCalm => 'Calm';

  @override
  String get dreamFormIntensityMild => 'Mild';

  @override
  String get dreamFormIntensityModerate => 'Moderate';

  @override
  String get dreamFormIntensityIntense => 'Intense';

  @override
  String get dreamFormIntensityExtreme => 'Extreme';

  @override
  String get dreamFormContextTags => 'Context tags';

  @override
  String get dreamFormContextTagsHint =>
      'Morpheus will generate them automatically after saving';

  @override
  String get dashboardNotLoggedIn =>
      'Session not started. Please sign in again.';

  @override
  String get dashboardInsightAnalyzing => 'Morpheus is analyzing your dreams.';

  @override
  String get dashboardInsightNeedMood =>
      'Record emotional intensity in your dreams to get correlations.';

  @override
  String get dashboardInsightTrendUp =>
      'Your emotional state in dreams has improved this week. Morpheus detects a positive trend.';

  @override
  String get dashboardInsightTrendDown =>
      'Your recent dreams show higher emotional intensity. Consider reviewing your sleep habits.';

  @override
  String get dashboardInsightPositive =>
      'Your dreams consistently reflect a positive emotional state.';

  @override
  String get dashboardInsightNeutral =>
      'Neutral emotional state in your dreams. Morpheus does not detect alert patterns.';

  @override
  String get dashboardInsightTense =>
      'Morpheus detects recurring emotional tension. Consider relaxation routines before sleep.';

  @override
  String get dashboardDayMon => 'Mon';

  @override
  String get dashboardDayTue => 'Tue';

  @override
  String get dashboardDayWed => 'Wed';

  @override
  String get dashboardDayThu => 'Thu';

  @override
  String get dashboardDayFri => 'Fri';

  @override
  String get dashboardDaySat => 'Sat';

  @override
  String get dashboardDaySun => 'Sun';

  @override
  String get dashboardMoodTone7d => 'EMOTIONAL TONE (7 DAYS)';

  @override
  String get dashboardRecurringElements => 'RECURRING ELEMENTS';

  @override
  String get dashboardCorrelationNeedMore =>
      'You need more records to detect correlations. Keep adding dreams every day.';

  @override
  String get dashboardCorrelationNeedMood =>
      'Rate your dream emotional intensity to enable correlation analysis.';

  @override
  String get dashboardCorrelationHigh =>
      'Your intense dreams match days with high energy and positive activity.';

  @override
  String get dashboardCorrelationStable =>
      'Morpheus detects emotional stability. Your dreams reflect your daily rhythm.';

  @override
  String get dashboardCorrelationStress =>
      'Your intense dreams match days of high activity or stress. Consider nighttime relaxation routines.';

  @override
  String get dashboardCorrelationTitle => 'CORRELATION';

  @override
  String get editProfileAvatarUpdated => 'Avatar updated';

  @override
  String get editProfileAvatarRemoved => 'Avatar removed';

  @override
  String get editProfileAvatarRemoveError => 'Error removing avatar';

  @override
  String get editProfileAvatarUploadError => 'Error uploading avatar';

  @override
  String get editProfileNameValidationError => 'Could not validate name';

  @override
  String get editProfileUpdateFailed => 'Profile update failed';

  @override
  String get editProfileChangeAvatar => 'Change avatar';

  @override
  String get editProfileRemoveAvatar => 'Remove avatar';

  @override
  String get editProfileUsername => 'Username';

  @override
  String get profilePublishedDreams => 'Published dreams';

  @override
  String get profileNoPublishedDreams =>
      'You have not published any dreams yet';

  @override
  String get profileFollowers => 'Followers';

  @override
  String get profileFollowing => 'Following';

  @override
  String get dreamAnalysisTitle => 'Analyze dream';

  @override
  String get dreamAnalysisUploadingRecordings => 'Uploading recordings...';

  @override
  String get dreamAnalysisAudioUploadFailedTitle => 'Audio upload failed';

  @override
  String get dreamAnalysisAudioUploadFailedMessage =>
      'We couldn\'t upload your recordings. Check your connection and try again before saving.';

  @override
  String get dreamAnalysisMissingContentTitle => 'Missing content';

  @override
  String get dreamAnalysisMissingContentMessage =>
      'To save without analysis you need a title and at least valid text or audio. Record again or add a description.';

  @override
  String get dreamAnalysisMorfeoListening => 'Morpheus is listening...';

  @override
  String get dreamAnalysisMorfeoTranscriptionFailedTitle =>
      'Morpheus could not transcribe';

  @override
  String get dreamAnalysisMorfeoTranscriptionFailedMessage =>
      'There was a problem processing your recordings. This can happen when audio is unclear or too short. Try recording again with more detail or use \"Save without analysis\".';

  @override
  String get dreamAnalysisMorfeoTranscriptionReadFailedMessage =>
      'The recorded audio could not be read correctly. This can happen when audio is unclear or too short. Try recording again with more detail or use \"Save without analysis\".';

  @override
  String get dreamAnalysisInsufficientInfoTitle => 'Insufficient information';

  @override
  String get dreamAnalysisInsufficientInfoMessage =>
      'Your audio transcription is too short for Morpheus to analyze the dream well. This can happen when audio is unclear or too short. Try recording again with more detail or use \"Save without analysis\".';

  @override
  String get dreamAnalysisMorfeoInterpreting =>
      'Morpheus is interpreting your dream...';

  @override
  String get dreamAnalysisMorfeoAnalyzeFailedTitle =>
      'Morpheus could not analyze';

  @override
  String get dreamAnalysisMorfeoAnalyzeFailedMessage =>
      'The analysis couldn\'t be completed right now. This can happen when audio is unclear or too short. Try recording again with more detail or use \"Save without analysis\".';

  @override
  String get dreamAnalysisMorfeoAnalyzeUnexpectedMessage =>
      'An unexpected error occurred while analyzing the dream. This can happen when audio is unclear or too short. Try recording again with more detail or use \"Save without analysis\".';

  @override
  String get dreamAnalysisSavingToJournal => 'Saving to your journal...';

  @override
  String get dreamAnalysisSaveFailedTitle => 'Could not save dream';

  @override
  String get dreamAnalysisSaveFailedAudioMessage =>
      'Saving could not be completed. It may be due to an incomplete audio upload or a connection issue. Check your connection and try again.';

  @override
  String get dreamAnalysisSaveFailedConnectionMessage =>
      'Saving could not be completed due to a connection or permissions issue. Please try again.';

  @override
  String get dreamAnalysisSaveErrorRetry =>
      'Error saving dream. Please try again.';

  @override
  String get dreamAnalysisUnderstood => 'Understood';

  @override
  String get dreamAnalysisSomethingWentWrong => 'Something went wrong.';

  @override
  String get dreamAnalysisMorfeoSubtitle => 'AI dream interpreter';

  @override
  String get dreamAnalysisCardBodyWithAudio =>
      'I will transcribe your recordings and analyze key emotions, places, and themes from your dream.';

  @override
  String get dreamAnalysisCardBodyWithoutAudio =>
      'I will analyze key emotions, places, and themes from your dream and return a useful summary.';

  @override
  String get dreamAnalysisAnalyzeWithMorfeo => 'Analyze with Morpheus';

  @override
  String get dreamAnalysisSaveWithoutAnalysis => 'Save without analysis';

  @override
  String dreamAnalysisAudioRecordingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count recording$_temp0';
  }

  @override
  String get dreamSavedMorfeoAnalyzeFailedTitle =>
      'Morpheus could not analyze the dream';

  @override
  String dreamSavedShareWithBody(String title, String body) {
    return '✨ \"$title\"\n\n$body\n\n— Saved in Hypnos Dream Journal';
  }

  @override
  String dreamSavedShareWithoutBody(String title) {
    return '✨ \"$title\"\n\n— Saved in Hypnos Dream Journal';
  }

  @override
  String get dreamSavedTitle => 'Dream saved!';

  @override
  String get dreamSavedPublishDream => 'Publish dream';

  @override
  String get dreamSavedVisibleOnlyYou => 'Visible only to you';

  @override
  String get dreamSavedShareSection => 'SHARE';

  @override
  String get dreamSavedShareWhatsapp => 'WhatsApp';

  @override
  String get dreamSavedShareMore => 'More';

  @override
  String get dreamSavedGoToJournal => 'Go to journal';

  @override
  String get dreamSavedVisibleForEveryone => 'Visible to everyone';

  @override
  String get dreamSavedVisibleForFollowers => 'Visible to followers';

  @override
  String get dreamSavedMorfeoInterpretation => 'MORPHEUS INTERPRETATION';

  @override
  String get dreamMorfeoResultTitle => 'Morpheus result';

  @override
  String get dreamMorfeoResultSubtitle =>
      'Review the full analysis before deciding how to publish your dream.';

  @override
  String get dreamMorfeoResultContinue => 'Continue to publishing';

  @override
  String get dreamMorfeoResultEmpty =>
      'Morpheus did not return enough analysis details for this dream.';

  @override
  String get dreamMorfeoResultEmptyField => 'No data';

  @override
  String get accountSecurityBiometricDialogTitle => 'Enable biometric unlock';

  @override
  String get accountSecurityBiometricDialogMessage =>
      'Enter your password to save this access on this device.';

  @override
  String get accountSecurityCurrentPasswordLabel => 'Current password';

  @override
  String get accountSecurityActivate => 'Enable';

  @override
  String get accountSecurityBiometricDisabled => 'Biometric unlock disabled';

  @override
  String get accountSecurityBiometricPasswordOnly =>
      'Can only be enabled for email/password accounts';

  @override
  String get accountSecurityBiometricEnabled => 'Biometric unlock enabled';

  @override
  String get accountSecurityBiometricEnableFailed =>
      'Could not enable biometrics';

  @override
  String get accountSecurityVisibilityEveryone => 'Everyone';

  @override
  String get accountSecurityVisibilityFollowers => 'Followers only';

  @override
  String get accountSecurityVisibilityPrivate => 'Private';

  @override
  String get accountSecurityResetPasswordTitle => 'Reset password';

  @override
  String accountSecurityResetPasswordMessage(String email) {
    return 'We\'ll send a link to $email.';
  }

  @override
  String get accountSecurityResetPasswordSendLink => 'Send link';

  @override
  String get accountSecurityResetPasswordSendError => 'Failed to send link';

  @override
  String get accountSecurityEmailSentTitle => 'Email sent!';

  @override
  String get accountSecurityEmailSentPrefix => 'We\'ve sent a reset link to ';

  @override
  String get accountSecurityEmailSentSuffix =>
      '\n\nAlso check your spam folder.';

  @override
  String get accountSecurityVisibilityUpdated => 'Visibility updated';

  @override
  String get accountSecurityLogoutConfirmMessage =>
      'Are you sure you want to log out?';

  @override
  String get accountSecurityDeleteWrongPassword => 'Password is incorrect';

  @override
  String get accountSecurityDeleteRequiresRecentLogin =>
      'For security, log in again and retry';

  @override
  String get accountSecurityDeleteReauthUnavailable =>
      'This account does not use a password. Sign in with your provider and retry';

  @override
  String get accountSecurityDeleteGenericError =>
      'Could not delete account. Please try again';

  @override
  String get accountSecurityDeleteTitle => 'Delete account';

  @override
  String get accountSecurityDeleteDialogMessage =>
      'This action is permanent. Enter your password to confirm.';

  @override
  String get accountSecurityDeletePermanently => 'Delete permanently';

  @override
  String get accountSecurityCredentialsSection => 'CREDENTIALS';

  @override
  String get accountSecurityNoData => '—';

  @override
  String get accountSecurityChangePassword => 'Change password';

  @override
  String get accountSecurityPrivacySection => 'PRIVACY';

  @override
  String get accountSecurityBiometricTitle => 'Biometric unlock';

  @override
  String get accountSecurityBiometricSupported =>
      'Use your fingerprint to sign in on this device.';

  @override
  String get accountSecurityBiometricUnsupported =>
      'This device does not support biometrics.';

  @override
  String get accountSecurityDreamVisibility => 'Dream visibility';

  @override
  String get accountSecurityAccountActionsSection => 'ACCOUNT ACTIONS';

  @override
  String get accountSecurityPermanentActionsHint =>
      'These actions are permanent and cannot be undone.';

  @override
  String get accountSecurityVisibilityEveryoneSubtitle =>
      'Your dreams are publicly available.';

  @override
  String get accountSecurityVisibilityFollowersSubtitle =>
      'Only people who follow you can see your dreams.';

  @override
  String get accountSecurityVisibilityPrivateSubtitle =>
      'No one can see your dreams.';

  @override
  String get socialFollowRequestsNotLoggedIn => 'Session not started';

  @override
  String get socialFollowRequestsTitle => 'Follow requests';

  @override
  String get socialFollowRequestsLoadError =>
      'Could not load requests. Please try again.';

  @override
  String get socialFollowRequestsEmpty => 'No pending requests';

  @override
  String get socialFollowRequestsAccept => 'Accept';

  @override
  String get socialFollowRequestsDecline => 'Decline';
}
