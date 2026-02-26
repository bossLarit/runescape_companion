import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/goal_planner_repository.dart';
import '../../data/osrs_goals_data.dart';
import '../../domain/goal_node_model.dart';
import '../../domain/planner_logic.dart';
import '../../../characters/presentation/providers/characters_provider.dart';

class GoalPlannerState {
  final List<GoalNode> nodes;
  final List<GoalDependency> dependencies;
  final bool isLoading;
  final String? error;
  final Set<String> completedOsrsGoalIds;
  final Set<String> savedGoalIds;

  const GoalPlannerState({
    this.nodes = const [],
    this.dependencies = const [],
    this.isLoading = false,
    this.error,
    this.completedOsrsGoalIds = const {},
    this.savedGoalIds = const {},
  });

  GoalPlannerState copyWith({
    List<GoalNode>? nodes,
    List<GoalDependency>? dependencies,
    bool? isLoading,
    String? error,
    Set<String>? completedOsrsGoalIds,
    Set<String>? savedGoalIds,
  }) {
    return GoalPlannerState(
      nodes: nodes ?? this.nodes,
      dependencies: dependencies ?? this.dependencies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      completedOsrsGoalIds: completedOsrsGoalIds ?? this.completedOsrsGoalIds,
      savedGoalIds: savedGoalIds ?? this.savedGoalIds,
    );
  }
}

final goalPlannerProvider =
    StateNotifierProvider<GoalPlannerNotifier, GoalPlannerState>((ref) {
  return GoalPlannerNotifier(ref.watch(goalPlannerRepositoryProvider));
});

final nextBestGoalsProvider = Provider<List<GoalNode>>((ref) {
  final state = ref.watch(goalPlannerProvider);
  final activeChar = ref.watch(activeCharacterProvider);
  if (activeChar == null) return [];
  final charNodes =
      state.nodes.where((n) => n.characterId == activeChar.id).toList();
  return PlannerLogic.getNextBestGoals(charNodes, state.dependencies);
});

class GoalPlannerNotifier extends StateNotifier<GoalPlannerState> {
  final GoalPlannerRepository _repo;

  GoalPlannerNotifier(this._repo)
      : super(const GoalPlannerState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    try {
      final nodes = await _repo.loadNodes();
      final deps = await _repo.loadDependencies();
      final completed = await _repo.loadCompletedOsrsGoals();
      final saved = await _repo.loadSavedOsrsGoals();
      state = GoalPlannerState(
        nodes: nodes,
        dependencies: deps,
        completedOsrsGoalIds: completed,
        savedGoalIds: saved,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addNode(GoalNode node) async {
    final updated = [...state.nodes, node];
    await _repo.saveNodes(updated);
    state = state.copyWith(
        nodes: PlannerLogic.updateStatuses(updated, state.dependencies));
  }

  Future<void> updateNode(GoalNode node) async {
    final updated = state.nodes.map((n) => n.id == node.id ? node : n).toList();
    await _repo.saveNodes(updated);
    state = state.copyWith(
        nodes: PlannerLogic.updateStatuses(updated, state.dependencies));
  }

  Future<void> deleteNode(String id) async {
    final updatedNodes = state.nodes.where((n) => n.id != id).toList();
    final updatedDeps = state.dependencies
        .where((d) => d.parentGoalId != id && d.dependencyGoalId != id)
        .toList();
    await _repo.saveNodes(updatedNodes);
    await _repo.saveDependencies(updatedDeps);
    state = state.copyWith(
      nodes: PlannerLogic.updateStatuses(updatedNodes, updatedDeps),
      dependencies: updatedDeps,
    );
  }

  Future<void> addDependency(GoalDependency dep) async {
    final updated = [...state.dependencies, dep];
    await _repo.saveDependencies(updated);
    state = state.copyWith(
      dependencies: updated,
      nodes: PlannerLogic.updateStatuses(state.nodes, updated),
    );
  }

  Future<void> removeDependency(String depId) async {
    final updated = state.dependencies.where((d) => d.id != depId).toList();
    await _repo.saveDependencies(updated);
    state = state.copyWith(
      dependencies: updated,
      nodes: PlannerLogic.updateStatuses(state.nodes, updated),
    );
  }

  Future<void> markCompleted(String nodeId) async {
    final updated = state.nodes.map((n) {
      if (n.id == nodeId) return n.copyWith(status: GoalNodeStatus.completed);
      return n;
    }).toList();
    await _repo.saveNodes(updated);
    state = state.copyWith(
        nodes: PlannerLogic.updateStatuses(updated, state.dependencies));
  }

  Future<void> markInProgress(String nodeId) async {
    final updated = state.nodes.map((n) {
      if (n.id == nodeId) return n.copyWith(status: GoalNodeStatus.inProgress);
      return n;
    }).toList();
    await _repo.saveNodes(updated);
    state = state.copyWith(nodes: updated);
  }

  Future<void> toggleOsrsGoal(String goalId) async {
    final updated = {...state.completedOsrsGoalIds};
    final isCompleting = !updated.contains(goalId);

    if (isCompleting) {
      // Mark this goal and all cascaded children as complete
      updated.add(goalId);
      final children = expandCascade(goalId);
      updated.addAll(children);

      // Auto-check parent goals if all their children are now complete
      for (final parentId in findParentGoals(goalId)) {
        final allChildren = expandCascade(parentId);
        if (allChildren.every((c) => updated.contains(c))) {
          updated.add(parentId);
        }
      }
    } else {
      // Uncheck this goal and all cascaded children
      updated.remove(goalId);
      final children = expandCascade(goalId);
      updated.removeAll(children);

      // Also uncheck any parent that depended on this goal
      for (final parentId in findParentGoals(goalId)) {
        updated.remove(parentId);
      }
    }

    state = state.copyWith(completedOsrsGoalIds: updated);
    await _repo.saveCompletedOsrsGoals(updated);
  }

  Future<void> toggleSavedGoal(String goalId) async {
    final updated = {...state.savedGoalIds};
    if (updated.contains(goalId)) {
      updated.remove(goalId);
    } else {
      updated.add(goalId);
    }
    state = state.copyWith(savedGoalIds: updated);
    await _repo.saveSavedOsrsGoals(updated);
  }
}
