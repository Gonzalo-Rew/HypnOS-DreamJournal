import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/repositories/social_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';
import 'package:hypnos_dreamjournal/shared/widgets/glass_card.dart';
import 'package:intl/intl.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({
    super.key,
    required this.dreamId,
    required this.dreamTitle,
  });

  final String dreamId;
  final String dreamTitle;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final SocialRepository _social = SocialRepositoryImpl();
  final _commentController = TextEditingController();
  bool _isSending = false;

  String? get _currentUserId => FirebaseService.getCurrentUserId();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final uid = _currentUserId;
    if (uid == null) return;

    setState(() => _isSending = true);

    // Get current user display name
    final userDoc = await FirebaseService.firestore
        .collection('users')
        .doc(uid)
        .get();
    final userName = userDoc.data()?['displayName'] as String? ?? 'Usuario';
    final userPhoto = userDoc.data()?['photoUrl'] as String?;

    final result = await _social.addComment(
      dreamId: widget.dreamId,
      userId: uid,
      userName: userName,
      userPhotoUrl: userPhoto,
      text: text,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (result is Success) {
      _commentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar el comentario'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteComment(String commentId, String commentUserId) async {
    final uid = _currentUserId;
    if (uid == null || uid != commentUserId) return;

    await _social.deleteComment(
      dreamId: widget.dreamId,
      commentId: commentId,
      requestingUserId: uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                      widget.dreamTitle,
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

            // Comments list
            Expanded(
              child: StreamBuilder<List<DreamComment>>(
                stream: _social.getComments(widget.dreamId),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentPrimary,
                      ),
                    );
                  }

                  final comments = snap.data ?? [];

                  if (comments.isEmpty) {
                    return const Center(
                      child: Text(
                        'Sé el primero en comentar',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      final c = comments[i];
                      final isOwn = c.userId == _currentUserId;
                      return GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.accentSecondary
                                  .withValues(alpha: 0.3),
                              backgroundImage: c.userPhotoUrl != null
                                  ? NetworkImage(c.userPhotoUrl!)
                                  : null,
                              child: c.userPhotoUrl == null
                                  ? Text(
                                      c.userName.isNotEmpty
                                          ? c.userName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        c.userName,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        DateFormat(
                                          'd MMM · HH:mm',
                                        ).format(c.createdAt),
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c.text,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isOwn)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                                onPressed: () => _deleteComment(c.id, c.userId),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Comment input
            Container(
              color: const Color(0xFF1E2230),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Escribe un comentario...',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentPrimary,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: AppColors.accentPrimary,
                          ),
                          onPressed: _sendComment,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
