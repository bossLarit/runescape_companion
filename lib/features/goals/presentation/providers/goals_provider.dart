import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/goal_repository.dart';
import '../../domain/goal_model.dart';
import '../../../characters/presentation/providers/characters_provider.dart';

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, AsyncValue<List<Goal>>>((ref) {
  return GoalsNotifier(ref.watch(goalRepositoryProvider));
});

final activeCharacterGoalsProvider = Provider<List<Goal>>((ref) {
  final activeChar = ref.watch(activeCharacterProvider);
  final goals = ref.watch(goalsProvider);
  if (activeChar == null) return [];
  return goals.whenOrNull(
        data: (list) => list.where((g) => g.characterId == activeChar.id).toList(),
      ) ??
      [];
});

class GoalsNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  final GoalRepository _repo;

  GoalsNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final goals = await _repo.loadAll();
      state = AsyncValue.data(goals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Goal goal) async {
    try {
      await _repo.add(goal);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(Goal goal) async {
    try {
      await _repo.update(goal);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.delete(id);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
