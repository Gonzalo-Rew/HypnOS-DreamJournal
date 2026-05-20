import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hypnos_dreamjournal/app/app_routes.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/audio_service.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/dreams/data/dream_draft.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_analysis_step_screen.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
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

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Intensity replaces the old 1-5 text field: stored as 1-5 mapped from 0.0-1.0
  double _intensityValue = 0.5; // maps to moodScore 3

  // Whether the user wants to publish this dream
  bool _isPublished = false;
  // Profile-level visibility setting (loaded from Firestore)
  String _profileDreamVisibility = 'public';

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
    } else {
      _intensityValue = 0.5;
      _existingAudioUrls = [];
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
      final profileVis = doc.data()?['dreamVisibility'] as String? ?? 'public';
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
      _ => DreamVisibility.private,
    };
  }

  // Maps slider 0.0-1.0 to moodScore 1-5
  int get _moodScore => (_intensityValue * 4).round() + 1;

  // ── Audio callbacks ────────────────────────────────────────────────────────

  void _onRecordingComplete(String filePath) {
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

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

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

    // ── Create mode: delegate to AI wizard (Step 2) ──────────────────────────
    if (!_isEditing) {
      final hasContent =
          _descriptionController.text.trim().isNotEmpty ||
          _localAudioPaths.isNotEmpty;
      if (!hasContent) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Agrega una descripción o una grabación de audio.';
        });
        return;
      }

      final draft = DreamDraft(
        title: _titleController.text.trim(),
        text: _descriptionController.text.trim(),
        moodScore: moodScore,
        localAudioPaths: List<String>.from(_localAudioPaths),
        existingAudioUrls: const [],
        removedExistingUrls: const [],
        isEditing: false,
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
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: AppColors.accentPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
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
                // ── TÍTULO ──────────────────────────────────────────────
                const Text('TÍTULO', style: sectionLabelStyle),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  decoration: glassDecoration,
                  child: TextFormField(
                    controller: _titleController,
                    style: fieldStyle,
                    decoration: const InputDecoration(
                      hintText: 'El bosque de neón...',
                      hintStyle: hintStyle,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
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
                const Text('CUÉNTALO', style: sectionLabelStyle),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  decoration: glassDecoration,
                  child: Stack(
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        style: fieldStyle,
                        decoration: const InputDecoration(
                          hintText: 'Escribe lo que recuerdas...',
                          hintStyle: hintStyle,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            left: AppSpacing.md,
                            right: AppSpacing.md,
                            top: AppSpacing.sm,
                            bottom: AppSpacing.xl,
                          ),
                        ),
                        validator: (v) => Validators.validateRequired(
                          v,
                          l.dreamFormFieldText,
                          l,
                        ),
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
                const Text('INTENSIDAD EMOCIONAL', style: sectionLabelStyle),
                const SizedBox(height: AppSpacing.xs),
                _IntensitySlider(
                  value: _intensityValue,
                  onChanged: (v) => setState(() => _intensityValue = v),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── PUBLICAR SUEÑO ───────────────────────────────────────
                _PublishToggle(
                  isPublished: _isPublished,
                  profileVisibility: _profileDreamVisibility,
                  onChanged: (v) => setState(() => _isPublished = v),
                  onGoToSettings: () =>
                      Navigator.of(context).pushNamed(AppRoutes.settings),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── GRABACIONES DE VOZ ───────────────────────────────────
                _buildAudioSection(l),
                const SizedBox(height: AppSpacing.md),

                // ── ETIQUETAS DE CONTEXTO ────────────────────────────────
                _AiTagsPlaceholder(),

                // ── Error ────────────────────────────────────────────────
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error),
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
                            _isEditing ? l.dreamFormSaveButton : 'Siguiente →',
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
                  const Text(
                    'Tu sueño se guardará de forma privada',
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
        const Text(
          'GRABACIONES DE VOZ',
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
                      'Grabaciones de voz',
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
              if (_showRecorder || _totalAudioCount < _maxAudios) ...[
                if (hasContent)
                  const Divider(height: 1, color: AppColors.borderSubtle),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _showRecorder
                      ? AudioRecorderWidget(
                          onRecordingComplete: _onRecordingComplete,
                          onRecordingDeleted: _onRecordingCancelled,
                        )
                      : GestureDetector(
                          onTap: () => setState(() => _showRecorder = true),
                          child: CustomPaint(
                            painter: _DashedRectPainter(
                              color: AppColors.accentPrimary.withValues(
                                alpha: 0.4,
                              ),
                              radius: 12,
                            ),
                            child: SizedBox(
                              height: 88,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.mic,
                                      color: AppColors.accentPrimary,
                                      size: 32,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      _totalAudioCount == 0
                                          ? 'Toca para grabar'
                                          : 'Añadir grabación',
                                      style: const TextStyle(
                                        color: AppColors.accentPrimary,
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
              ] else ...[
                const Divider(height: 1, color: AppColors.borderSubtle),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    'Límite de $_maxAudios grabaciones alcanzado.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
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
        'Error al cargar',
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

  static const _labels = [
    'Tranquilo',
    'Leve',
    'Moderado',
    'Intenso',
    'Extremo',
  ];

  @override
  Widget build(BuildContext context) {
    final labelIndex = (value * 4).round().clamp(0, 4);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
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
                color: AppColors.accentSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _labels[labelIndex],
                style: const TextStyle(
                  color: AppColors.accentSecondary,
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
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1E2230),
                        AppColors.accentPrimary,
                        AppColors.accentSecondary,
                      ],
                    ),
                  ),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    thumbShape: _GlowThumbShape(),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Colors.white,
                    overlayColor: AppColors.accentPrimary.withValues(
                      alpha: 0.2,
                    ),
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tranquilo',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
              Text(
                'Moderado',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
              Text(
                'Extremo',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── AI Tags Placeholder ──────────────────────────────────────────────────────

class _AiTagsPlaceholder extends StatelessWidget {
  const _AiTagsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.accentSecondary.withValues(alpha: 0.35),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.accentSecondary,
                  size: 14,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Etiquetas de contexto',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.lock_outline,
                  color: AppColors.accentSecondary,
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Morfeo las generará automáticamente tras guardar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ['···', '···', '···']
                  .map(
                    (label) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSecondary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.accentSecondary.withValues(
                            alpha: 0.30,
                          ),
                        ),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.accentSecondary,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
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

  bool get _profileIsPrivate => profileVisibility == 'private';

  String get _audienceDescription {
    if (!isPublished) return 'Solo tú podrás ver este sueño.';
    return switch (profileVisibility) {
      'public' => 'Cualquier usuario de Hypnos podrá verlo.',
      'followers' => 'Solo tus seguidores podrán verlo.',
      _ => 'Solo tú podrás ver este sueño.',
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
                color: _profileIsPrivate
                    ? AppColors.textSecondary
                    : AppColors.accentPrimary,
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
                value: _profileIsPrivate ? false : isPublished,
                onChanged: _profileIsPrivate ? null : onChanged,
                activeColor: AppColors.accentPrimary,
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
          // Contextual info
          if (_profileIsPrivate) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tu perfil es privado. No puedes publicar sueños.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: onGoToSettings,
              child: Text(
                'Cambiar en Ajustes de privacidad →',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.accentPrimary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.accentPrimary,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              _audienceDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
        ..color = AppColors.accentPrimary.withValues(alpha: 0.30)
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
