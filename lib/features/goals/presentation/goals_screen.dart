import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/goal_model.dart';
import 'providers/goals_provider.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import '../../characters/domain/character_model.dart';
import '../../characters/presentation/providers/hiscores_provider.dart';
import '../../goal_planner/presentation/providers/goal_planner_provider.dart';
import '../../goal_planner/data/osrs_goals_data.dart';
import '../../goal_planner/data/goal_suggestion_engine.dart';
import '../../goal_planner/data/micro_goals_engine.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/screen_header.dart';

class GoalsScreen extends HookConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final activeChar = ref.watch(activeCharacterProvider);
    final plannerState = ref.watch(goalPlannerProvider);
    final hiscoreState = ref.watch(hiscoresProvider);
    final searchQuery = useState('');

    final isIronman = activeChar != null &&
        {
          CharacterType.iron,
          CharacterType.hcim,
          CharacterType.uim,
          CharacterType.gim,
        }.contains(activeChar.characterType);

    // Build player levels from hiscores
    final playerLevels = <String, int>{};
    hiscoreState.whenData((result) {
      if (result != null) {
        for (final entry in result.skills.entries) {
          if (entry.value.level > 0) {
            playerLevels[entry.key] = entry.value.level;
          }
        }
      }
    });

    // Saved planner goals
    final savedIds = plannerState.savedGoalIds;
    final completedIds = plannerState.completedOsrsGoalIds;

    // Resolve saved OsrsGoals
    final savedOsrsGoals = <ScoredGoal>[];
    if (savedIds.isNotEmpty && playerLevels.isNotEmpty) {
      final allScored = GoalSuggestionEngine.analyzeGoals(
        playerLevels: playerLevels,
        completedGoalIds: completedIds,
      );
      for (final s in allScored) {
        if (savedIds.contains(s.goal.id)) savedOsrsGoals.add(s);
      }
    }

    // Resolve saved MicroGoals (training goals)
    final savedMicroGoals = <MicroGoal>[];
    if (savedIds.isNotEmpty && playerLevels.isNotEmpty) {
      final allMicro = MicroGoalsEngine.generateGoals(
        playerLevels: playerLevels,
        isIronman: isIronman,
        maxGoalsPerSkill: 5,
      );
      for (final g in allMicro) {
        final tid = 'training_${g.skill}_${g.targetLevel}';
        if (savedIds.contains(tid)) savedMicroGoals.add(g);
      }
    }

    final hasPlannerGoals =
        savedOsrsGoals.isNotEmpty || savedMicroGoals.isNotEmpty;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'Goals',
              characterName: activeChar?.displayName,
              actions: [
                ElevatedButton.icon(
                  onPressed: activeChar == null
                      ? null
                      : () => _showGoalForm(context, ref, activeChar.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Goal'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Search
            SizedBox(
              width: 300,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search goals...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onChanged: (v) => searchQuery.value = v,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  // ── Saved Planner Goals ──
                  if (hasPlannerGoals) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.flag, size: 16, color: Color(0xFFD4A017)),
                          SizedBox(width: 6),
                          Text('Saved Goals from Goal Planner',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFD4A017))),
                        ],
                      ),
                    ),
                    // Milestone goals
                    for (final scored in savedOsrsGoals)
                      if (searchQuery.value.isEmpty ||
                          scored.goal.title
                              .toLowerCase()
                              .contains(searchQuery.value.toLowerCase()))
                        _PlannerGoalTile(
                          title: scored.goal.title,
                          subtitle: categoryLabel(scored.goal.category),
                          progress: scored.completionPercent / 100,
                          isCompleted: completedIds.contains(scored.goal.id),
                          readiness: scored.readiness,
                          onToggleComplete: () => ref
                              .read(goalPlannerProvider.notifier)
                              .toggleOsrsGoal(scored.goal.id),
                          onUnsave: () => ref
                              .read(goalPlannerProvider.notifier)
                              .toggleSavedGoal(scored.goal.id),
                        ),
                    // Training goals
                    for (final micro in savedMicroGoals)
                      if (searchQuery.value.isEmpty ||
                          micro.skill
                              .toLowerCase()
                              .contains(searchQuery.value.toLowerCase()) ||
                          micro.milestone
                              .toLowerCase()
                              .contains(searchQuery.value.toLowerCase()))
                        _PlannerGoalTile(
                          title: '${micro.skill} → Lv${micro.targetLevel}',
                          subtitle:
                              '${micro.bestMethod.method} — ${micro.milestone}',
                          progress: micro.currentLevel / micro.targetLevel,
                          isCompleted: false,
                          readiness: null,
                          hours: micro.estimatedHours,
                          onToggleComplete: null,
                          onUnsave: () => ref
                              .read(goalPlannerProvider.notifier)
                              .toggleSavedGoal(
                                  'training_${micro.skill}_${micro.targetLevel}'),
                        ),
                    const Divider(height: 24),
                  ],

                  // ── Custom Goals ──
                  goalsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (allGoals) {
                      final goals = allGoals
                          .where((g) =>
                              activeChar == null ||
                              g.characterId == activeChar.id)
                          .where((g) =>
                              searchQuery.value.isEmpty ||
                              g.title
                                  .toLowerCase()
                                  .contains(searchQuery.value.toLowerCase()))
                          .toList();
                      goals.sort((a, b) {
                        final pa = a.priority.index;
                        final pb = b.priority.index;
                        if (pa != pb) return pb.compareTo(pa);
                        return b.updatedAt.compareTo(a.updatedAt);
                      });

                      if (goals.isEmpty && !hasPlannerGoals) {
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Text(
                              activeChar == null
                                  ? 'Create a character to start tracking goals'
                                  : 'Save goals in the Goal Planner, or tap "+ Add Goal"',
                              style: const TextStyle(color: Colors.white54)),
                        ));
                      }
                      if (goals.isNotEmpty && hasPlannerGoals) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.edit_note,
                                      size: 16, color: Colors.white54),
                                  SizedBox(width: 6),
                                  Text('Custom Goals',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white54)),
                                ],
                              ),
                            ),
                            for (final g in goals) _GoalTile(goal: g),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          for (final g in goals) _GoalTile(goal: g),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalForm(BuildContext context, WidgetRef ref, String characterId,
      [Goal? existing]) {
    showDialog(
      context: context,
      builder: (ctx) => _GoalFormDialog(
        characterId: characterId,
        goal: existing,
        onSave: (goal) {
          if (existing != null) {
            ref.read(goalsProvider.notifier).update(goal);
          } else {
            ref.read(goalsProvider.notifier).add(goal);
          }
        },
      ),
    );
  }
}

class _PlannerGoalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final bool isCompleted;
  final GoalReadiness? readiness;
  final double? hours;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onUnsave;

  const _PlannerGoalTile({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.isCompleted,
    required this.readiness,
    this.hours,
    this.onToggleComplete,
    this.onUnsave,
  });

  @override
  Widget build(BuildContext context) {
    final rColor = isCompleted
        ? Colors.green
        : switch (readiness) {
            GoalReadiness.ready => const Color(0xFF43A047),
            GoalReadiness.almostReady => const Color(0xFFFF9800),
            GoalReadiness.workTowards => Colors.red,
            null => const Color(0xFF42A5F5),
          };
    final rLabel = isCompleted
        ? 'Completed'
        : switch (readiness) {
            GoalReadiness.ready => 'Ready',
            GoalReadiness.almostReady => 'Almost',
            GoalReadiness.workTowards => 'In Progress',
            null => 'Training',
          };

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Checkbox
            if (onToggleComplete != null)
              SizedBox(
                width: 28,
                child: Checkbox(
                  value: isCompleted,
                  onChanged: (_) => onToggleComplete!(),
                  activeColor: const Color(0xFFD4A017),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            if (onToggleComplete != null) const SizedBox(width: 6),
            // Color bar
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: rColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.white38 : Colors.white,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      )),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 10, color: Colors.white38)),
                ],
              ),
            ),
            // Progress bar
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(rColor),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('${(progress * 100).toStringAsFixed(0)}%',
                      style:
                          const TextStyle(fontSize: 9, color: Colors.white38)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Readiness badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: rColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(rLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: rColor)),
            ),
            // Time estimate
            if (hours != null) ...[
              const SizedBox(width: 8),
              Text(MicroGoalsEngine.formatHours(hours!),
                  style: const TextStyle(fontSize: 10, color: Colors.white38)),
            ],
            // Remove button
            if (onUnsave != null)
              IconButton(
                icon: const Icon(Icons.bookmark_remove, size: 16),
                color: Colors.white24,
                tooltip: 'Remove from Goals',
                onPressed: onUnsave,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalTile extends HookConsumerWidget {
  final Goal goal;
  const _GoalTile({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = goal.progressPercent;
    final priorityColor = switch (goal.priority) {
      GoalPriority.critical => Colors.red,
      GoalPriority.high => Colors.orange,
      GoalPriority.medium => Colors.blue,
      GoalPriority.low => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title,
                          style: Theme.of(context).textTheme.titleSmall),
                      if (goal.description.isNotEmpty)
                        Text(goal.description,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Chip(
                  label: Text(goal.type.name,
                      style: const TextStyle(fontSize: 11)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(goal.status.name,
                      style: const TextStyle(fontSize: 11)),
                  backgroundColor: goal.isComplete
                      ? Colors.green.withValues(alpha: 0.2)
                      : null,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'complete') {
                      await ref.read(goalsProvider.notifier).update(
                            goal.copyWith(
                                status: GoalStatus.completed,
                                currentValue: goal.targetValue),
                          );
                    } else if (value == 'delete') {
                      final confirmed = await showConfirmDialog(context,
                          title: 'Delete Goal',
                          message: 'Delete "${goal.title}"?');
                      if (confirmed) {
                        await ref.read(goalsProvider.notifier).delete(goal.id);
                      }
                    } else if (value == 'edit') {
                      unawaited(showDialog(
                        context: context,
                        builder: (ctx) => _GoalFormDialog(
                          characterId: goal.characterId,
                          goal: goal,
                          onSave: (g) =>
                              ref.read(goalsProvider.notifier).update(g),
                        ),
                      ));
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'complete', child: Text('Mark Complete')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            if (goal.targetValue > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation(
                          progress >= 100
                              ? Colors.green
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${progress.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(
                    '${goal.currentValue.toStringAsFixed(0)} / ${goal.targetValue.toStringAsFixed(0)} ${goal.unit}',
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoalFormDialog extends HookWidget {
  final String characterId;
  final Goal? goal;
  final void Function(Goal) onSave;

  const _GoalFormDialog(
      {required this.characterId, this.goal, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final isEditing = goal != null;
    final titleCtrl = useTextEditingController(text: goal?.title ?? '');
    final descCtrl = useTextEditingController(text: goal?.description ?? '');
    final targetCtrl =
        useTextEditingController(text: goal?.targetValue.toString() ?? '0');
    final currentCtrl =
        useTextEditingController(text: goal?.currentValue.toString() ?? '0');
    final unitCtrl = useTextEditingController(text: goal?.unit ?? '');
    final estMinCtrl = useTextEditingController(
        text: goal?.estimatedMinutes.toString() ?? '0');
    final tagsCtrl =
        useTextEditingController(text: goal?.tags.join(', ') ?? '');
    final type = useState(goal?.type ?? GoalType.custom);
    final priority = useState(goal?.priority ?? GoalPriority.medium);
    final status = useState(goal?.status ?? GoalStatus.active);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Goal' : 'New Goal'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  autofocus: true),
              const SizedBox(height: 8),
              TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<GoalType>(
                      key: ValueKey(type.value),
                      value: type.value,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: GoalType.values
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t.name)))
                          .toList(),
                      onChanged: (v) => type.value = v ?? GoalType.custom,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<GoalPriority>(
                      key: ValueKey(priority.value),
                      value: priority.value,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: GoalPriority.values
                          .map((p) =>
                              DropdownMenuItem(value: p, child: Text(p.name)))
                          .toList(),
                      onChanged: (v) =>
                          priority.value = v ?? GoalPriority.medium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: targetCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Target'),
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: currentCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Current'),
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: unitCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Unit'))),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: estMinCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Estimated Minutes'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Tags (comma separated)')),
              if (isEditing) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<GoalStatus>(
                  key: ValueKey(status.value),
                  value: status.value,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: GoalStatus.values
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => status.value = v ?? GoalStatus.active,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final title = titleCtrl.text.trim();
            if (title.isEmpty) return;
            final tags = tagsCtrl.text
                .split(',')
                .map((t) => t.trim())
                .where((t) => t.isNotEmpty)
                .toList();
            final result =
                (goal ?? Goal(characterId: characterId, title: title)).copyWith(
              title: title,
              description: descCtrl.text.trim(),
              type: type.value,
              targetValue: double.tryParse(targetCtrl.text) ?? 0,
              currentValue: double.tryParse(currentCtrl.text) ?? 0,
              unit: unitCtrl.text.trim(),
              priority: priority.value,
              status: status.value,
              estimatedMinutes: int.tryParse(estMinCtrl.text) ?? 0,
              tags: tags,
            );
            onSave(result);
            Navigator.of(context).pop();
          },
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
