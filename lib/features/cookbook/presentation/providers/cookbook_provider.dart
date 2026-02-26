import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cookbook_repository.dart';
import '../../domain/cookbook_models.dart';

class CookbookState {
  final List<CookbookTemplate> templates;
  final List<CookbookProgress> progress;
  final bool isLoading;
  final String? error;

  const CookbookState({
    this.templates = const [],
    this.progress = const [],
    this.isLoading = false,
    this.error,
  });

  CookbookState copyWith({
    List<CookbookTemplate>? templates,
    List<CookbookProgress>? progress,
    bool? isLoading,
    String? error,
  }) {
    return CookbookState(
      templates: templates ?? this.templates,
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final cookbookProvider =
    StateNotifierProvider<CookbookNotifier, CookbookState>((ref) {
  return CookbookNotifier(ref.watch(cookbookRepositoryProvider));
});

class CookbookNotifier extends StateNotifier<CookbookState> {
  final CookbookRepository _repo;

  CookbookNotifier(this._repo) : super(const CookbookState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    try {
      final templates = await _repo.loadTemplates();
      final progress = await _repo.loadProgress();
      state = CookbookState(templates: templates, progress: progress);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addTemplate(CookbookTemplate template) async {
    final updated = [...state.templates, template];
    await _repo.saveTemplates(updated);
    state = state.copyWith(templates: updated);
  }

  Future<void> updateTemplate(CookbookTemplate template) async {
    final updated = state.templates.map((t) => t.id == template.id ? template : t).toList();
    await _repo.saveTemplates(updated);
    state = state.copyWith(templates: updated);
  }

  Future<void> deleteTemplate(String id) async {
    final updated = state.templates.where((t) => t.id != id).toList();
    await _repo.saveTemplates(updated);
    state = state.copyWith(templates: updated);
  }

  CookbookProgress getOrCreateProgress(String templateId, String characterId) {
    try {
      return state.progress.firstWhere(
        (p) => p.templateId == templateId && p.characterId == characterId,
      );
    } catch (_) {
      return CookbookProgress(templateId: templateId, characterId: characterId);
    }
  }

  Future<void> toggleStep(String templateId, String characterId, String stepId) async {
    var progress = getOrCreateProgress(templateId, characterId);
    final completed = Set<String>.from(progress.completedStepIds);
    if (completed.contains(stepId)) {
      completed.remove(stepId);
    } else {
      completed.add(stepId);
    }
    progress = progress.copyWith(completedStepIds: completed, lastViewedStepId: stepId);

    final allProgress = state.progress
        .where((p) => !(p.templateId == templateId && p.characterId == characterId))
        .toList();
    allProgress.add(progress);
    await _repo.saveProgress(allProgress);
    state = state.copyWith(progress: allProgress);
  }
}
