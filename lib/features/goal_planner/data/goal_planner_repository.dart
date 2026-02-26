import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/goal_node_model.dart';

const _completedOsrsGoalsFile = 'completed_osrs_goals.json';
const _savedOsrsGoalsFile = 'saved_osrs_goals.json';

final goalPlannerRepositoryProvider = Provider<GoalPlannerRepository>((ref) {
  return GoalPlannerRepository(ref.watch(localStorageServiceProvider));
});

class GoalPlannerRepository {
  final LocalStorageService _storage;

  GoalPlannerRepository(this._storage);

  Future<List<GoalNode>> loadNodes() async {
    final data = await _storage.loadJson(AppConstants.goalNodesFile);
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((e) => GoalNode.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveNodes(List<GoalNode> nodes) async {
    await _storage.saveJson(
        AppConstants.goalNodesFile, nodes.map((n) => n.toJson()).toList());
  }

  Future<List<GoalDependency>> loadDependencies() async {
    final data = await _storage.loadJson(AppConstants.dependenciesFile);
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((e) => GoalDependency.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDependencies(List<GoalDependency> deps) async {
    await _storage.saveJson(
        AppConstants.dependenciesFile, deps.map((d) => d.toJson()).toList());
  }

  Future<Set<String>> loadCompletedOsrsGoals() async {
    final data = await _storage.loadJson(_completedOsrsGoalsFile);
    if (data is List) {
      return data.cast<String>().toSet();
    }
    return {};
  }

  Future<void> saveCompletedOsrsGoals(Set<String> ids) async {
    await _storage.saveJson(_completedOsrsGoalsFile, ids.toList()..sort());
  }

  Future<Set<String>> loadSavedOsrsGoals() async {
    final data = await _storage.loadJson(_savedOsrsGoalsFile);
    if (data is List) {
      return data.cast<String>().toSet();
    }
    return {};
  }

  Future<void> saveSavedOsrsGoals(Set<String> ids) async {
    await _storage.saveJson(_savedOsrsGoalsFile, ids.toList()..sort());
  }
}
