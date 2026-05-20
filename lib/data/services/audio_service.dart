import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';

/// Service for audio recording and Firebase Storage upload.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;

  bool get isRecording => _isRecording;

  /// Request microphone permission.
  Future<bool> requestPermission() async {
    return _recorder.hasPermission();
  }

  /// Start recording audio.
  /// Returns the file path where the recording will be saved.
  Future<Result<String>> startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw PermissionException(
          message: 'Microphone permission denied',
          permission: 'microphone',
        );
      }

      final dir = await _getTempDirectory();
      final filePath =
          '${dir.path}/dream_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      _isRecording = true;

      return Success(filePath);
    } catch (e) {
      if (e is PermissionException) {
        return Failure(e);
      }
      return Failure(AppException(message: 'Failed to start recording: $e'));
    }
  }

  /// Stop recording and return the file path of the recording.
  Future<Result<String>> stopRecording() async {
    try {
      if (!_isRecording) {
        return Failure(AppException(message: 'No active recording'));
      }

      final path = await _recorder.stop();
      _isRecording = false;

      if (path == null || path.isEmpty) {
        return Failure(AppException(message: 'Recording path is null'));
      }

      return Success(path);
    } catch (e) {
      _isRecording = false;
      return Failure(AppException(message: 'Failed to stop recording: $e'));
    }
  }

  /// Cancel active recording without saving.
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.cancel();
        _isRecording = false;
      }
    } catch (_) {
      _isRecording = false;
    }
  }

  /// Pause the active recording.
  Future<void> pauseRecording() async {
    try {
      if (_isRecording) await _recorder.pause();
    } catch (_) {}
  }

  /// Resume a paused recording.
  Future<void> resumeRecording() async {
    try {
      if (_isRecording) await _recorder.resume();
    } catch (_) {}
  }

  /// Upload a local audio file to Firebase Storage.
  /// [audioIndex] is used to name the file (audio_0.m4a, audio_1.m4a, etc.).
  /// Returns the download URL of the uploaded file.
  Future<Result<String>> uploadAudio({
    required String userId,
    required String dreamId,
    required String localFilePath,
    int audioIndex = 0,
    void Function(double progress)? onProgress,
  }) async {
    try {
      if (kIsWeb) {
        return Failure(
          AppException(message: 'Audio upload not supported on web'),
        );
      }

      final file = File(localFilePath);
      if (!await file.exists()) {
        return Failure(AppException(message: 'Audio file not found'));
      }

      final storage = FirebaseService.storage;
      final ref = storage.ref(
        'users/$userId/dreams/$dreamId/audio_$audioIndex.m4a',
      );

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'audio/m4a'),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          if (snapshot.totalBytes > 0) {
            onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
          }
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Success(downloadUrl);
    } on FirebaseException catch (e) {
      return Failure(
        AppException(message: 'Firebase Storage error: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Failure(AppException(message: 'Failed to upload audio: $e'));
    }
  }

  /// Delete an audio file from Firebase Storage by its URL.
  Future<Result<void>> deleteAudio({required String audioUrl}) async {
    try {
      final ref = FirebaseService.storage.refFromURL(audioUrl);
      await ref.delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(
        AppException(message: 'Failed to delete audio: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Failure(AppException(message: 'Failed to delete audio: $e'));
    }
  }

  /// Delete a local temp audio file.
  Future<void> deleteLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<Directory> _getTempDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return getTemporaryDirectory();
    }
    return getApplicationDocumentsDirectory();
  }

  void dispose() {
    _recorder.dispose();
  }
}
