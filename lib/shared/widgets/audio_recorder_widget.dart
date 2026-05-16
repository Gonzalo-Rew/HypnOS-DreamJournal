import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/services/audio_service.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';

/// Callback signature when a recording is completed.
typedef OnRecordingComplete = void Function(String filePath);

/// Widget for recording audio inside the dream form.
class AudioRecorderWidget extends StatefulWidget {
  const AudioRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    this.onRecordingDeleted,
    this.existingRecordingPath,
  });

  /// Called when a new recording is successfully completed.
  final OnRecordingComplete onRecordingComplete;

  /// Called when the recording is deleted by the user.
  final VoidCallback? onRecordingDeleted;

  /// If a recording already exists (edit mode), its local path.
  final String? existingRecordingPath;

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioService _audioService = AudioService.instance;

  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _audioService.startRecording();

      if (!mounted) return;

      if (result is Success<String>) {
        setState(() {
          _isRecording = true;
          _isLoading = false;
        });
        _startTimer();
      } else {
        final failure = result as Failure<String>;
        setState(() {
          _isLoading = false;
          _errorMessage = failure.exception is PermissionException
              ? 'Permiso de micrófono denegado. Actívalo en Ajustes.'
              : 'Error al iniciar la grabación.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error inesperado: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    // Disable further stop calls while processing.
    setState(() => _isLoading = true);
    _stopTimer();

    try {
      final result = await _audioService.stopRecording();

      if (!mounted) return;

      if (result is Success<String>) {
        widget.onRecordingComplete(result.value);
        if (mounted) {
          setState(() {
            _isRecording = false;
            _isLoading = false;
            _elapsed = Duration.zero;
          });
        }
      } else {
        // Stop failed — let user try again.
        setState(() {
          _isLoading = false;
          _errorMessage = 'No se pudo detener la grabación.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al detener: $e';
      });
    }
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        if (_isRecording) _buildRecordingActive(),
        if (!_isRecording) _buildRecordingIdle(),
      ],
    );
  }

  Widget _buildRecordingIdle() {
    return Center(
      child: _isLoading
          ? const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentPrimary,
              ),
            )
          : ElevatedButton.icon(
              onPressed: _startRecording,
              icon: const Icon(Icons.mic_none),
              label: const Text('Iniciar grabación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPrimary.withValues(alpha: 0.15),
                foregroundColor: AppColors.accentPrimary,
                side: const BorderSide(color: AppColors.accentPrimary),
              ),
            ),
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
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _stopRecording,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    )
                  : const Icon(Icons.stop_circle_outlined),
              label: const Text('Detener'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withValues(alpha: 0.2),
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      _stopTimer();
                      await _audioService.cancelRecording();
                      if (!mounted) return;
                      setState(() {
                        _isRecording = false;
                        _isLoading = false;
                        _elapsed = Duration.zero;
                      });
                      widget.onRecordingDeleted?.call();
                    },
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
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
