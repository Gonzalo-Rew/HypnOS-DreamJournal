import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/auth_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';

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
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final uid = _user!.id;
      final ref = FirebaseStorage.instance.ref('avatars/$uid.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      await _authRepo.updateUserProfile(photoUrl: url);
      await FirebaseService.firestore.collection('users').doc(uid).update({
        'photoUrl': url,
      });
      if (!mounted) return;
      setState(() {
        _user = _user!.copyWith(photoUrl: url);
        _isSaving = false;
      });
      _showSnack('Avatar actualizado');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack('Error al subir avatar', isError: true);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || !_hasChanges) return;
    setState(() => _isSaving = true);
    final result = await _authRepo.updateUserProfile(displayName: name);
    if (!mounted) return;
    if (result is Failure) {
      final err = result.exception;
      final isTaken =
          err is ValidationException && err.message == 'display_name_taken';
      setState(() => _isSaving = false);
      _showSnack(
        isTaken
            ? (Localizations.localeOf(context).languageCode == 'en'
                  ? 'This name is already taken, please choose another'
                  : 'Este nombre ya está en uso, elige otro')
            : 'Error al actualizar el perfil',
        isError: true,
      );
      return;
    }
    setState(() {
      _user = _user?.copyWith(displayName: name);
      _originalName = name;
      _isSaving = false;
    });
    _showSnack(
      Localizations.localeOf(context).languageCode == 'en'
          ? 'Profile updated'
          : 'Perfil actualizado',
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.accentPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Editar perfil',
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
                      child: const Text(
                        'Cambiar avatar',
                        style: TextStyle(
                          color: AppColors.accentPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        labelText: 'Nombre de usuario',
                        labelStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
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
                      : const Text(
                          'Guardar',
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
