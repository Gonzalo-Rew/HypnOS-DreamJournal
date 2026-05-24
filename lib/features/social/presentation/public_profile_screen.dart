import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/social_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/social/presentation/follow_users_list_screen.dart';
import 'package:hypnos_dreamjournal/shared/widgets/audio_player_widget.dart';
import 'package:intl/intl.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final SocialRepositoryImpl _social = SocialRepositoryImpl();
  String? _currentUserId;
  bool _isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseService.getCurrentUser()?.uid;
  }

  Future<void> _handleFollowAction(String followState) async {
    final myId = _currentUserId;
    if (myId == null) return;
    setState(() => _isFollowLoading = true);
    try {
      switch (followState) {
        case 'following':
          await _social.unfollow(
            currentUserId: myId,
            targetUserId: widget.userId,
          );
          break;
        case 'pending':
          await _social.cancelFollowRequest(
            currentUserId: myId,
            targetUserId: widget.userId,
          );
          break;
        case 'none':
        default:
          await _social.sendFollowRequest(
            currentUserId: myId,
            targetUserId: widget.userId,
          );
          break;
      }
    } finally {
      if (mounted) setState(() => _isFollowLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = _currentUserId;
    final isSelf = myId == widget.userId;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseService.firestore
              .collection('users')
              .doc(widget.userId)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentPrimary,
                ),
              );
            }
            if (!snap.hasData || !snap.data!.exists) {
              return _buildNotFound(context);
            }

            final profileUser = User.fromFirestore(
              snap.data!.data()!,
              snap.data!.id,
            );

            return Column(
              children: [
                // ── Header ────────────────────────────────────────────────
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
                        profileUser.displayName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body ──────────────────────────────────────────────────
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Profile header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Column(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 44,
                                backgroundColor: AppColors.accentSecondary
                                    .withValues(alpha: 0.3),
                                backgroundImage: profileUser.photoUrl != null
                                    ? NetworkImage(profileUser.photoUrl!)
                                    : null,
                                child: profileUser.photoUrl == null
                                    ? Text(
                                        profileUser.displayName.isNotEmpty
                                            ? profileUser.displayName[0]
                                                  .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              Text(
                                profileUser.displayName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              if (profileUser.username != null)
                                Text(
                                  '@${profileUser.username}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),

                              const SizedBox(height: AppSpacing.md),

                              // Follower stats
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _LiveFollowStat(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FollowUsersListScreen(
                                          userId: widget.userId,
                                          ownerName: profileUser.displayName,
                                          type: FollowUsersListType.followers,
                                        ),
                                      ),
                                    ),
                                    query: FirebaseService.firestore
                                        .collection('follows')
                                        .where(
                                          'followingId',
                                          isEqualTo: widget.userId,
                                        ),
                                    fallbackCount: profileUser.followersCount,
                                    label: 'seguidores',
                                  ),
                                  const SizedBox(width: AppSpacing.xl),
                                  _LiveFollowStat(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FollowUsersListScreen(
                                          userId: widget.userId,
                                          ownerName: profileUser.displayName,
                                          type: FollowUsersListType.following,
                                        ),
                                      ),
                                    ),
                                    query: FirebaseService.firestore
                                        .collection('follows')
                                        .where(
                                          'followerId',
                                          isEqualTo: widget.userId,
                                        ),
                                    fallbackCount: profileUser.followingCount,
                                    label: 'siguiendo',
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Follow/Unfollow button (not shown for self)
                              if (!isSelf && myId != null)
                                StreamBuilder<String>(
                                  stream: _social.getFollowState(
                                    currentUserId: myId,
                                    targetUserId: widget.userId,
                                  ),
                                  builder: (ctx, snap) {
                                    final state = snap.data ?? 'none';
                                    final isFollowing = state == 'following';
                                    final isPending = state == 'pending';
                                    return SizedBox(
                                      width: 160,
                                      height: 38,
                                      child: FilledButton(
                                        onPressed: _isFollowLoading
                                            ? null
                                            : () => _handleFollowAction(state),
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              isFollowing || isPending
                                              ? Colors.white.withValues(
                                                  alpha: 0.08,
                                                )
                                              : AppColors.accentPrimary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.md,
                                            ),
                                            side: isFollowing || isPending
                                                ? const BorderSide(
                                                    color:
                                                        AppColors.borderSubtle,
                                                  )
                                                : BorderSide.none,
                                          ),
                                        ),
                                        child: _isFollowLoading
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      color:
                                                          AppColors.textPrimary,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                isFollowing
                                                    ? 'Siguiendo'
                                                    : isPending
                                                    ? 'Solicitado'
                                                    : 'Seguir',
                                                style: TextStyle(
                                                  color:
                                                      isFollowing || isPending
                                                      ? AppColors.textPrimary
                                                      : AppColors.bgPrimary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Divider
                      const SliverToBoxAdapter(
                        child: Divider(
                          height: 1,
                          color: AppColors.borderSubtle,
                        ),
                      ),

                      // Content based on visibility
                      if (profileUser.dreamVisibility == 'private' && !isSelf)
                        _buildPrivateSliver()
                      else if (profileUser.dreamVisibility == 'followers' &&
                          !isSelf &&
                          myId != null)
                        _buildFollowersGatedSliver(myId, profileUser)
                      else
                        _buildDreamsSliver(profileUser),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Align(
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
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Usuario no encontrado',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivateSliver() {
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 48),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Esta cuenta es privada',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Sigue esta cuenta para ver sus sueños.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowersGatedSliver(String myId, User profileUser) {
    return SliverFillRemaining(
      child: Center(
        child: StreamBuilder<bool>(
          stream: _social.isFollowing(
            currentUserId: myId,
            targetUserId: widget.userId,
          ),
          builder: (_, snap) {
            final isFollowing = snap.data ?? false;
            if (isFollowing) {
              return _DreamsListView(userId: widget.userId, social: _social);
            }
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: AppColors.textSecondary,
                  size: 48,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Sigue esta cuenta para ver sus sueños.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDreamsSliver(User profileUser) {
    return SliverFillRemaining(
      child: _DreamsListView(userId: widget.userId, social: _social),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _LiveFollowStat extends StatelessWidget {
  const _LiveFollowStat({
    this.onTap,
    required this.query,
    required this.fallbackCount,
    required this.label,
  });

  final VoidCallback? onTap;
  final Query<Map<String, dynamic>> query;
  final int fallbackCount;
  final String label;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? fallbackCount;
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DreamsListView extends StatelessWidget {
  const _DreamsListView({required this.userId, required this.social});
  final String userId;
  final SocialRepositoryImpl social;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: social.getPublicDreamsByUser(userId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accentPrimary),
          );
        }
        final docs = snap.data ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Sin sueños publicados aún.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: docs.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final data = docs[i].data();
            final dreamId = docs[i].id;
            final title = data['title'] as String? ?? 'Sueño';
            final preview =
                (data['text'] as String? ?? data['content'] as String? ?? '')
                    .takeWithEllipsis(120);
            final audioPaths = List<String>.from(
              data['audioPaths'] as List? ?? const [],
            );
            final dreamDate =
                (data['dreamDate'] as dynamic)?.toDate() as DateTime?;

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _PublicDreamDetailScreen(
                    dreamId: dreamId,
                    title: title,
                    description:
                        data['text'] as String? ??
                        data['content'] as String? ??
                        '',
                    dreamDate: dreamDate,
                    audioPaths: audioPaths,
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseService.firestore
                          .collection('publicDreams')
                          .doc(dreamId)
                          .collection('likes')
                          .snapshots(),
                      builder: (context, likesSnap) {
                        final likesCount = likesSnap.data?.docs.length ?? 0;
                        return Row(
                          children: [
                            const Icon(
                              Icons.favorite_outline,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$likesCount',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

extension on String {
  String takeWithEllipsis(int n) =>
      length <= n ? this : '${substring(0, n)}...';
}

class _PublicDreamDetailScreen extends StatelessWidget {
  const _PublicDreamDetailScreen({
    required this.dreamId,
    required this.title,
    required this.description,
    required this.dreamDate,
    required this.audioPaths,
  });

  final String dreamId;
  final String title;
  final String description;
  final DateTime? dreamDate;
  final List<String> audioPaths;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (dreamDate != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('d MMM yyyy, HH:mm').format(dreamDate!),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                description.isNotEmpty ? description : '-',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PublicLikeBar(dreamId: dreamId),
            if (audioPaths.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Audios',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              for (var i = 0; i < audioPaths.length; i++) ...[
                const SizedBox(height: AppSpacing.xs),
                if (audioPaths.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'Audio ${i + 1}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                AudioPlayerWidget(remoteUrl: audioPaths[i]),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _PublicLikeBar extends StatefulWidget {
  const _PublicLikeBar({required this.dreamId});

  final String dreamId;

  @override
  State<_PublicLikeBar> createState() => _PublicLikeBarState();
}

class _PublicLikeBarState extends State<_PublicLikeBar> {
  final SocialRepository _social = SocialRepositoryImpl();
  bool _isSaving = false;

  Future<void> _toggleLike(bool isLiked) async {
    final uid = FirebaseService.getCurrentUserId();
    if (uid == null) return;

    setState(() => _isSaving = true);
    if (isLiked) {
      await _social.unlikeDream(userId: uid, dreamId: widget.dreamId);
    } else {
      await _social.likeDream(userId: uid, dreamId: widget.dreamId);
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseService.getCurrentUserId() ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          if (uid.isNotEmpty)
            StreamBuilder<bool>(
              stream: _social.isDreamLiked(
                userId: uid,
                dreamId: widget.dreamId,
              ),
              builder: (_, snap) {
                final isLiked = snap.data ?? false;
                return GestureDetector(
                  onTap: _isSaving ? null : () => _toggleLike(isLiked),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.error,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          isLiked ? Icons.favorite : Icons.favorite_outline,
                          color: isLiked
                              ? AppColors.error
                              : AppColors.textSecondary,
                          size: 22,
                        ),
                );
              },
            ),
          const SizedBox(width: 6),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseService.firestore
                .collection('publicDreams')
                .doc(widget.dreamId)
                .collection('likes')
                .snapshots(),
            builder: (_, snap) {
              final likes = snap.data?.docs.length ?? 0;
              return Text(
                '$likes',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
