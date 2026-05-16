import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/audio_service.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
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
  static const String _aiCategoryPlaceholder = 'Pending AI categorization';
  static const int _maxAudios = 3;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _moodScoreController = TextEditingController();
  final _contextNotesController = TextEditingController();

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
      _existingAudioUrls.length - _removedExistingUrls.length +
      _localAudioPaths.length;

  bool get _isEditing => widget.dream != null;

  @override
  void initState() {
    super.initState();
    final dream = widget.dream;
    if (dream != null) {
      _titleController.text = dream.title;
      _descriptionController.text = dream.text;
      _moodScoreController.text = (dream.moodScore ?? 3).toString();
      _contextNotesController.text = dream.contextNotes ?? '';
      _existingAudioUrls = List<String>.from(dream.audioPaths);
    } else {
      _moodScoreController.text = '3';
      _existingAudioUrls = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _moodScoreController.dispose();
    _contextNotesController.dispose();
    super.dispose();
  }

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

  // ── Validation ─────────────────────────────────────────────────────────────

  String? _validateMoodScore(String? value) {
    final l = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l.dreamFormValidationMoodRequired;
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 1 || parsed > 5) {
      return l.dreamFormValidationMoodRange;
    }
    return null;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = FirebaseService.getCurrentUserId();
    if (userId == null) {
      setState(() => _errorMessage = AppLocalizations.of(context).dreamFormNotLoggedIn);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final moodScore = int.parse(_moodScoreController.text.trim());

    final tempDreamId = _isEditing
        ? widget.dream!.id
        : '${userId}_${DateTime.now().millisecondsSinceEpoch}';

    // Upload new local recordings.
    final uploadedUrls = <String>[];
    for (var i = 0; i < _localAudioPaths.length; i++) {
      final uploadResult = await AudioService.instance.uploadAudio(
        userId: userId,
        dreamId: tempDreamId,
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

    if (_isEditing) {
      final updateData = <String, dynamic>{
        'title': _titleController.text.trim(),
        'text': _descriptionController.text.trim(),
        'moodScore': moodScore,
        'contextNotes': _contextNotesController.text.trim(),
        'tags': ['mood:$moodScore'],
        'audioPaths': finalAudioPaths,
        'hasAudio': finalAudioPaths.isNotEmpty,
      };
      final result = await _dreamRepository.updateDream(
        userId: userId,
        dreamId: widget.dream!.id,
        data: updateData,
      );
      _handleResult(result);
      return;
    }

    final createResult = await _dreamRepository.createDream(
      userId: userId,
      title: _titleController.text.trim(),
      text: _descriptionController.text.trim(),
      dreamDate: DateTime.now(),
      moodScore: moodScore,
      tags: ['mood:$moodScore'],
      contextNotes: _contextNotesController.text.trim(),
      audioPaths: finalAudioPaths,
    );

    if (createResult is Failure<Dream>) {
      _handleFailure(createResult.exception);
      return;
    }

    final createdDream = (createResult as Success<Dream>).value;
    _dreamRepository.updateDream(
      userId: userId,
      dreamId: createdDream.id,
      data: {'aiCategory': _aiCategoryPlaceholder},
    );

    // Clean up local temp files.
    for (final path in _localAudioPaths) {
      AudioService.instance.deleteLocalFile(path);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).pop(true);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.dreamFormEditTitle : l.dreamFormNewTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: l.dreamFormFieldTitle),
                  validator: (v) =>
                      Validators.validateRequired(v, l.dreamFormFieldTitle, l),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: l.dreamFormFieldText),
                  validator: (v) =>
                      Validators.validateRequired(v, l.dreamFormFieldText, l),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _moodScoreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l.dreamFormFieldMood),
                  validator: _validateMoodScore,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _contextNotesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l.dreamFormFieldContextNotes,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // ── Audio section ─────────────────────────────────────────
                _buildAudioSection(l),
                // ─────────────────────────────────────────────────────────
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isEditing
                              ? l.dreamFormSaveButton
                              : l.dreamFormCreateButton,
                        ),
                ),
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

    return Container(
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
                Icon(Icons.mic, color: AppColors.accentPrimary, size: 16),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                        color: AppColors.accentPrimary.withValues(alpha: 0.12),
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
                  : Center(
                      child: TextButton.icon(
                        onPressed: () =>
                            setState(() => _showRecorder = true),
                        icon: const Icon(Icons.mic_none, size: 18),
                        label: Text(
                          _totalAudioCount == 0
                              ? 'Grabar audio'
                              : 'Añadir grabación',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentPrimary,
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
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: AppColors.error),
      );
    }

    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds)
            .clamp(0.0, 1.0)
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
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: AppColors.accentPrimary,
              inactiveTrackColor:
                  AppColors.accentPrimary.withValues(alpha: 0.2),
              thumbColor: AppColors.accentPrimary,
              overlayColor:
                  AppColors.accentPrimary.withValues(alpha: 0.15),
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
