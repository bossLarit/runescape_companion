import 'goal_node_model.dart';

class PlannerLogic {
  /// Compute which goals are available (all required deps completed)
  static List<GoalNode> computeAvailableGoals(
    List<GoalNode> nodes,
    List<GoalDependency> dependencies,
  ) {
    final completedIds = nodes
        .where((n) => n.status == GoalNodeStatus.completed)
        .map((n) => n.id)
        .toSet();

    return nodes.where((node) {
      if (node.status == GoalNodeStatus.completed) return false;
      final requiredDeps = dependencies.where(
        (d) => d.parentGoalId == node.id && d.relationType == DependencyRelation.requires,
      );
      return requiredDeps.every((d) => completedIds.contains(d.dependencyGoalId));
    }).toList();
  }

  /// Mark goals as locked if required dependencies are not completed
  static List<GoalNode> updateStatuses(
    List<GoalNode> nodes,
    List<GoalDependency> dependencies,
  ) {
    final completedIds = nodes
        .where((n) => n.status == GoalNodeStatus.completed)
        .map((n) => n.id)
        .toSet();

    return nodes.map((node) {
      if (node.status == GoalNodeStatus.completed) return node;
      if (node.status == GoalNodeStatus.inProgress) return node;

      final requiredDeps = dependencies.where(
        (d) => d.parentGoalId == node.id && d.relationType == DependencyRelation.requires,
      );

      final blockedDeps = dependencies.where(
        (d) => d.parentGoalId == node.id && d.relationType == DependencyRelation.blockedBy,
      );

      if (blockedDeps.any((d) => !completedIds.contains(d.dependencyGoalId))) {
        return node.copyWith(status: GoalNodeStatus.blocked);
      }

      if (requiredDeps.every((d) => completedIds.contains(d.dependencyGoalId))) {
        return node.copyWith(status: GoalNodeStatus.available);
      }

      return node.copyWith(status: GoalNodeStatus.locked);
    }).toList();
  }

  /// Return next best goals sorted by priority, est time, depth
  static List<GoalNode> getNextBestGoals(
    List<GoalNode> nodes,
    List<GoalDependency> dependencies, {
    int limit = 5,
  }) {
    final available = computeAvailableGoals(nodes, dependencies);

    available.sort((a, b) {
      // Priority (higher = better)
      final pa = a.priority.index;
      final pb = b.priority.index;
      if (pa != pb) return pb.compareTo(pa);

      // Estimated time (shorter = better)
      final ea = a.estimatedMinutes ?? 999;
      final eb = b.estimatedMinutes ?? 999;
      if (ea != eb) return ea.compareTo(eb);

      // Dependency depth (more dependents = more valuable)
      final da = dependencies.where((d) => d.dependencyGoalId == a.id).length;
      final db = dependencies.where((d) => d.dependencyGoalId == b.id).length;
      return db.compareTo(da);
    });

    return available.take(limit).toList();
  }

  /// Get dependencies (incoming) for a goal
  static List<GoalDependency> getDependenciesFor(String goalId, List<GoalDependency> deps) {
    return deps.where((d) => d.parentGoalId == goalId).toList();
  }

  /// Get dependents (outgoing) — goals that depend on this one
  static List<GoalDependency> getDependentsOf(String goalId, List<GoalDependency> deps) {
    return deps.where((d) => d.dependencyGoalId == goalId).toList();
  }
}
