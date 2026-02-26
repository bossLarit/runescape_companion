import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/goal_model.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository(ref.watch(localStorageServiceProvider));
});

class GoalRepository {
  final LocalStorageService _storage;

  GoalRepository(this._storage);

  Future<List<Goal>> loadAll() async {
    final data = await _storage.loadJson(AppConstants.goalsFile);
    if (data == null) return [];
    final list = data as List<dynamic>;
    return list.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAll(List<Goal> goals) async {
    await _storage.saveJson(AppConstants.goalsFile, goals.map((g) => g.toJson()).toList());
  }

  Future<void> add(Goal goal) async {
    final all = await loadAll();
    all.add(goal);
    await saveAll(all);
  }

  Future<void> update(Goal goal) async {
    final all = await loadAll();
    final index = all.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      all[index] = goal;
      await saveAll(all);
    }
  }

  Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((g) => g.id == id);
    await saveAll(all);
  }

  Future<List<Goal>> loadForCharacter(String characterId) async {
    final all = await loadAll();
    return all.where((g) => g.characterId == characterId).toList();
  }
}
