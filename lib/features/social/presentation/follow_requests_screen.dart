import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/repositories/social_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/social/presentation/public_profile_screen.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:hypnos_dreamjournal/shared/errors/error_messages.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';

class FollowRequestsScreen extends StatelessWidget {
  const FollowRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final myId = FirebaseService.getCurrentUser()?.uid;
    if (myId == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: Text(
            l.socialFollowRequestsNotLoggedIn,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final social = SocialRepositoryImpl();

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
                    l.socialFollowRequestsTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<FollowRequest>>(
                stream: social.getIncomingFollowRequests(myId),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentPrimary,
                      ),
                    );
                  }

                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Text(
                          l.socialFollowRequestsLoadError,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final requests = snap.data ?? [];

                  if (requests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.4,
                            ),
                            size: 54,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l.socialFollowRequestsEmpty,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, i) {
                      final req = requests[i];
                      return _FollowRequestTile(
                        request: req,
                        social: social,
                        myId: myId,
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

// ─── Tile ─────────────────────────────────────────────────────────────────────

class _FollowRequestTile extends StatefulWidget {
  const _FollowRequestTile({
    required this.request,
    required this.social,
    required this.myId,
  });

  final FollowRequest request;
  final SocialRepositoryImpl social;
  final String myId;

  @override
  State<_FollowRequestTile> createState() => _FollowRequestTileState();
}

class _FollowRequestTileState extends State<_FollowRequestTile> {
  bool _isLoading = false;

  Future<void> _accept() async {
    setState(() => _isLoading = true);
    final result = await widget.social.acceptFollowRequest(
      requestId: widget.request.id,
      requesterId: widget.request.requesterId,
      targetUserId: widget.myId,
    );
    if (!mounted) return;
    if (result is Failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppError.handle(result, 'AcceptRequest'),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _decline() async {
    setState(() => _isLoading = true);
    await widget.social.declineFollowRequest(widget.request.id);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PublicProfileScreen(userId: widget.request.requesterId),
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.accentPrimary.withValues(alpha: 0.2),
              backgroundImage: widget.request.requesterPhotoUrl != null
                  ? NetworkImage(widget.request.requesterPhotoUrl!)
                  : null,
              child: widget.request.requesterPhotoUrl == null
                  ? Text(
                      widget.request.requesterName.isNotEmpty
                          ? widget.request.requesterName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Name
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PublicProfileScreen(userId: widget.request.requesterId),
                ),
              ),
              child: Text(
                widget.request.requesterName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Action buttons
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accentPrimary,
              ),
            )
          else ...[
            // Confirm
            FilledButton(
              onPressed: _accept,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentPrimary,
                foregroundColor: AppColors.bgPrimary,
                minimumSize: const Size(72, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: const StadiumBorder(),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(
                AppLocalizations.of(context).socialFollowRequestsAccept,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),

            // Decline
            OutlinedButton(
              onPressed: _decline,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
                minimumSize: const Size(72, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: const StadiumBorder(),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(
                AppLocalizations.of(context).socialFollowRequestsDecline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
