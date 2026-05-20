import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/auth_repository.dart';
import 'package:hypnos_dreamjournal/data/repositories/social_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_detail_screen.dart';
import 'package:hypnos_dreamjournal/features/settings/presentation/settings_screen.dart';
import 'package:hypnos_dreamjournal/features/social/presentation/comments_screen.dart';
import 'package:hypnos_dreamjournal/features/social/presentation/follow_requests_screen.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/widgets/glass_card.dart';
import 'package:hypnos_dreamjournal/shared/widgets/hypnos_app_bar.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _authRepo = AuthRepositoryImpl();
  final SocialRepository _social = SocialRepositoryImpl();

  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final result = await _authRepo.getCurrentUser();
    if (!mounted) return;
    if (result is Success<User>) {
      setState(() {
        _currentUser = result.value;
        _isLoading = false;
      });
    } else {
      final authUser = FirebaseService.getCurrentUser();
      if (authUser != null) {
        setState(() {
          _currentUser = User(
            id: authUser.uid,
            email: authUser.email ?? '',
            displayName:
                authUser.displayName ?? authUser.email?.split('@').first ?? '',
            createdAt: DateTime.now(),
            aiEnabled: true,
            timezone: 'UTC',
            notificationsEnabled: false,
            notificationTime: '08:00',
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SettingsScreen()))
        .then((_) => _loadProfile());
  }

  void _openDreamDetail(Dream dream) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DreamDetailScreen(dream: dream)));
  }

  void _openComments(String dreamId, String dreamTitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CommentsScreen(dreamId: dreamId, dreamTitle: dreamTitle),
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

    final user = _currentUser;
    final uid = user?.id ?? FirebaseService.getCurrentUserId() ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            HypnosAppBar(
              onSettingsTap: _openSettings,
              extraActions: [
                StreamBuilder<int>(
                  stream: _social.pendingFollowRequestCount(uid),
                  builder: (context, snap) {
                    final count = snap.data ?? 0;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.people_outlined,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FollowRequestsScreen(),
                            ),
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.accentPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  count > 9 ? '9+' : '$count',
                                  style: const TextStyle(
                                    color: AppColors.bgPrimary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseService.firestore
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, userSnap) {
                  User? liveUser = user;
                  if (userSnap.hasData && userSnap.data!.exists) {
                    liveUser = User.fromFirestore(
                      userSnap.data!.data()!,
                      userSnap.data!.id,
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accentPrimary,
                    backgroundColor: const Color(0xFF1E2230),
                    onRefresh: _loadProfile,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _ProfileHeader(
                            user: liveUser,
                            onEditTap: _openSettings,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              AppSpacing.lg,
                              AppSpacing.md,
                              AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.auto_stories_outlined,
                                  color: AppColors.accentPrimary,
                                  size: 18,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                const Text(
                                  'Sueños publicados',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        StreamBuilder<
                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                        >(
                          stream: _social.getPublicDreamsByUser(uid),
                          builder: (context, dreamSnap) {
                            if (dreamSnap.connectionState ==
                                ConnectionState.waiting) {
                              return const SliverToBoxAdapter(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(AppSpacing.lg),
                                    child: CircularProgressIndicator(
                                      color: AppColors.accentPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final docs = dreamSnap.data ?? [];

                            if (docs.isEmpty) {
                              return SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.bedtime_outlined,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.4),
                                        size: 48,
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      const Text(
                                        'Todavía no has publicado ningún sueño',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                i,
                              ) {
                                final data = docs[i].data();
                                final dreamId = docs[i].id;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  child: _PublicDreamCard(
                                    dreamId: dreamId,
                                    data: data,
                                    currentUserId: uid,
                                    social: _social,
                                    onCommentsTap: () => _openComments(
                                      dreamId,
                                      data['title'] as String? ?? '',
                                    ),
                                    onTap: () {
                                      final dream = Dream.fromFirestore(
                                        data,
                                        dreamId,
                                        uid,
                                      );
                                      _openDreamDetail(dream);
                                    },
                                  ),
                                );
                              }, childCount: docs.length),
                            );
                          },
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.xl),
                        ),
                      ],
                    ),
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

// ─── Profile header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.onEditTap});

  final User? user;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final u = user;
    final initials =
        (u?.displayName.isNotEmpty == true ? u!.displayName[0] : '?')
            .toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.accentSecondary.withValues(alpha: 0.3),
            backgroundImage: u?.photoUrl != null
                ? NetworkImage(u!.photoUrl!)
                : null,
            child: u?.photoUrl == null
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
          const SizedBox(height: AppSpacing.sm),
          Text(
            u?.displayName ?? '—',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (u?.username != null || u?.email != null)
            Text(
              u?.username != null
                  ? '@${u!.username}'
                  : u!.email.split('@').first,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(count: u?.followersCount ?? 0, label: 'Seguidores'),
              const SizedBox(width: AppSpacing.lg),
              _StatChip(count: u?.followingCount ?? 0, label: 'Siguiendo'),
              const SizedBox(width: AppSpacing.lg),
              FutureBuilder<AggregateQuerySnapshot>(
                future: FirebaseService.firestore
                    .collection('dreams')
                    .where('userId', isEqualTo: u?.id ?? '')
                    .count()
                    .get(),
                builder: (_, snap) {
                  final count = snap.data?.count ?? 0;
                  return _StatChip(count: count, label: 'Sueños');
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onEditTap,
            icon: const Icon(
              Icons.edit_outlined,
              size: 16,
              color: AppColors.accentPrimary,
            ),
            label: const Text(
              'Editar perfil',
              style: TextStyle(color: AppColors.accentPrimary, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.accentPrimary, width: 1),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.count, required this.label});
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

// ─── Public dream card ────────────────────────────────────────────────────────

class _PublicDreamCard extends StatelessWidget {
  const _PublicDreamCard({
    required this.dreamId,
    required this.data,
    required this.currentUserId,
    required this.social,
    required this.onCommentsTap,
    required this.onTap,
  });

  final String dreamId;
  final Map<String, dynamic> data;
  final String currentUserId;
  final SocialRepository social;
  final VoidCallback onCommentsTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? '';
    final text = data['text'] as String? ?? '';
    final likesCount = data['likesCount'] as int? ?? 0;
    final commentsCount = data['commentsCount'] as int? ?? 0;
    final publishedAt = (data['publishedAt'] as dynamic)?.toDate() as DateTime?;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (publishedAt != null)
                  Text(
                    DateFormat('d MMM').format(publishedAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            if (text.isNotEmpty)
              Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                StreamBuilder<bool>(
                  stream: social.isDreamLiked(
                    userId: currentUserId,
                    dreamId: dreamId,
                  ),
                  builder: (context, snap) {
                    final liked = snap.data ?? false;
                    return GestureDetector(
                      onTap: () async {
                        if (liked) {
                          await social.unlikeDream(
                            userId: currentUserId,
                            dreamId: dreamId,
                          );
                        } else {
                          await social.likeDream(
                            userId: currentUserId,
                            dreamId: dreamId,
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            color: liked
                                ? AppColors.error
                                : AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            likesCount.toString(),
                            style: TextStyle(
                              color: liked
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.md),
                GestureDetector(
                  onTap: onCommentsTap,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        commentsCount.toString(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
