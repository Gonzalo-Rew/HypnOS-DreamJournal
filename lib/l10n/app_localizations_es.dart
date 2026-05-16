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
  String get dreamsListTitle => 'Sueños';

  @override
  String get dreamsListEmpty => 'Todavía no hay sueños.';

  @override
  String get dreamsListCreateFirst => 'Crea tu primer sueño';

  @override
  String get dreamsListRetry => 'Reintentar';

  @override
  String dreamsListMoodLabel(String score) {
    return 'Ánimo $score';
  }

  @override
  String get dreamsListMoodNoScore => 'Ánimo -';

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
  String get dreamFormFieldMood => 'Estado de ánimo (1-5)';

  @override
  String get dreamFormFieldContextNotes => 'Notas de contexto';

  @override
  String get dreamFormFieldAiCategory => 'Categoría IA';

  @override
  String get dreamFormValidationMoodRequired =>
      'El estado de ánimo es obligatorio';

  @override
  String get dreamFormValidationMoodRange =>
      'El estado de ánimo debe estar entre 1 y 5';

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
  String get dreamDetailMoodScore => 'Estado de ánimo';

  @override
  String get dreamDetailMoodTooltip =>
      'Tu estado de ánimo al despertar,\ndel 1 (muy mal) al 5 (excelente).';

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
  String get dashboardAvgMood => 'Ánimo prom.';

  @override
  String get dashboardAiAnalyzed => 'Analizados IA';

  @override
  String get dashboardMoodEvolution => 'Evolución del ánimo';

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
}
