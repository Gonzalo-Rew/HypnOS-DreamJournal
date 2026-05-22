import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/services/audio_service.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/errors/error_messages.dart';

/// Callback signature when a recording is completed.
typedef OnRecordingComplete = void Function(String filePath);

/// Widget for recording audio inside the dream form.
class AudioRecorderWidget extends StatefulWidget {
  const AudioRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    this.onRecordingDeleted,
    this.existingRecordingPath,
    this.autoStartOnMount = false,
    this.directActionMode = false,
  });

  /// Called when a new recording is successfully completed.
  final OnRecordingComplete onRecordingComplete;

  /// Called when the recording is deleted by the user.
  final VoidCallback? onRecordingDeleted;

  /// If a recording already exists (edit mode), its local path.
  final String? existingRecordingPath;

  /// Starts recording automatically when the widget is mounted.
  final bool autoStartOnMount;

  /// Shows direct Save/Cancel actions immediately (used by dream form UX).
  final bool directActionMode;

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioService _audioService = AudioService.instance;

  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _errorMessage;
  bool _isStarting = false;
  bool _isStopping = false;
  bool _hasAutoStarted = false;

  bool get _isBusy => _isStarting || _isStopping;

  @override
  void initState() {
    super.initState();
    if (widget.autoStartOnMount) {
      _isStarting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoStartIfNeeded();
      });
    }
  }

  Future<void> _autoStartIfNeeded() async {
    if (_hasAutoStarted || !mounted || _isRecording) {
      return;
    }
    _hasAutoStarted = true;
    await _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isRecording) {
      _audioService.cancelRecording();
    }
    super.dispose();
  }

  void _startTimer() {
    _elapsed = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed += const Duration(seconds: 1));
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _startRecording() async {
    setState(() {
      _isStarting = true;
      _errorMessage = null;
    });

    try {
      final result = await _audioService.startRecording();

      if (!mounted) return;

      if (result is Success<String>) {
        setState(() {
          _isRecording = true;
          _isStarting = false;
        });
        _startTimer();
      } else {
        final failure = result as Failure<String>;
        setState(() {
          _isStarting = false;
          _errorMessage = failure.exception is PermissionException
              ? 'Permiso de micrófono denegado. Actívalo en Ajustes.'
              : 'Error al iniciar la grabación.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isStarting = false;
        _errorMessage = AppError.handle(e, 'AudioRecorder.start');
      });
    }
  }

  Future<void> _stopRecording() async {
    // Disable further stop calls while processing.
    setState(() => _isStopping = true);
    _stopTimer();

    try {
      final result = await _audioService.stopRecording();

      if (!mounted) return;

      if (result is Success<String>) {
        widget.onRecordingComplete(result.value);
        if (mounted) {
          setState(() {
            _isRecording = false;
            _isStopping = false;
            _elapsed = Duration.zero;
          });
        }
      } else {
        // Stop failed — let user try again.
        setState(() {
          _isStopping = false;
          _errorMessage = 'No se pudo detener la grabación.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isStopping = false;
        _errorMessage = AppError.handle(e, 'AudioRecorder.stop');
      });
    }
  }

  Future<void> _cancelRecording() async {
    setState(() {
      _isStopping = true;
      _errorMessage = null;
    });
    _stopTimer();

    await _audioService.cancelRecording();
    if (!mounted) return;

    setState(() {
      _isRecording = false;
      _isStopping = false;
      _elapsed = Duration.zero;
    });
    widget.onRecordingDeleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              _errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ),
        if (_isRecording) _buildRecordingActive(),
        if (!_isRecording) _buildRecordingIdle(),
      ],
    );
  }

  Widget _buildRecordingIdle() {
    if (widget.directActionMode) {
      return _buildDirectActionIdle();
    }

    if (_isStarting && widget.autoStartOnMount) {
      return const SizedBox(
        height: 56,
        child: Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentPrimary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isBusy ? null : _startRecording,
            icon: _isStarting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.mic_rounded),
            label: Text(_isStarting ? 'Iniciando...' : 'Iniciar grabación'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectActionIdle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PulsingDot(),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _isStarting ? 'Iniciando grabación...' : 'Grabando · 00:00',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 190,
              child: FilledButton.icon(
                onPressed: (_isStarting || _isStopping) ? null : _stopRecording,
                icon: (_isStarting || _isStopping)
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.stop_rounded),
                label: Text(
                  _isStarting
                      ? 'Iniciando...'
                      : _isStopping
                      ? 'Finalizando...'
                      : 'Guardar',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(
              onPressed: _isStopping ? null : _cancelRecording,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.borderSubtle),
                minimumSize: const Size(110, 46),
                shape: const StadiumBorder(),
              ),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordingActive() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PulsingDot(),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Grabando · ${_formatDuration(_elapsed)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 190,
              child: FilledButton.icon(
                onPressed: _isStopping ? null : _stopRecording,
                icon: _isStopping
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.stop_rounded),
                label: Text(_isStopping ? 'Finalizando...' : 'Guardar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(
              onPressed: _isStopping ? null : _cancelRecording,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.borderSubtle),
                minimumSize: const Size(110, 46),
                shape: const StadiumBorder(),
              ),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Animated pulsing red dot for active recording indicator.
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
