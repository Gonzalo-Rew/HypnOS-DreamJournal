import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/user_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/social_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/social/presentation/comments_screen.dart';

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
    switch (followState) {
      case 'following':
        await _social.unfollow(
          currentUserId: myId,
          targetUserId: widget.userId,
        );
      case 'pending':
        await _social.cancelFollowRequest(
          currentUserId: myId,
          targetUserId: widget.userId,
        );
      case 'none':
      default:
        await _social.sendFollowRequest(
          currentUserId: myId,
          targetUserId: widget.userId,
        );
    }
    if (mounted) setState(() => _isFollowLoading = false);
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
                                  _Stat(
                                    count: profileUser.followersCount,
                                    label: 'seguidores',
                                  ),
                                  const SizedBox(width: AppSpacing.xl),
                                  _Stat(
                                    count: profileUser.followingCount,
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

class _Stat extends StatelessWidget {
  const _Stat({required this.count, required this.label});
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
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
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final data = docs[i].data();
            final dreamId = docs[i].id;
            final title = data['title'] as String? ?? 'Sueño';
            final preview = (data['content'] as String? ?? '').take(120);
            final likesCount = data['likesCount'] as int? ?? 0;
            final commentsCount = data['commentsCount'] as int? ?? 0;

            return Container(
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
                  Row(
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
                      const SizedBox(width: AppSpacing.md),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommentsScreen(
                              dreamId: dreamId,
                              dreamTitle: title,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$commentsCount',
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
            );
          },
        );
      },
    );
  }
}

extension on String {
  String take(int n) => length <= n ? this : substring(0, n);
}
