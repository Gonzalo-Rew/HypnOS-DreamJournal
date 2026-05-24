import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/auth_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/utils/validators_formatters.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthRepository _authRepo = AuthRepositoryImpl();
  final _nameController = TextEditingController();

  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String _originalName = '';
  String? _errorMessage;

  bool get _hasChanges => _nameController.text.trim() != _originalName;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await _authRepo.getCurrentUser();
    if (!mounted) return;
    if (result is Success<User>) {
      final u = result.value;
      setState(() {
        _user = u;
        _nameController.text = u.displayName;
        _originalName = u.displayName;
        _isLoading = false;
      });
    } else {
      final authUser = FirebaseService.getCurrentUser();
      if (authUser != null) {
        final name =
            authUser.displayName ?? authUser.email?.split('@').first ?? '';
        setState(() {
          _user = User(
            id: authUser.uid,
            email: authUser.email ?? '',
            displayName: name,
            createdAt: DateTime.now(),
            aiEnabled: true,
            timezone: 'UTC',
            notificationsEnabled: false,
            notificationTime: '08:00',
          );
          _nameController.text = name;
          _originalName = name;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAvatar() async {
    final l = AppLocalizations.of(context);
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    if (_user == null) {
      _showSnack(l.profileLoadError, isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final uid = _user!.id;
      final ref = FirebaseStorage.instance.ref('users/$uid/profile/avatar.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();

      final updateResult = await _authRepo.updateUserProfile(photoUrl: url);
      if (updateResult is Failure) {
        try {
          await ref.delete();
        } on FirebaseException catch (_) {
          // Best-effort rollback if Firestore update fails after upload.
        }
        throw updateResult.exception;
      }

      if (!mounted) return;
      setState(() {
        _user = _user!.copyWith(photoUrl: url);
        _isSaving = false;
      });
      _showSnack(l.editProfileAvatarUpdated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final msg = e is AppException
          ? e.message
          : l.editProfileAvatarUploadError;
      _showSnack(msg, isError: true);
    }
  }

  Future<void> _removeAvatar() async {
    final l = AppLocalizations.of(context);

    if (_user == null || _user?.photoUrl == null) {
      _showSnack(l.profileLoadError, isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final uid = _user!.id;
      final updateResult = await _authRepo.updateUserProfile(
        clearPhotoUrl: true,
      );
      if (updateResult is Failure) {
        throw updateResult.exception;
      }

      final ref = FirebaseStorage.instance.ref('users/$uid/profile/avatar.jpg');
      try {
        await ref.delete();
      } on FirebaseException catch (_) {
        // Best-effort cleanup. Profile state was already updated to no-avatar.
      }

      if (!mounted) return;
      setState(() {
        _user = _user!.copyWith(photoUrl: null);
        _isSaving = false;
      });
      _showSnack(l.editProfileAvatarRemoved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final msg = e is AppException
          ? e.message
          : l.editProfileAvatarRemoveError;
      _showSnack(msg, isError: true);
    }
  }

  Future<bool> _isDisplayNameTaken(String name) async {
    final key = name.trim().toLowerCase();
    final currentKey = _originalName.trim().toLowerCase();
    if (key == currentKey) return false;

    final reservedDoc = await FirebaseService.firestore
        .collection('usernames')
        .doc(key)
        .get();

    if (!reservedDoc.exists) return false;

    final reservedUid = reservedDoc.data()?['uid'] as String?;
    return reservedUid != null && reservedUid != _user?.id;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final l = AppLocalizations.of(context);
    if (!_hasChanges) return;

    final validationError = Validators.validateDisplayName(name, l);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final isTaken = await _isDisplayNameTaken(name);
      if (!mounted) return;
      if (isTaken) {
        setState(() {
          _isSaving = false;
          _errorMessage = l.validationDisplayNameTaken;
        });
        return;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = l.editProfileNameValidationError;
      });
      return;
    }

    final result = await _authRepo.updateUserProfile(displayName: name);
    if (!mounted) return;
    if (result is Failure) {
      final err = result.exception;
      final repoNameTaken =
          err is ValidationException && err.message == 'display_name_taken';
      setState(() {
        _isSaving = false;
        if (repoNameTaken) {
          _errorMessage = l.validationDisplayNameTaken;
        } else {
          _errorMessage = l.editProfileUpdateFailed;
        }
      });
      return;
    }
    setState(() {
      _user = _user?.copyWith(displayName: name);
      _originalName = name;
      _isSaving = false;
      _errorMessage = null;
    });
    _showSuccessFeedback(l.profileSaveSuccess);
  }

  void _showSnack(String msg, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E2230),
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(
              color: isError ? AppColors.error : AppColors.borderSubtle,
            ),
          ),
          duration: Duration(seconds: isError ? 3 : 2),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.photo_camera_rounded,
                color: isError ? AppColors.error : AppColors.accentPrimary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _showSuccessFeedback(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E2230),
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.accentPrimary,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentPrimary),
        ),
      );
    }

    final user = _user;
    final initials =
        (user?.displayName.isNotEmpty == true ? user!.displayName[0] : '?')
            .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    l.settingsEditProfile,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Avatar centrado
                  Center(
                    child: GestureDetector(
                      onTap: _isSaving ? null : _pickAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: AppColors.accentSecondary
                                .withValues(alpha: 0.3),
                            backgroundImage: user?.photoUrl != null
                                ? NetworkImage(user!.photoUrl!)
                                : null,
                            child: user?.photoUrl == null
                                ? Text(
                                    initials,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          if (_isSaving)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.accentPrimary,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.accentPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 14,
                                color: AppColors.bgPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // "Cambiar avatar" en azul
                  Center(
                    child: GestureDetector(
                      onTap: _isSaving ? null : _pickAvatar,
                      child: Text(
                        l.editProfileChangeAvatar,
                        style: TextStyle(
                          color: AppColors.accentPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (user?.photoUrl != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Center(
                      child: GestureDetector(
                        onTap: _isSaving ? null : _removeAvatar,
                        child: Text(
                          l.editProfileRemoveAvatar,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Nombre de usuario
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: TextField(
                      controller: _nameController,
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        labelText: l.editProfileUsername,
                        labelStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Guardar (bottom) ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: (_hasChanges && !_isSaving) ? _save : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    disabledBackgroundColor: AppColors.textSecondary.withValues(
                      alpha: 0.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.bgPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l.dreamFormSaveButton,
                          style: TextStyle(
                            color: AppColors.bgPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
