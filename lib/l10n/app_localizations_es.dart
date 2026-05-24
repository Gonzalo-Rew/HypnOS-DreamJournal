// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Hypnos Dream Journal';

  @override
  String get language => 'Idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginCreateAccount => 'Crear cuenta';

  @override
  String get registerTitle => 'Crea tu cuenta';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get registerSuccessMessage =>
      'Cuenta creada correctamente. Por favor, inicia sesión.';

  @override
  String get fieldEmail => 'Correo electrónico';

  @override
  String get fieldPassword => 'Contraseña';

  @override
  String get fieldConfirmPassword => 'Confirmar contraseña';

  @override
  String get fieldDisplayName => 'Nombre';

  @override
  String get validationEmailRequired => 'El correo electrónico es obligatorio';

  @override
  String get validationEmailInvalid => 'Introduce un correo electrónico válido';

  @override
  String get validationPasswordRequired => 'La contraseña es obligatoria';

  @override
  String get validationPasswordTooShort =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get validationPasswordNoUppercase =>
      'La contraseña debe contener al menos una letra mayúscula';

  @override
  String get validationPasswordNoLowercase =>
      'La contraseña debe contener al menos una letra minúscula';

  @override
  String get validationPasswordNoDigit =>
      'La contraseña debe contener al menos un número';

  @override
  String get validationConfirmPasswordRequired => 'Confirma tu contraseña';

  @override
  String get validationPasswordsMismatch => 'Las contraseñas no coinciden';

  @override
  String get validationDisplayNameRequired => 'El nombre es obligatorio';

  @override
  String get validationDisplayNameTooShort =>
      'El nombre debe tener al menos 2 caracteres';

  @override
  String get validationDisplayNameTooLong =>
      'El nombre no puede superar los 50 caracteres';

  @override
  String get validationDisplayNameInvalidChars =>
      'El nombre contiene caracteres no permitidos';

  @override
  String get validationDisplayNameTaken =>
      'Este nombre ya está en uso, elige otro';

  @override
  String validationFieldRequired(String fieldName) {
    return '$fieldName es obligatorio';
  }

  @override
  String validationFieldTooShort(int min) {
    return 'Debe tener al menos $min caracteres';
  }

  @override
  String validationFieldTooLong(int max) {
    return 'No puede superar los $max caracteres';
  }

  @override
  String get validationFieldRequired2 => 'Este campo es obligatorio';

  @override
  String get homeTitle => 'Inicio';

  @override
  String homeGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get homeSubtitle => 'Captura tu sueño en menos de un minuto.';

  @override
  String get homeCreateDream => 'Nuevo sueño';

  @override
  String get homeListDreams => 'Ver sueños';

  @override
  String get homeProfile => 'Perfil';

  @override
  String get homeTodayLabel => 'Hoy';

  @override
  String get homeNoDreamsToday => 'No hay ningún sueño registrado hoy';

  @override
  String get dreamsListTitle => 'Sueños';

  @override
  String get dreamsListEmpty => 'Todavía no hay sueños.';

  @override
  String get dreamsListCreateFirst => 'Crea tu primer sueño';

  @override
  String get dreamsListRetry => 'Reintentar';

  @override
  String dreamsListMoodLabel(String score) {
    return 'Intensidad $score';
  }

  @override
  String get dreamsListMoodNoScore => 'Intensidad -';

  @override
  String get dreamsListTooltipCreate => 'Nuevo sueño';

  @override
  String get dreamsListNotLoggedIn =>
      'Debes estar autenticado para ver tus sueños.';

  @override
  String get dreamFormNewTitle => 'Nuevo sueño';

  @override
  String get dreamFormEditTitle => 'Editar sueño';

  @override
  String get dreamFormFieldTitle => 'Título del sueño';

  @override
  String get dreamFormFieldText => 'Descripción del sueño';

  @override
  String get dreamFormFieldMood => 'Intensidad emocional (1-5)';

  @override
  String get dreamFormFieldContextNotes => 'Notas de contexto';

  @override
  String get dreamFormFieldAiCategory => 'Categoría IA';

  @override
  String get dreamFormValidationMoodRequired =>
      'La intensidad emocional es obligatoria';

  @override
  String get dreamFormValidationMoodRange =>
      'La intensidad emocional debe estar entre 1 y 5';

  @override
  String get dreamFormSaveButton => 'Guardar cambios';

  @override
  String get dreamFormCreateButton => 'Crear sueño';

  @override
  String get dreamFormNotLoggedIn =>
      'Debes estar autenticado para guardar un sueño.';

  @override
  String get dreamDetailTitle => 'Detalle del sueño';

  @override
  String get dreamDetailMoodScore => 'Intensidad emocional';

  @override
  String get dreamDetailMoodTooltip =>
      'Tu intensidad emocional al despertar:\n1 Tranquilo, 2 Leve, 3 Moderado, 4 Intenso, 5 Extremo.';

  @override
  String get dreamDetailContextNotes => 'Notas de contexto';

  @override
  String get dreamDetailAiCategory => 'Categoría IA';

  @override
  String get dreamDetailAiCategoryPending => 'Pendiente de categorización IA';

  @override
  String get dreamDetailEditButton => 'Editar';

  @override
  String get dreamDetailDeleteButton => 'Eliminar';

  @override
  String get dreamDetailDeleteDialogTitle => 'Eliminar sueño';

  @override
  String get dreamDetailDeleteDialogContent =>
      'Esta acción no se puede deshacer.';

  @override
  String get dreamDetailDeleteCancel => 'Cancelar';

  @override
  String get dreamDetailDeleteConfirm => 'Eliminar';

  @override
  String get profileTitle => 'Perfil';

  @override
  String profileEmail(String email) {
    return 'Correo: $email';
  }

  @override
  String get profileNotificationsEnabled => 'Notificaciones activadas';

  @override
  String get profileNotificationTime => 'Hora de notificación';

  @override
  String get profileSaveButton => 'Guardar perfil';

  @override
  String get profileSaveSuccess => 'Perfil actualizado';

  @override
  String get profileLogoutButton => 'Cerrar sesión';

  @override
  String get profileIncomplete =>
      'Tu perfil aún no está completo. Guarda para finalizar la configuración.';

  @override
  String get profileLoadError =>
      'No se pudo cargar el perfil. Intenta cerrar sesión y volver a entrar.';

  @override
  String get profileSaveError => 'No se pudo actualizar el perfil.';

  @override
  String get profileLogoutError =>
      'Error al cerrar sesión. Inténtalo de nuevo.';

  @override
  String profileFirestoreError(String message) {
    return 'Error al guardar el perfil: $message';
  }

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get audioRecorderTitle => 'Grabación de voz';

  @override
  String get audioRecorderStart => 'Iniciar grabación';

  @override
  String get audioRecorderStop => 'Detener grabación';

  @override
  String get audioRecorderDelete => 'Eliminar';

  @override
  String get audioRecorderRecording => 'Grabando';

  @override
  String get audioRecorderDone => 'Audio grabado';

  @override
  String get audioRecorderPermissionDenied => 'Permiso de micrófono denegado';

  @override
  String get audioPlayerTitle => 'Grabación de voz';

  @override
  String get audioPlayerError => 'Error al cargar el audio';

  @override
  String get dreamFormAudioSection => 'Grabación de voz (opcional)';

  @override
  String get dreamFormAnalyzeButton => 'Analizar con IA';

  @override
  String get dreamFormAnalyzing => 'Analizando sueño...';

  @override
  String get dreamFormAnalysisSuccess => 'Análisis IA completado';

  @override
  String get dreamFormAnalysisError => 'El análisis IA falló';

  @override
  String get dreamDetailAudioSection => 'Grabación de voz';

  @override
  String get dreamDetailTranscription => 'Transcripción';

  @override
  String get dreamDetailAiAnalysis => 'Análisis IA';

  @override
  String get dreamDetailAiSentiment => 'Sentimiento';

  @override
  String get dreamDetailAiEmotions => 'Emociones';

  @override
  String get dreamDetailAiCharacters => 'Personajes';

  @override
  String get dreamDetailAiPlaces => 'Lugares';

  @override
  String get dreamDetailAiThemes => 'Temas';

  @override
  String get dreamDetailAiPsychNote => 'Nota psicológica';

  @override
  String get dreamDetailAiSummary => 'Resumen';

  @override
  String get dreamDetailAnalyzeButton => 'Ejecutar análisis IA';

  @override
  String get dreamDetailAnalyzing => 'Analizando...';

  @override
  String get dreamDetailAnalysisNoKey =>
      'Añade una clave de API de Gemini en tu perfil para activar el análisis IA.';

  @override
  String get profileGeminiApiKey => 'Clave API de Gemini';

  @override
  String get profileGeminiApiKeyHint =>
      'Pega aquí tu clave de Google AI Studio';

  @override
  String get profileGeminiApiKeySaved => 'Clave API de Gemini guardada';

  @override
  String get profileGeminiApiKeyCleared => 'Clave API de Gemini eliminada';

  @override
  String get profileAiEnabled => 'Análisis IA activado';

  @override
  String get profileAiEnabledHint =>
      'Activa el análisis con Gemini IA para tus sueños';

  @override
  String get homeDashboard => 'Dashboard';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardTotalDreams => 'Total sueños';

  @override
  String get dashboardThisMonth => 'Este mes';

  @override
  String get dashboardAvgMood => 'Intensidad prom.';

  @override
  String get dashboardAiAnalyzed => 'Analizados IA';

  @override
  String get dashboardMoodEvolution => 'Evolución de intensidad';

  @override
  String get dashboardDreamsPerWeek => 'Sueños por semana';

  @override
  String get dashboardTopCategories => 'Categorías IA más frecuentes';

  @override
  String get dashboardTopTags => 'Etiquetas más usadas';

  @override
  String get dashboardNoData => 'Todavía no hay sueños. ¡Empieza a registrar!';

  @override
  String get dashboardNoDreamsThisMonth => 'Ninguno este mes';

  @override
  String get welcomeMorpheusTitle => 'Morfeo';

  @override
  String get welcomeMorpheusSubtitle => 'Tu diario de sueños personal';

  @override
  String get welcomeBeginJourney => 'Comienza tu viaje';

  @override
  String get welcomeAlreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get welcomeLogIn => 'Iniciar sesión';

  @override
  String get welcomeTagline => 'Explora las profundidades de tus sueños';

  @override
  String get loginPortalTitle => 'Entra al Portal Onírico';

  @override
  String get loginPortalSubtitle =>
      'Inicia sesión para acceder a tu diario de sueños';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginSignIn => 'Iniciar sesión';

  @override
  String get loginNoAccount => '¿No tienes cuenta?';

  @override
  String get registerPortalTitle => 'Crea tu Portal Onírico';

  @override
  String get registerPortalSubtitle => 'Comienza tu viaje a tu subconsciente';

  @override
  String get registerDreamerNameHint => 'Tu nombre de soñador';

  @override
  String get registerEmailHint => 'Tu dirección de correo';

  @override
  String get registerCreateAccount => 'Crear cuenta';

  @override
  String get registerOrSecureAccess => 'O continúa con';

  @override
  String get registerContinueApple => 'Continuar con Apple';

  @override
  String get registerContinueGoogle => 'Continuar con Google';

  @override
  String get registerTermsPrefix => 'Al registrarte aceptas nuestros';

  @override
  String get registerTermsLink => 'Términos y Condiciones';

  @override
  String get registerTermsSuffix => '.';

  @override
  String get authErrorEmailInUse => 'Este correo ya está registrado';

  @override
  String get authErrorInvalidEmail => 'El correo electrónico no es válido';

  @override
  String get authErrorWeakPassword => 'La contraseña es demasiado débil';

  @override
  String get authErrorWrongPassword => 'La contraseña no es correcta';

  @override
  String get authErrorUserNotFound => 'No existe ninguna cuenta con ese correo';

  @override
  String get authErrorUserDisabled => 'Esta cuenta ha sido desactivada';

  @override
  String get authErrorTooManyRequests =>
      'Demasiados intentos fallidos. Inténtalo más tarde';

  @override
  String get authErrorNetworkFailed =>
      'Error de red. Comprueba tu conexión a internet';

  @override
  String get authErrorOperationNotAllowed =>
      'Este método de inicio de sesión no está disponible';

  @override
  String get authErrorGoogleFailed =>
      'No se pudo iniciar sesión con Google. Inténtalo de nuevo';

  @override
  String get authErrorAppleFailed =>
      'No se pudo iniciar sesión con Apple. Inténtalo de nuevo';

  @override
  String get authErrorAppleNotSupported =>
      'Inicio de sesión con Apple no disponible en este dispositivo';

  @override
  String get authErrorAppleNotInteractive =>
      'El inicio de sesión con Apple requiere interacción del usuario';

  @override
  String get authErrorGeneric => 'Ha ocurrido un error. Inténtalo de nuevo';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionAccount => 'PERFIL Y CUENTA';

  @override
  String get settingsEditProfile => 'Editar perfil';

  @override
  String get settingsAccountSecurity => 'Cuenta y seguridad';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsSectionPreferences => 'PREFERENCIAS';

  @override
  String get settingsSectionAi => 'INTELIGENCIA ARTIFICIAL';

  @override
  String get settingsAiTitle => 'Morfeo - Análisis con IA';

  @override
  String get settingsAiSubtitle => 'Activo';

  @override
  String get settingsSectionLegal => 'LEGAL';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsTermsAndConditions => 'Términos y condiciones';

  @override
  String get dreamsListFilterByDate => 'Filtrar por fecha';

  @override
  String dreamsListResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count sueño$_temp0 encontrado$_temp1';
  }

  @override
  String get dreamsListNoDreamsInRange =>
      'No hay sueños en ese rango de fechas';

  @override
  String get dreamsListClearFilter => 'Quitar filtro';

  @override
  String get dreamsListMoodUnrated => 'Sin valorar';

  @override
  String get dreamsListMoodPositive => 'Leve';

  @override
  String get dreamsListMoodNeutral => 'Moderado';

  @override
  String get dreamsListMoodIntense => 'Intenso';

  @override
  String get dreamsListUntitled => 'Sin título';

  @override
  String get dreamFormNeedTextOrAudio =>
      'Añade una descripción o una grabación de audio.';

  @override
  String dreamFormDescriptionMin(int min) {
    return 'La descripción debe tener al menos $min caracteres para un análisis útil.';
  }

  @override
  String dreamFormAudioLimit(int max) {
    return 'Solo puedes adjuntar hasta $max grabaciones.';
  }

  @override
  String get dreamFormDateSection => 'FECHA';

  @override
  String get dreamFormTitleSection => 'TÍTULO';

  @override
  String get dreamFormTitleHint => 'El bosque de neón...';

  @override
  String get dreamFormTellItSection => 'CUÉNTALO';

  @override
  String get dreamFormDescriptionHint => 'Escribe lo que recuerdas...';

  @override
  String get dreamFormIntensitySection => 'INTENSIDAD EMOCIONAL';

  @override
  String get dreamFormNextButton => 'Siguiente ->';

  @override
  String get dreamFormPrivateSaveHint =>
      'Tu sueño se guardará de forma privada';

  @override
  String get dreamFormVoiceRecordingsSection => 'Grabaciones de voz';

  @override
  String dreamFormAudioLimitReached(int max) {
    return 'Límite alcanzado (máx. $max)';
  }

  @override
  String get dreamFormRecordAudio => 'Grabar audio';

  @override
  String get dreamFormIntensityCalm => 'Tranquilo';

  @override
  String get dreamFormIntensityMild => 'Leve';

  @override
  String get dreamFormIntensityModerate => 'Moderado';

  @override
  String get dreamFormIntensityIntense => 'Intenso';

  @override
  String get dreamFormIntensityExtreme => 'Extremo';

  @override
  String get dreamFormContextTags => 'Etiquetas de contexto';

  @override
  String get dreamFormContextTagsHint =>
      'Morfeo las generará automáticamente tras guardar';

  @override
  String get dashboardNotLoggedIn =>
      'Sesión no iniciada. Vuelve a iniciar sesión.';

  @override
  String get dashboardInsightAnalyzing => 'Morfeo está analizando tus sueños.';

  @override
  String get dashboardInsightNeedMood =>
      'Registra la intensidad emocional en tus sueños para obtener correlaciones.';

  @override
  String get dashboardInsightTrendUp =>
      'Tu estado emocional en sueños ha mejorado esta semana. Morfeo detecta una tendencia positiva.';

  @override
  String get dashboardInsightTrendDown =>
      'Tus sueños recientes muestran mayor intensidad emocional. Considera revisar tus hábitos de sueño.';

  @override
  String get dashboardInsightPositive =>
      'Tus sueños reflejan un estado emocional positivo de forma consistente.';

  @override
  String get dashboardInsightNeutral =>
      'Estado emocional neutro en tus sueños. Morfeo no detecta patrones de alerta.';

  @override
  String get dashboardInsightTense =>
      'Morfeo detecta tensión emocional recurrente. Considera técnicas de relajación antes de dormir.';

  @override
  String get dashboardDayMon => 'Lun';

  @override
  String get dashboardDayTue => 'Mar';

  @override
  String get dashboardDayWed => 'Mié';

  @override
  String get dashboardDayThu => 'Jue';

  @override
  String get dashboardDayFri => 'Vie';

  @override
  String get dashboardDaySat => 'Sáb';

  @override
  String get dashboardDaySun => 'Dom';

  @override
  String get dashboardMoodTone7d => 'TONO EMOCIONAL (7 DÍAS)';

  @override
  String get dashboardRecurringElements => 'ELEMENTOS RECURRENTES';

  @override
  String get dashboardCorrelationNeedMore =>
      'Necesitas más registros para detectar correlaciones. Sigue añadiendo sueños cada día.';

  @override
  String get dashboardCorrelationNeedMood =>
      'Valora la intensidad emocional de tus sueños para activar el análisis de correlación.';

  @override
  String get dashboardCorrelationHigh =>
      'Tus sueños intensos coinciden con días de alta energía y actividad positiva.';

  @override
  String get dashboardCorrelationStable =>
      'Morfeo detecta estabilidad emocional. Tus sueños reflejan tu ritmo diario.';

  @override
  String get dashboardCorrelationStress =>
      'Tus sueños intensos coinciden con días de alta actividad o estrés. Considera rutinas de relajación nocturna.';

  @override
  String get dashboardCorrelationTitle => 'CORRELACIÓN';

  @override
  String get editProfileAvatarUpdated => 'Avatar actualizado';

  @override
  String get editProfileAvatarRemoved => 'Avatar eliminado';

  @override
  String get editProfileAvatarRemoveError => 'Error al eliminar avatar';

  @override
  String get editProfileAvatarUploadError => 'Error al subir avatar';

  @override
  String get editProfileNameValidationError => 'No se pudo validar el nombre';

  @override
  String get editProfileUpdateFailed => 'Error al actualizar el perfil';

  @override
  String get editProfileChangeAvatar => 'Cambiar avatar';

  @override
  String get editProfileRemoveAvatar => 'Quitar avatar';

  @override
  String get editProfileUsername => 'Nombre de usuario';

  @override
  String get profilePublishedDreams => 'Sueños publicados';

  @override
  String get profileNoPublishedDreams =>
      'Todavía no has publicado ningún sueño';

  @override
  String get profileFollowers => 'Seguidores';

  @override
  String get profileFollowing => 'Siguiendo';

  @override
  String get dreamAnalysisTitle => 'Analizar sueño';

  @override
  String get dreamAnalysisUploadingRecordings => 'Subiendo grabaciones...';

  @override
  String get dreamAnalysisAudioUploadFailedTitle =>
      'No se pudieron subir los audios';

  @override
  String get dreamAnalysisAudioUploadFailedMessage =>
      'No hemos podido subir tus grabaciones. Revisa tu conexión e inténtalo de nuevo antes de guardar.';

  @override
  String get dreamAnalysisMissingContentTitle => 'Falta contenido para guardar';

  @override
  String get dreamAnalysisMissingContentMessage =>
      'Para guardar sin análisis necesitas un título y al menos texto o audio válido. Vuelve a grabar el audio o añade una descripción.';

  @override
  String get dreamAnalysisMorfeoListening => 'Morfeo está escuchando...';

  @override
  String get dreamAnalysisMorfeoTranscriptionFailedTitle =>
      'Morfeo no pudo transcribir';

  @override
  String get dreamAnalysisMorfeoTranscriptionFailedMessage =>
      'Hubo un problema al procesar tus grabaciones. Puede pasar si el audio no se escucha bien o si hay muy poca información. Prueba a grabar de nuevo con más detalle o usa \"Guardar sin análisis\".';

  @override
  String get dreamAnalysisMorfeoTranscriptionReadFailedMessage =>
      'No se pudo leer correctamente el audio grabado. Puede pasar si el audio no se escucha bien o si hay muy poca información. Prueba a grabar de nuevo con más detalle o usa \"Guardar sin análisis\".';

  @override
  String get dreamAnalysisInsufficientInfoTitle => 'Información insuficiente';

  @override
  String get dreamAnalysisInsufficientInfoMessage =>
      'La transcripción de tus audios es demasiado corta para que Morfeo pueda analizar bien el sueño. Puede pasar si el audio no se escucha bien o si hay muy poca información. Prueba a grabar de nuevo con más detalle o usa \"Guardar sin análisis\".';

  @override
  String get dreamAnalysisMorfeoInterpreting =>
      'Morfeo está interpretando tu sueño...';

  @override
  String get dreamAnalysisMorfeoAnalyzeFailedTitle => 'Morfeo no pudo analizar';

  @override
  String get dreamAnalysisMorfeoAnalyzeFailedMessage =>
      'Ahora mismo no se pudo completar el análisis. Puede pasar si el audio no se escucha bien o si hay muy poca información. Prueba a grabar de nuevo con más detalle o usa \"Guardar sin análisis\".';

  @override
  String get dreamAnalysisMorfeoAnalyzeUnexpectedMessage =>
      'Se produjo un error inesperado al analizar el sueño. Puede pasar si el audio no se escucha bien o si hay muy poca información. Prueba a grabar de nuevo con más detalle o usa \"Guardar sin análisis\".';

  @override
  String get dreamAnalysisSavingToJournal => 'Guardando en tu diario...';

  @override
  String get dreamAnalysisSaveFailedTitle => 'No se pudo guardar el sueño';

  @override
  String get dreamAnalysisSaveFailedAudioMessage =>
      'No se pudo completar el guardado. Puede deberse a una subida incompleta de audio o a un problema de conexión. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get dreamAnalysisSaveFailedConnectionMessage =>
      'No se pudo completar el guardado por un problema de conexión o permisos. Inténtalo de nuevo.';

  @override
  String get dreamAnalysisSaveErrorRetry =>
      'Error al guardar el sueño. Inténtalo de nuevo.';

  @override
  String get dreamAnalysisUnderstood => 'Entendido';

  @override
  String get dreamAnalysisSomethingWentWrong => 'Algo salió mal.';

  @override
  String get dreamAnalysisMorfeoSubtitle => 'Intérprete de sueños IA';

  @override
  String get dreamAnalysisCardBodyWithAudio =>
      'Transcribiré tus grabaciones y analizaré emociones, lugares y temas clave de tu sueño.';

  @override
  String get dreamAnalysisCardBodyWithoutAudio =>
      'Analizaré emociones, lugares y temas clave de tu sueño y te devolveré un resumen útil.';

  @override
  String get dreamAnalysisAnalyzeWithMorfeo => 'Analizar con Morfeo';

  @override
  String get dreamAnalysisSaveWithoutAnalysis => 'Guardar sin análisis';

  @override
  String dreamAnalysisAudioRecordingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'es',
      one: '',
    );
    return '$count grabación$_temp0';
  }

  @override
  String get dreamSavedMorfeoAnalyzeFailedTitle =>
      'Morfeo no pudo analizar el sueño';

  @override
  String dreamSavedShareWithBody(String title, String body) {
    return '✨ \"$title\"\n\n$body\n\n— Registrado en Hypnos Dream Journal';
  }

  @override
  String dreamSavedShareWithoutBody(String title) {
    return '✨ \"$title\"\n\n— Registrado en Hypnos Dream Journal';
  }

  @override
  String get dreamSavedTitle => '¡Sueño guardado!';

  @override
  String get dreamSavedPublishDream => 'Publicar sueño';

  @override
  String get dreamSavedVisibleOnlyYou => 'Solo visible para ti';

  @override
  String get dreamSavedShareSection => 'COMPARTIR';

  @override
  String get dreamSavedShareWhatsapp => 'WhatsApp';

  @override
  String get dreamSavedShareMore => 'Más';

  @override
  String get dreamSavedGoToJournal => 'Ir al diario';

  @override
  String get dreamSavedVisibleForEveryone => 'Visible para todos';

  @override
  String get dreamSavedVisibleForFollowers => 'Visible para seguidores';

  @override
  String get dreamSavedMorfeoInterpretation => 'INTERPRETACIÓN DE MORFEO';

  @override
  String get dreamMorfeoResultTitle => 'Resultado de Morfeo';

  @override
  String get dreamMorfeoResultSubtitle =>
      'Revisa el análisis completo antes de decidir cómo publicar tu sueño.';

  @override
  String get dreamMorfeoResultContinue => 'Continuar a publicación';

  @override
  String get dreamMorfeoResultEmpty =>
      'Morfeo no devolvió suficientes detalles de análisis para este sueño.';

  @override
  String get dreamMorfeoResultEmptyField => 'Sin datos';

  @override
  String get accountSecurityBiometricDialogTitle =>
      'Activar desbloqueo biométrico';

  @override
  String get accountSecurityBiometricDialogMessage =>
      'Introduce tu contraseña para guardar este acceso en este dispositivo.';

  @override
  String get accountSecurityCurrentPasswordLabel => 'Contraseña actual';

  @override
  String get accountSecurityActivate => 'Activar';

  @override
  String get accountSecurityBiometricDisabled =>
      'Desbloqueo biométrico desactivado';

  @override
  String get accountSecurityBiometricPasswordOnly =>
      'Solo se puede activar en cuentas con correo y contraseña';

  @override
  String get accountSecurityBiometricEnabled =>
      'Desbloqueo biométrico activado';

  @override
  String get accountSecurityBiometricEnableFailed =>
      'No se pudo activar la biometría';

  @override
  String get accountSecurityVisibilityEveryone => 'Todo el mundo';

  @override
  String get accountSecurityVisibilityFollowers => 'Solo seguidores';

  @override
  String get accountSecurityVisibilityPrivate => 'Privado';

  @override
  String get accountSecurityResetPasswordTitle => 'Restablecer contraseña';

  @override
  String accountSecurityResetPasswordMessage(String email) {
    return 'Te enviaremos un enlace a $email.';
  }

  @override
  String get accountSecurityResetPasswordSendLink => 'Enviar enlace';

  @override
  String get accountSecurityResetPasswordSendError =>
      'Error al enviar el enlace';

  @override
  String get accountSecurityEmailSentTitle => '¡Correo enviado!';

  @override
  String get accountSecurityEmailSentPrefix =>
      'Hemos enviado un enlace de\nrestablecimiento a ';

  @override
  String get accountSecurityEmailSentSuffix =>
      '\n\nRevisa también tu carpeta de spam.';

  @override
  String get accountSecurityVisibilityUpdated => 'Visibilidad actualizada';

  @override
  String get accountSecurityLogoutConfirmMessage =>
      '¿Seguro que quieres cerrar sesión?';

  @override
  String get accountSecurityDeleteWrongPassword =>
      'La contraseña es incorrecta';

  @override
  String get accountSecurityDeleteRequiresRecentLogin =>
      'Por seguridad, vuelve a iniciar sesión y reinténtalo';

  @override
  String get accountSecurityDeleteReauthUnavailable =>
      'Esta cuenta no usa contraseña. Inicia sesión con tu proveedor y reintenta';

  @override
  String get accountSecurityDeleteGenericError =>
      'No se pudo eliminar la cuenta. Inténtalo de nuevo';

  @override
  String get accountSecurityDeleteTitle => 'Eliminar cuenta';

  @override
  String get accountSecurityDeleteDialogMessage =>
      'Esta acción es permanente. Introduce tu contraseña para confirmar.';

  @override
  String get accountSecurityDeletePermanently => 'Eliminar definitivamente';

  @override
  String get accountSecurityCredentialsSection => 'CREDENCIALES';

  @override
  String get accountSecurityNoData => '—';

  @override
  String get accountSecurityChangePassword => 'Cambiar contraseña';

  @override
  String get accountSecurityPrivacySection => 'PRIVACIDAD';

  @override
  String get accountSecurityBiometricTitle => 'Desbloqueo biométrico';

  @override
  String get accountSecurityBiometricSupported =>
      'Usa tu huella para iniciar sesión en este dispositivo.';

  @override
  String get accountSecurityBiometricUnsupported =>
      'Este dispositivo no admite biometría.';

  @override
  String get accountSecurityDreamVisibility => 'Visibilidad de los sueños';

  @override
  String get accountSecurityAccountActionsSection => 'ACCIONES DE CUENTA';

  @override
  String get accountSecurityPermanentActionsHint =>
      'Estas acciones son permanentes y no se pueden deshacer.';

  @override
  String get accountSecurityVisibilityEveryoneSubtitle =>
      'Tus sueños están disponibles públicamente.';

  @override
  String get accountSecurityVisibilityFollowersSubtitle =>
      'Solo quienes te siguen pueden ver tus sueños.';

  @override
  String get accountSecurityVisibilityPrivateSubtitle =>
      'Nadie puede ver tus sueños.';

  @override
  String get socialFollowRequestsNotLoggedIn => 'Sesión no iniciada';

  @override
  String get socialFollowRequestsTitle => 'Solicitudes de seguimiento';

  @override
  String get socialFollowRequestsLoadError =>
      'No se pudieron cargar las solicitudes. Intenta de nuevo.';

  @override
  String get socialFollowRequestsEmpty => 'Sin solicitudes pendientes';

  @override
  String get socialFollowRequestsAccept => 'Aceptar';

  @override
  String get socialFollowRequestsDecline => 'Rechazar';
}
