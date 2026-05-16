import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/core/config/app_settings.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/app/app_routes.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/auth_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/shared/errors/exceptions.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/utils/validators_formatters.dart';
import 'package:hypnos_dreamjournal/shared/widgets/language_picker_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _authRepository = AuthRepositoryImpl();

  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoggingOut = false;
  String? _errorMessage;

  User? _currentUser;
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);

  // Sprint 3: Gemini API key
  final _geminiApiKeyController = TextEditingController();
  bool _obscureGeminiKey = true;
  bool _isSavingGeminiKey = false;

  // Sprint 4: AI toggle
  bool _aiEnabled = true;
  bool _isLoadingAiEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadGeminiKey();
    _loadAiEnabled();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _geminiApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadGeminiKey() async {
    final key = await AppSettings.instance.getGeminiApiKey();
    if (mounted && key != null) {
      _geminiApiKeyController.text = key;
    }
  }

  Future<void> _loadAiEnabled() async {
    final enabled = await AppSettings.instance.getAiEnabled();
    if (mounted) {
      setState(() {
        _aiEnabled = enabled;
        _isLoadingAiEnabled = false;
      });
    }
  }

  Future<void> _saveGeminiKey() async {
    final key = _geminiApiKeyController.text.trim();
    setState(() => _isSavingGeminiKey = true);
    if (key.isEmpty) {
      await AppSettings.instance.clearGeminiApiKey();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).profileGeminiApiKeyCleared),
          ),
        );
      }
    } else {
      await AppSettings.instance.setGeminiApiKey(key);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).profileGeminiApiKeySaved),
          ),
        );
      }
    }
    setState(() => _isSavingGeminiKey = false);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authRepository.getCurrentUser();

    if (!mounted) {
      return;
    }

    if (result is Failure<User>) {
      final l = AppLocalizations.of(context);
      // Fallback: use Firebase Auth data directly (Firestore doc may not exist yet)
      final authUser = FirebaseService.getCurrentUser();
      if (authUser != null) {
        final email = authUser.email ?? '';
        final displayName = authUser.displayName?.isNotEmpty == true
            ? authUser.displayName!
            : (email.isNotEmpty ? email.split('@').first : '');
        final fallback = User(
          id: authUser.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
          aiEnabled: true,
          timezone: 'UTC',
          notificationsEnabled: false,
          notificationTime: '08:00',
        );
        setState(() {
          _currentUser = fallback;
          _displayNameController.text = fallback.displayName;
          _isLoading = false;
          _errorMessage = l.profileIncomplete;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = l.profileLoadError;
        });
      }
      return;
    }

    final user = (result as Success<User>).value;
    final parts = user.notificationTime.split(':');
    final hour = int.tryParse(parts.first) ?? 8;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    setState(() {
      _currentUser = user;
      _displayNameController.text = user.displayName;
      _notificationsEnabled = user.notificationsEnabled;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
      _isLoading = false;
    });
  }

  Future<void> _pickNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );

    if (picked != null) {
      setState(() {
        _notificationTime = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _currentUser;
    if (user == null) {
      return;
    }

    final l = AppLocalizations.of(context);

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final updateAuthResult = await _authRepository.updateUserProfile(
      displayName: _displayNameController.text.trim(),
    );

    if (updateAuthResult is Failure<void>) {
      final ex = updateAuthResult.exception;
      setState(() {
        _isSaving = false;
        _errorMessage = ex is AuthException ? ex.message : l.profileSaveError;
      });
      return;
    }

    try {
      final hh = _notificationTime.hour.toString().padLeft(2, '0');
      final mm = _notificationTime.minute.toString().padLeft(2, '0');

      await FirebaseService.firestore.collection('users').doc(user.id).set({
        'displayName': _displayNameController.text.trim(),
        'email': user.email,
        'createdAt': user.createdAt,
        'aiEnabled': user.aiEnabled,
        'timezone': user.timezone,
        'photoUrl': user.photoUrl,
        'notificationsEnabled': _notificationsEnabled,
        'notificationTime': '$hh:$mm',
      }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.profileSaveSuccess)));
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _errorMessage = l.profileFirestoreError(e.message ?? '');
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _errorMessage = l.profileSaveError;
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
      _errorMessage = null;
    });

    final result = await _authRepository.signOut();

    if (!mounted) {
      return;
    }

    if (result is Failure<void>) {
      final l = AppLocalizations.of(context);
      setState(() {
        _isLoggingOut = false;
        _errorMessage = l.profileLogoutError;
      });
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profileTitle),
        actions: [const LanguagePickerButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(l.profileEmail(_currentUser?.email ?? '-')),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(labelText: l.fieldDisplayName),
                  validator: (v) => Validators.validateDisplayName(v, l),
                ),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: SwitchListTile(
                    value: _notificationsEnabled,
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                    title: Text(l.profileNotificationsEnabled),
                  ),
                ),
                Card(
                  child: SwitchListTile(
                    value: _aiEnabled,
                    onChanged: _isLoadingAiEnabled
                        ? null
                        : (value) async {
                            setState(() => _aiEnabled = value);
                            await AppSettings.instance.setAiEnabled(value);
                          },
                    title: Text(l.profileAiEnabled),
                    subtitle: Text(
                      l.profileAiEnabledHint,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text(l.profileNotificationTime),
                    subtitle: Text(_notificationTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: _isSaving ? null : _pickNotificationTime,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.profileSaveButton),
                ),
                const SizedBox(height: AppSpacing.xs),
                OutlinedButton(
                  onPressed: _isLoggingOut ? null : _logout,
                  child: _isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.profileLogoutButton),
                ),
                const SizedBox(height: AppSpacing.lg),
                // ── Sprint 3: Gemini API Key ──────────────────────────────
                Text(
                  l.profileGeminiApiKey,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _geminiApiKeyController,
                  obscureText: _obscureGeminiKey,
                  decoration: InputDecoration(
                    labelText: l.profileGeminiApiKey,
                    hintText: l.profileGeminiApiKeyHint,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureGeminiKey
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscureGeminiKey = !_obscureGeminiKey);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                OutlinedButton(
                  onPressed: _isSavingGeminiKey ? null : _saveGeminiKey,
                  child: _isSavingGeminiKey
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.profileSaveButton),
                ),
                // ─────────────────────────────────────────────────────────
              ],
            ),
          ),
        ),
      ),
    );
  }
}
