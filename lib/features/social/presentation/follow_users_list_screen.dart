import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/social_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/social/presentation/public_profile_screen.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/widgets/glass_card.dart';

enum FollowUsersListType { followers, following }

class _FollowUserEntry {
  const _FollowUserEntry({required this.user});

  final User user;
}

class FollowUsersListScreen extends StatefulWidget {
  const FollowUsersListScreen({
    super.key,
    required this.userId,
    required this.ownerName,
    required this.type,
  });

  final String userId;
  final String ownerName;
  final FollowUsersListType type;

  @override
  State<FollowUsersListScreen> createState() => _FollowUsersListScreenState();
}

class _FollowUsersListScreenState extends State<FollowUsersListScreen> {
  final SocialRepository _social = SocialRepositoryImpl();
  final Set<String> _removingUserIds = <String>{};

  void _showFeedback(String msg, {bool isError = false}) {
    final accent = isError ? AppColors.error : AppColors.accentPrimary;
    final icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_rounded;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2230).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isOwnFollowersList {
    final currentUserId = FirebaseService.getCurrentUserId();
    return widget.type == FollowUsersListType.followers &&
        currentUserId != null &&
        currentUserId == widget.userId;
  }

  String _title(AppLocalizations l) {
    final label = widget.type == FollowUsersListType.followers
        ? l.profileFollowers
        : l.profileFollowing;
    return '$label de ${widget.ownerName}';
  }

  Query<Map<String, dynamic>> _followQuery() {
    final query = FirebaseService.firestore.collection('follows');
    return widget.type == FollowUsersListType.followers
        ? query.where('followingId', isEqualTo: widget.userId)
        : query.where('followerId', isEqualTo: widget.userId);
  }

  String _otherUserId(Map<String, dynamic> data) {
    return widget.type == FollowUsersListType.followers
        ? (data['followerId'] as String? ?? '')
        : (data['followingId'] as String? ?? '');
  }

  Future<List<_FollowUserEntry>> _loadUsers(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> follows,
  ) async {
    final users = await Future.wait(
      follows.map((doc) async {
        final data = doc.data();
        final otherUserId = _otherUserId(data);
        if (otherUserId.isEmpty) {
          return null;
        }

        final snap = await FirebaseService.firestore
            .collection('users')
            .doc(otherUserId)
            .get();
        if (!snap.exists || snap.data() == null) {
          return null;
        }

        return _FollowUserEntry(
          user: User.fromFirestore(snap.data()!, snap.id),
        );
      }),
    );

    return users.whereType<_FollowUserEntry>().toList();
  }

  Future<void> _removeFollower(User user) async {
    final currentUserId = FirebaseService.getCurrentUserId();
    if (currentUserId == null) return;

    final shouldRemove = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (ctx) => Align(
        alignment: const Alignment(0, -0.24),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2230),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.1),
                  blurRadius: 30,
                  spreadRadius: -6,
                ),
                BoxShadow(
                  color: AppColors.accentPrimary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.error.withValues(alpha: 0.25),
                        AppColors.error.withValues(alpha: 0.12),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.45),
                    ),
                  ),
                  child: const Icon(
                    Icons.person_remove_alt_1_rounded,
                    color: AppColors.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Eliminar seguidor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¿Quieres eliminar a ${user.displayName} de tus seguidores?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.borderSubtle.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          foregroundColor: AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (shouldRemove != true || !mounted) return;

    setState(() => _removingUserIds.add(user.id));
    final result = await _social.removeFollower(
      currentUserId: currentUserId,
      followerUserId: user.id,
    );

    if (!mounted) return;
    setState(() => _removingUserIds.remove(user.id));

    if (result is Failure<void>) {
      _showFeedback('No se pudo eliminar el seguidor.', isError: true);
      return;
    }

    _showFeedback('${user.displayName} eliminado de seguidores');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      _title(l),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _followQuery().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentPrimary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'No se pudo cargar la lista.',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final follows =
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
                        docs,
                      )..sort((a, b) {
                        final aData = a.data();
                        final bData = b.data();
                        final aTime =
                            (aData['createdAt'] as dynamic)?.toDate()
                                as DateTime?;
                        final bTime =
                            (bData['createdAt'] as dynamic)?.toDate()
                                as DateTime?;
                        return (bTime ?? DateTime.fromMillisecondsSinceEpoch(0))
                            .compareTo(
                              aTime ?? DateTime.fromMillisecondsSinceEpoch(0),
                            );
                      });

                  if (follows.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.35,
                            ),
                            size: 56,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            widget.type == FollowUsersListType.followers
                                ? 'Aun no hay seguidores.'
                                : 'Aun no sigue a nadie.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return FutureBuilder<List<_FollowUserEntry>>(
                    future: _loadUsers(follows),
                    builder: (context, usersSnap) {
                      if (usersSnap.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentPrimary,
                          ),
                        );
                      }

                      final users = usersSnap.data ?? [];

                      if (users.isEmpty) {
                        return const Center(
                          child: Text(
                            'No se pudo resolver la lista de usuarios.',
                            style: TextStyle(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: users.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final entry = users[index];
                          final user = entry.user;
                          final isRemoving = _removingUserIds.contains(user.id);

                          return GlassCard(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.accentSecondary
                                    .withValues(alpha: 0.25),
                                backgroundImage: user.photoUrl != null
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                child: user.photoUrl == null
                                    ? Text(
                                        user.displayName.isNotEmpty
                                            ? user.displayName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                user.displayName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: user.username != null
                                  ? Text(
                                      '@${user.username}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  : null,
                              trailing: _isOwnFollowersList
                                  ? PopupMenuButton<String>(
                                      enabled: !isRemoving,
                                      color: AppColors.surfaceGlass,
                                      icon: isRemoving
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.accentPrimary,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.more_horiz,
                                              color: AppColors.textSecondary,
                                            ),
                                      onSelected: (value) {
                                        if (value == 'view') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PublicProfileScreen(
                                                    userId: user.id,
                                                  ),
                                            ),
                                          );
                                          return;
                                        }
                                        if (value == 'remove') {
                                          _removeFollower(user);
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem<String>(
                                          value: 'view',
                                          child: Text('Ver perfil'),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'remove',
                                          child: Text('Eliminar seguidor'),
                                        ),
                                      ],
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.textSecondary,
                                      size: 14,
                                    ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PublicProfileScreen(userId: user.id),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
