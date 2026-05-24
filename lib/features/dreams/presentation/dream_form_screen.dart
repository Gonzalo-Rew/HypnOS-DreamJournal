import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/audio_service.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/dreams/data/dream_draft.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_analysis_step_screen.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dreams_refresh_bus.dart';
import 'package:hypnos_dreamjournal/features/settings/presentation/account_security_screen.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/utils/intensity_utils.dart';
import 'package:hypnos_dreamjournal/shared/utils/validators_formatters.dart';
import 'package:hypnos_dreamjournal/shared/widgets/audio_recorder_widget.dart';

class DreamFormScreen extends StatefulWidget {
  const DreamFormScreen({super.key, this.dream});

  final Dream? dream;

  @override
  State<DreamFormScreen> createState() => _DreamFormScreenState();
}

class _DreamFormScreenState extends State<DreamFormScreen> {
  static const int _maxAudios = 3;
  static const int _minDreamDescriptionChars = 100;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Intensity replaces the old 1-5 text field: stored as 1-5 mapped from 0.0-1.0
  double _intensityValue = 0.5; // maps to moodScore 3

  // Fecha del sueño
  DateTime _selectedDate = DateTime.now();

  // Whether the user wants to publish this dream
  bool _isPublished = false;
  // Profile-level visibility setting (loaded from Firestore)
  String _profileDreamVisibility = 'followers';

  final DreamRepository _dreamRepository = DreamRepositoryImpl();

  bool _isSubmitting = false;
  String? _errorMessage;

  // Audio state — max 3 recordings.
  /// Remote URLs already stored in Firestore (edit mode).
  late final List<String> _existingAudioUrls;

  /// Remote URLs removed during edit (to be deleted from Storage on save).
  final List<String> _removedExistingUrls = [];

  /// New local file paths recorded in this session.
  final List<String> _localAudioPaths = [];

  /// Whether the recorder widget is currently visible.
  bool _showRecorder = false;

  int get _totalAudioCount =>
      _existingAudioUrls.length -
      _removedExistingUrls.length +
      _localAudioPaths.length;

  bool get _isEditing => widget.dream != null;

  bool get _hasActiveAudio {
    final activeExisting = _existingAudioUrls
        .where((url) => !_removedExistingUrls.contains(url))
        .toList();
    return activeExisting.isNotEmpty || _localAudioPaths.isNotEmpty;
  }

  String? _validateDreamDescription(AppLocalizations l, String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      if (!_hasActiveAudio) {
        return l.dreamFormNeedTextOrAudio;
      }
      return null;
    }

    if (trimmed.length < _minDreamDescriptionChars) {
      return l.dreamFormDescriptionMin(_minDreamDescriptionChars);
    }
    return null;
  }

  void _showAudioLimitFeedback(AppLocalizations l) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(content: Text(l.dreamFormAudioLimit(_maxAudios))),
    );
  }

  @override
  void initState() {
    super.initState();
    final dream = widget.dream;
    if (dream != null) {
      _titleController.text = dream.title;
      _descriptionController.text = dream.text;
      // Map moodScore (1-5) back to slider 0.0-1.0
      final score = (dream.moodScore ?? 3).clamp(1, 5);
      _intensityValue = (score - 1) / 4.0;
      _existingAudioUrls = List<String>.from(dream.audioPaths);
      _isPublished = dream.isPublished;
      _selectedDate = dream.dreamDate;
    } else {
      _intensityValue = 0.5;
      _existingAudioUrls = [];
      _selectedDate = DateTime.now();
    }
    _loadProfile();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userId = FirebaseService.getCurrentUserId();
    if (userId == null) return;
    try {
      final doc = await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();
      if (!mounted) return;
      final profileVis = (doc.data()?['dreamVisibility'] as String?) == 'public'
          ? 'public'
          : 'followers';
      setState(() {
        _profileDreamVisibility = profileVis;
      });
    } catch (_) {}
  }

  // Derives the dream's DreamVisibility from the publish toggle + profile setting.
  DreamVisibility get _resolvedVisibility {
    if (!_isPublished) return DreamVisibility.private;
    return switch (_profileDreamVisibility) {
      'public' => DreamVisibility.public,
      'followers' => DreamVisibility.followers,
      _ => DreamVisibility.followers,
    };
  }

  // Maps slider 0.0-1.0 to moodScore 1-5
  int get _moodScore => (_intensityValue * 4).round() + 1;

  // ── Audio callbacks ────────────────────────────────────────────────────────

  void _onRecordingComplete(String filePath) {
    final l = AppLocalizations.of(context);
    if (_totalAudioCount >= _maxAudios) {
      AudioService.instance.deleteLocalFile(filePath);
      _showAudioLimitFeedback(l);
      setState(() => _showRecorder = false);
      return;
    }
    setState(() {
      _localAudioPaths.add(filePath);
      _showRecorder = false;
    });
  }

  void _onRecordingCancelled() {
    setState(() => _showRecorder = false);
  }

  void _deleteExistingAudio(String url) {
    setState(() => _removedExistingUrls.add(url));
  }

  Future<void> _deleteLocalAudio(String path) async {
    await AudioService.instance.deleteLocalFile(path);
    setState(() => _localAudioPaths.remove(path));
  }

  void _onAddAudioPressed() {
    final l = AppLocalizations.of(context);
    if (_totalAudioCount >= _maxAudios) {
      _showAudioLimitFeedback(l);
      return;
    }
    setState(() => _showRecorder = true);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context);

    final userId = FirebaseService.getCurrentUserId();
    if (userId == null) {
      setState(
        () => _errorMessage = AppLocalizations.of(context).dreamFormNotLoggedIn,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final moodScore = _moodScore;

    final hasText = _descriptionController.text.trim().isNotEmpty;
    final hasAudio = _hasActiveAudio;
    if (!hasText && !hasAudio) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = l.dreamFormNeedTextOrAudio;
      });
      return;
    }

    // ── Create mode: delegate to AI wizard (Step 2) ──────────────────────────
    if (!_isEditing) {
      final draft = DreamDraft(
        title: _titleController.text.trim(),
        text: _descriptionController.text.trim(),
        moodScore: moodScore,
        localAudioPaths: List<String>.from(_localAudioPaths),
        existingAudioUrls: const [],
        removedExistingUrls: const [],
        isEditing: false,
        dreamDate: _selectedDate,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DreamAnalysisStepScreen(draft: draft),
        ),
      );
      return;
    }

    // ── Edit mode: upload audio then update Firestore ─────────────────────────
    final uploadedUrls = <String>[];
    for (var i = 0; i < _localAudioPaths.length; i++) {
      final uploadResult = await AudioService.instance.uploadAudio(
        userId: userId,
        dreamId: widget.dream!.id,
        localFilePath: _localAudioPaths[i],
        audioIndex: i,
      );
      if (uploadResult is Success<String>) {
        uploadedUrls.add(uploadResult.value);
      }
    }

    // Delete removed remote files from Storage (best-effort, no blocking).
    for (final url in _removedExistingUrls) {
      AudioService.instance.deleteAudio(audioUrl: url);
    }

    // Build final audioPaths list.
    final keptExisting = _existingAudioUrls
        .where((url) => !_removedExistingUrls.contains(url))
        .toList();
    final finalAudioPaths = [...keptExisting, ...uploadedUrls];

    final updateData = <String, dynamic>{
      'title': _titleController.text.trim(),
      'text': _descriptionController.text.trim(),
      'moodScore': moodScore,
      'tags': ['mood:$moodScore'],
      'audioPaths': finalAudioPaths,
      'hasAudio': finalAudioPaths.isNotEmpty,
      'visibility': _resolvedVisibility.name,
      'isPublished': _isPublished,
      'dreamDate': _selectedDate,
    };
    final result = await _dreamRepository.updateDream(
      userId: userId,
      dreamId: widget.dream!.id,
      data: updateData,
    );
    _handleResult(result);
  }

  void _handleResult(Result<void> result) {
    if (!mounted) return;
    if (result is Success<void>) {
      setState(() => _isSubmitting = false);
      DreamsRefreshBus.notifyUpdated();
      Navigator.of(context).pop(true);
      return;
    }
    _handleFailure((result as Failure<void>).exception);
  }

  void _handleFailure(Exception exception) {
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _errorMessage = exception.toString();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    const sectionLabelStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    );

    const glassDecoration = BoxDecoration(
      color: AppColors.surfaceGlass,
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
      border: Border.fromBorderSide(BorderSide(color: AppColors.borderSubtle)),
    );

    const fieldStyle = TextStyle(
      color: AppColors.textPrimary,
      fontFamily: 'Lora',
      fontStyle: FontStyle.italic,
      fontSize: 16,
    );

    const hintStyle = TextStyle(
      color: AppColors.textSecondary,
      fontFamily: 'Lora',
      fontStyle: FontStyle.italic,
      fontSize: 16,
    );

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          _isEditing ? l.dreamFormEditTitle : l.dreamFormNewTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.sm,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isEditing) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGlass,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.accentPrimary.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.accentPrimary.withValues(
                                  alpha: 0.16,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: AppColors.accentPrimary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'Actualizar sueño',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Revisa el contenido, ajusta su privacidad y guarda los cambios.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('CONTENIDO DEL SUEÑO', style: sectionLabelStyle),
                  const SizedBox(height: AppSpacing.xs),
                ],
                // ── FECHA ───────────────────────────────────────────────
                Text(l.dreamFormDateSection, style: sectionLabelStyle),
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      locale: Localizations.localeOf(context),
                      barrierColor: Colors.black.withValues(alpha: 0.72),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.accentPrimary,
                            onPrimary: AppColors.bgPrimary,
                            surface: Color(0xFF1E2230),
                            onSurface: AppColors.textPrimary,
                          ),
                          datePickerTheme: DatePickerThemeData(
                            backgroundColor: const Color(0xFF1E2230),
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: AppColors.accentPrimary.withValues(
                                  alpha: 0.22,
                                ),
                                width: 1,
                              ),
                            ),
                          ),
                          dialogTheme: const DialogThemeData(
                            backgroundColor: Color(0xFF1E2230),
                            surfaceTintColor: Colors.transparent,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xE61E2230),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadius.md),
                      ),
                      border: Border.all(
                        color: AppColors.borderSubtle.withValues(alpha: 0.55),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.accentPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                          style: fieldStyle,
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.edit_calendar,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── TÍTULO ──────────────────────────────────────────────
                Text(l.dreamFormTitleSection, style: sectionLabelStyle),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  decoration: glassDecoration,
                  child: TextFormField(
                    controller: _titleController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    smartDashesType: SmartDashesType.enabled,
                    smartQuotesType: SmartQuotesType.enabled,
                    style: fieldStyle,
                    decoration: InputDecoration(
                      hintText: l.dreamFormTitleHint,
                      hintStyle: hintStyle,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    validator: (v) => Validators.validateRequired(
                      v,
                      l.dreamFormFieldTitle,
                      l,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── CUÉNTALO ────────────────────────────────────────────
                Text(l.dreamFormTellItSection, style: sectionLabelStyle),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  decoration: glassDecoration,
                  child: Stack(
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        enableSuggestions: true,
                        smartDashesType: SmartDashesType.enabled,
                        smartQuotesType: SmartQuotesType.enabled,
                        style: fieldStyle,
                        decoration: InputDecoration(
                          hintText: l.dreamFormDescriptionHint,
                          hintStyle: hintStyle,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(
                            left: AppSpacing.md,
                            right: AppSpacing.md,
                            top: AppSpacing.sm,
                            bottom: AppSpacing.xl,
                          ),
                        ),
                        validator: (v) => _validateDreamDescription(l, v),
                      ),
                      Positioned(
                        right: AppSpacing.sm,
                        bottom: AppSpacing.sm,
                        child: Icon(
                          Icons.graphic_eq,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.35,
                          ),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── INTENSIDAD EMOCIONAL ─────────────────────────────────
                Text(l.dreamFormIntensitySection, style: sectionLabelStyle),
                const SizedBox(height: AppSpacing.xs),
                _IntensitySlider(
                  value: _intensityValue,
                  onChanged: (v) => setState(() => _intensityValue = v),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── GRABACIONES DE VOZ ───────────────────────────────────
                _buildAudioSection(l),
                const SizedBox(height: AppSpacing.md),

                if (_isEditing) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text('PUBLICACIÓN Y ALCANCE', style: sectionLabelStyle),
                  const SizedBox(height: AppSpacing.xs),
                  _PublishToggle(
                    isPublished: _isPublished,
                    profileVisibility: _profileDreamVisibility,
                    onChanged: (value) => setState(() => _isPublished = value),
                    onGoToSettings: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AccountSecurityScreen(),
                        ),
                      );
                    },
                  ),
                ],

                // ── Error ────────────────────────────────────────────────
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                // ── BOTÓN GUARDAR ────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPrimary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: AppColors.bgPrimary,
                      disabledBackgroundColor: AppColors.accentPrimary
                          .withValues(alpha: 0.5),
                      minimumSize: const Size.fromHeight(54),
                      shape: const StadiumBorder(),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.bgPrimary,
                            ),
                          )
                        : Text(
                            _isEditing
                                ? 'Actualizar sueño'
                                : l.dreamFormNextButton,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.bgPrimary,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (_isEditing)
                  Text(
                    l.dreamFormPrivateSaveHint,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioSection(AppLocalizations l) {
    final activeExisting = _existingAudioUrls
        .where((url) => !_removedExistingUrls.contains(url))
        .toList();

    final clips = [
      ...activeExisting.map((u) => (path: u, local: false)),
      ..._localAudioPaths.map((p) => (path: p, local: true)),
    ];

    final hasContent = clips.isNotEmpty || _showRecorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section label
        Text(
          l.dreamFormVoiceRecordingsSection.toUpperCase(),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mic,
                      color: AppColors.accentPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l.dreamFormVoiceRecordingsSection,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _totalAudioCount >= _maxAudios
                            ? AppColors.error.withValues(alpha: 0.15)
                            : AppColors.accentPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_totalAudioCount / $_maxAudios',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _totalAudioCount >= _maxAudios
                              ? AppColors.error
                              : AppColors.accentPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Clip list ────────────────────────────────────────────────
              if (clips.isNotEmpty) ...[
                const Divider(height: 1, color: AppColors.borderSubtle),
                for (var i = 0; i < clips.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        // Index badge
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.accentPrimary.withValues(
                              alpha: 0.12,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: AppColors.accentPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        // Compact player
                        Expanded(
                          child: clips[i].local
                              ? _CompactAudioPlayer(localPath: clips[i].path)
                              : _CompactAudioPlayer(remoteUrl: clips[i].path),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        // Delete
                        GestureDetector(
                          onTap: clips[i].local
                              ? () => _deleteLocalAudio(clips[i].path)
                              : () => _deleteExistingAudio(clips[i].path),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < clips.length - 1)
                    const Divider(
                      height: 1,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                      color: AppColors.borderSubtle,
                    ),
                ],
              ],

              // ── Recorder / Add button ────────────────────────────────────
              if (hasContent)
                const Divider(height: 1, color: AppColors.borderSubtle),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _showRecorder
                    ? AudioRecorderWidget(
                        onRecordingComplete: _onRecordingComplete,
                        onRecordingDeleted: _onRecordingCancelled,
                        autoStartOnMount: true,
                        directActionMode: true,
                      )
                    : GestureDetector(
                        onTap: _onAddAudioPressed,
                        child: CustomPaint(
                          painter: _DashedRectPainter(
                            color:
                                (_totalAudioCount >= _maxAudios
                                        ? AppColors.textSecondary
                                        : AppColors.accentPrimary)
                                    .withValues(alpha: 0.4),
                            radius: 12,
                          ),
                          child: SizedBox(
                            height: 88,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _totalAudioCount >= _maxAudios
                                        ? Icons.mic_off
                                        : Icons.mic,
                                    color: _totalAudioCount >= _maxAudios
                                        ? AppColors.textSecondary
                                        : AppColors.accentPrimary,
                                    size: 32,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _totalAudioCount >= _maxAudios
                                        ? l.dreamFormAudioLimitReached(
                                            _maxAudios,
                                          )
                                        : l.dreamFormRecordAudio,
                                    style: TextStyle(
                                      color: _totalAudioCount >= _maxAudios
                                          ? AppColors.textSecondary
                                          : AppColors.accentPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Compact inline audio player ──────────────────────────────────────────────

class _CompactAudioPlayer extends StatefulWidget {
  const _CompactAudioPlayer({this.localPath, this.remoteUrl})
    : assert(
        localPath != null || remoteUrl != null,
        'Provide localPath or remoteUrl',
      );

  final String? localPath;
  final String? remoteUrl;

  @override
  State<_CompactAudioPlayer> createState() => _CompactAudioPlayerState();
}

class _CompactAudioPlayerState extends State<_CompactAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      if (widget.localPath != null) {
        await _player.setFilePath(widget.localPath!);
      } else {
        await _player.setUrl(widget.remoteUrl!);
      }
      _player.durationStream.listen((d) {
        if (mounted && d != null) setState(() => _duration = d);
      });
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _player.playerStateStream.listen((s) {
        if (!mounted) return;
        setState(() {
          _isPlaying = s.playing;
          if (s.processingState == ProcessingState.completed) {
            _position = Duration.zero;
            _player.seek(Duration.zero);
          }
        });
      });
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_isLoading) {
      return const SizedBox(
        height: 32,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentPrimary,
            ),
          ),
        ),
      );
    }
    if (_hasError) {
      return Text(
        l.audioPlayerError,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.error),
      );
    }

    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Row(
      children: [
        GestureDetector(
          onTap: _isPlaying ? _player.pause : _player.play,
          child: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: AppColors.accentPrimary,
            size: 30,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: AppColors.accentPrimary,
              inactiveTrackColor: AppColors.accentPrimary.withValues(
                alpha: 0.2,
              ),
              thumbColor: AppColors.accentPrimary,
              overlayColor: AppColors.accentPrimary.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: progress.toDouble(),
              onChanged: (v) {
                final pos = Duration(
                  milliseconds: (_duration.inMilliseconds * v).round(),
                );
                _player.seek(pos);
              },
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${_fmt(_position)} / ${_fmt(_duration)}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ── Intensity Slider ─────────────────────────────────────────────────────────

class _IntensitySlider extends StatelessWidget {
  const _IntensitySlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labelIndex = (value * 4).round().clamp(0, 4);
    final intensityScore = labelIndex + 1;
    final badgeColor = IntensityUtils.color(intensityScore);
    final intensityGradientColors = List<Color>.generate(
      5,
      (index) => IntensityUtils.color(index + 1),
    );
    final cardBackground = Color.lerp(
      AppColors.surfaceGlass,
      badgeColor,
      0.08,
    )!;
    final cardBorder = Color.lerp(AppColors.borderSubtle, badgeColor, 0.45)!;
    final labels = [
      l.dreamFormIntensityCalm,
      l.dreamFormIntensityMild,
      l.dreamFormIntensityModerate,
      l.dreamFormIntensityIntense,
      l.dreamFormIntensityExtreme,
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pill badge aligned top-right
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                labels[labelIndex],
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Gradient track + transparent-track slider stacked
          SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(colors: intensityGradientColors),
                  ),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    thumbShape: _GlowThumbShape(glowColor: badgeColor),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Colors.white,
                    overlayColor: badgeColor.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: value,
                    min: 0.0,
                    max: 1.0,
                    divisions: 4,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labels.first,
                style: TextStyle(
                  color: labelIndex <= 1 ? badgeColor : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: labelIndex <= 1
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
              Text(
                labels[2],
                style: TextStyle(
                  color: labelIndex == 2 ? badgeColor : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: labelIndex == 2
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
              Text(
                labels.last,
                style: TextStyle(
                  color: labelIndex >= 3 ? badgeColor : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: labelIndex >= 3
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Publish Toggle ───────────────────────────────────────────────────────────

class _PublishToggle extends StatelessWidget {
  const _PublishToggle({
    required this.isPublished,
    required this.profileVisibility,
    required this.onChanged,
    required this.onGoToSettings,
  });

  final bool isPublished;
  final String profileVisibility;
  final ValueChanged<bool> onChanged;
  final VoidCallback onGoToSettings;

  String get _audienceDescription {
    return switch (profileVisibility) {
      'public' =>
        isPublished
            ? 'Cualquier usuario de Hypnos podrá verlo.'
            : 'Si lo publicas, será visible para todo el mundo.',
      _ =>
        isPublished
            ? 'Solo tus seguidores podrán verlo.'
            : 'Si lo publicas, será visible solo para tus seguidores.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle row
          Row(
            children: [
              Icon(
                isPublished ? Icons.public : Icons.lock_outline,
                color: AppColors.accentPrimary,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Publicar sueño',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: isPublished,
                onChanged: onChanged,
                activeThumbColor: AppColors.accentPrimary,
                activeTrackColor: AppColors.accentPrimary.withValues(
                  alpha: 0.25,
                ),
                inactiveTrackColor: AppColors.borderSubtle.withValues(
                  alpha: 0.3,
                ),
                inactiveThumbColor: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _audienceDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onGoToSettings,
            child: Text(
              'Cambiar en Ajustes ->',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.accentPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashed Rectangle Painter ────────────────────────────────────────────────

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

// ── Glow Thumb Shape ────────────────────────────────────────────────────────

class _GlowThumbShape extends SliderComponentShape {
  const _GlowThumbShape({required this.glowColor});

  final Color glowColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    // Glow
    canvas.drawCircle(
      center,
      14,
      Paint()
        ..color = glowColor.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // White thumb
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }
}
