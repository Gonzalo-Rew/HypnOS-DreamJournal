import 'package:flutter/material.dart';
import 'package:hypnos_dreamjournal/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:hypnos_dreamjournal/app/theme/app_colors.dart';
import 'package:hypnos_dreamjournal/app/theme/app_dimensions.dart';
import 'package:hypnos_dreamjournal/data/models/dream_model.dart';
import 'package:hypnos_dreamjournal/data/repositories/dream_repository.dart';
import 'package:hypnos_dreamjournal/data/services/firebase_service.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_detail_screen.dart';
import 'package:hypnos_dreamjournal/features/dreams/presentation/dream_form_screen.dart';
import 'package:hypnos_dreamjournal/shared/errors/result.dart';

class DreamsListScreen extends StatefulWidget {
  const DreamsListScreen({super.key});

  @override
  State<DreamsListScreen> createState() => _DreamsListScreenState();
}

class _DreamsListScreenState extends State<DreamsListScreen> {
  final DreamRepository _dreamRepository = DreamRepositoryImpl();

  bool _isLoading = true;
  String? _errorMessage;
  List<Dream> _dreams = const [];

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    final userId = FirebaseService.getCurrentUserId();
    if (userId == null) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      setState(() {
        _isLoading = false;
        _errorMessage = l.dreamsListNotLoggedIn;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _dreamRepository.getDreamsByUser(userId: userId);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      if (result is Success<List<Dream>>) {
        _dreams = result.value;
      } else {
        _errorMessage = (result as Failure<List<Dream>>).exception.toString();
      }
    });
  }

  Future<void> _openNewDream() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const DreamFormScreen()),
    );
    if (created == true) {
      await _loadDreams();
    }
  }

  Future<void> _openDetail(Dream dream) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DreamDetailScreen(dream: dream)),
    );

    if (changed == true) {
      await _loadDreams();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.dreamsListTitle),
        actions: [
          IconButton(onPressed: _loadDreams, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l.dreamsListTooltipCreate,
        onPressed: _openNewDream,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton(
                        onPressed: _loadDreams,
                        child: Text(l.dreamsListRetry),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (_dreams.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l.dreamsListEmpty),
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton(
                        onPressed: _openNewDream,
                        child: Text(l.dreamsListCreateFirst),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.sm),
              itemCount: _dreams.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final dream = _dreams[index];
                final moodLabel = dream.moodScore != null
                    ? l.dreamsListMoodLabel(dream.moodScore.toString())
                    : l.dreamsListMoodNoScore;
                return Card(
                  child: ListTile(
                    title: Text(dream.title),
                    subtitle: Text(
                      '${DateFormat.yMMMd().format(dream.dreamDate)} | $moodLabel',
                    ),
                    onTap: () => _openDetail(dream),
                    trailing: dream.tags.contains('favorite')
                        ? const Icon(Icons.star, color: AppColors.warning)
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
