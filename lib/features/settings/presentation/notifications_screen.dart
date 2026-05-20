import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/auth_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/widgets/glass_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AuthRepository _authRepo = AuthRepositoryImpl();

  String? _userId;
  bool _isLoading = true;
  bool _notificationsEnabled = false;
  bool _notifyFollowRequests = true;
  bool _notifyNewFollowers = true;
  bool _notifyFollowingDreams = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _authRepo.getCurrentUser();
    if (!mounted) return;
    if (result is Success<User>) {
      final u = result.value;
      final parts = u.notificationTime.split(':');
      setState(() {
        _userId = u.id;
        _notificationsEnabled = u.notificationsEnabled;
        _notifyFollowRequests = u.notifyFollowRequests;
        _notifyNewFollowers = u.notifyNewFollowers;
        _notifyFollowingDreams = u.notifyFollowingDreams;
        _notificationTime = TimeOfDay(
          hour: int.tryParse(parts.first) ?? 8,
          minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
        );
        _isLoading = false;
      });
    } else {
      _userId = FirebaseService.getCurrentUser()?.uid;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _update(Map<String, dynamic> data) async {
    if (_userId == null) return;
    await FirebaseService.firestore
        .collection('users')
        .doc(_userId)
        .update(data);
  }

  Widget _divider() => const Divider(
    height: 1,
    color: AppColors.borderSubtle,
    indent: AppSpacing.md,
    endIndent: AppSpacing.md,
  );

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
                    'Notificaciones',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                children: [
                  // SUEÑOS
                  _SubLabel(label: 'SUEÑOS'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          title: const Text(
                            'Recordatorio diario',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: const Text(
                            'Recibe un aviso para registrar tus sueños',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          value: _notificationsEnabled,
                          activeColor: AppColors.accentPrimary,
                          onChanged: (v) async {
                            setState(() => _notificationsEnabled = v);
                            await _update({'notificationsEnabled': v});
                          },
                        ),
                        if (_notificationsEnabled) ...[
                          _divider(),
                          ListTile(
                            leading: const Icon(
                              Icons.access_time,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            title: const Text(
                              'Hora del recordatorio',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            trailing: Text(
                              _notificationTime.format(context),
                              style: const TextStyle(
                                color: AppColors.accentPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _notificationTime,
                              );
                              if (picked != null && mounted) {
                                setState(() => _notificationTime = picked);
                                final hh = picked.hour.toString().padLeft(
                                  2,
                                  '0',
                                );
                                final mm = picked.minute.toString().padLeft(
                                  2,
                                  '0',
                                );
                                await _update({'notificationTime': '$hh:$mm'});
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // SOCIAL
                  _SubLabel(label: 'SOCIAL'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: const Icon(
                            Icons.person_add_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          title: const Text(
                            'Solicitudes de seguimiento',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          value: _notifyFollowRequests,
                          activeColor: AppColors.accentPrimary,
                          onChanged: (v) async {
                            setState(() => _notifyFollowRequests = v);
                            await _update({'notifyFollowRequests': v});
                          },
                        ),
                        _divider(),
                        SwitchListTile(
                          secondary: const Icon(
                            Icons.group_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          title: const Text(
                            'Nuevos seguidores',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          value: _notifyNewFollowers,
                          activeColor: AppColors.accentPrimary,
                          onChanged: (v) async {
                            setState(() => _notifyNewFollowers = v);
                            await _update({'notifyNewFollowers': v});
                          },
                        ),
                        _divider(),
                        SwitchListTile(
                          secondary: const Icon(
                            Icons.auto_stories_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          title: const Text(
                            'Sueños de seguidos',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: const Text(
                            'Cuando alguien que sigues publica un sueño',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          value: _notifyFollowingDreams,
                          activeColor: AppColors.accentPrimary,
                          onChanged: (v) async {
                            setState(() => _notifyFollowingDreams = v);
                            await _update({'notifyFollowingDreams': v});
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.xs,
        top: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
