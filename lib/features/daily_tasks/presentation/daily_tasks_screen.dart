import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/daily_tasks_repository.dart';

// ─── Task Definitions ────────────────────────────────

enum TaskFrequency { recurring, daily, weekly }

class TaskDef {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final TaskFrequency frequency;
  final Duration cooldown;
  final bool enabledByDefault;

  const TaskDef({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.cooldown,
    this.enabledByDefault = true,
  });
}

const _allTasks = <TaskDef>[
  // Recurring
  TaskDef(
    id: 'herb_run',
    name: 'Herb Run',
    description: 'Plant and harvest herbs at all patches',
    icon: Icons.grass,
    color: Color(0xFF43A047),
    frequency: TaskFrequency.recurring,
    cooldown: Duration(minutes: 80),
  ),
  TaskDef(
    id: 'birdhouse_run',
    name: 'Birdhouse Run',
    description: 'Check and rebuild birdhouses on Fossil Island',
    icon: Icons.house,
    color: Color(0xFF8D6E63),
    frequency: TaskFrequency.recurring,
    cooldown: Duration(minutes: 50),
  ),
  TaskDef(
    id: 'seaweed_run',
    name: 'Seaweed Run',
    description: 'Plant giant seaweed at underwater patches',
    icon: Icons.water,
    color: Color(0xFF00897B),
    frequency: TaskFrequency.recurring,
    cooldown: Duration(minutes: 40),
  ),
  TaskDef(
    id: 'tree_run',
    name: 'Tree Run',
    description: 'Check health of trees and fruit trees',
    icon: Icons.park,
    color: Color(0xFF2E7D32),
    frequency: TaskFrequency.recurring,
    cooldown: Duration(hours: 5, minutes: 20),
    enabledByDefault: false,
  ),
  TaskDef(
    id: 'fruit_tree_run',
    name: 'Fruit Tree Run',
    description: 'Check health of fruit trees',
    icon: Icons.eco,
    color: Color(0xFFE65100),
    frequency: TaskFrequency.recurring,
    cooldown: Duration(hours: 16),
    enabledByDefault: false,
  ),
  TaskDef(
    id: 'hardwood_run',
    name: 'Hardwood Tree Run',
    description: 'Check teak/mahogany trees on Fossil Island',
    icon: Icons.forest,
    color: Color(0xFF4E342E),
    frequency: TaskFrequency.recurring,
    cooldown: Duration(hours: 64),
    enabledByDefault: false,
  ),
  // Dailies
  TaskDef(
    id: 'daily_battlestaves',
    name: 'Daily Battlestaves',
    description: 'Buy battlestaves from Zaff in Varrock (Varrock diary)',
    icon: Icons.store,
    color: Color(0xFF1565C0),
    frequency: TaskFrequency.daily,
    cooldown: Duration(hours: 24),
  ),
  TaskDef(
    id: 'daily_sand',
    name: 'Daily Buckets of Sand',
    description: 'Collect free sand from Bert in Yanille (Hand in the Sand)',
    icon: Icons.beach_access,
    color: Color(0xFFFFB74D),
    frequency: TaskFrequency.daily,
    cooldown: Duration(hours: 24),
    enabledByDefault: false,
  ),
  TaskDef(
    id: 'daily_kingdom',
    name: 'Kingdom of Miscellania',
    description: 'Top up coffers and maintain 100% approval',
    icon: Icons.castle,
    color: Color(0xFF7B1FA2),
    frequency: TaskFrequency.daily,
    cooldown: Duration(hours: 24),
    enabledByDefault: false,
  ),
  TaskDef(
    id: 'daily_flax',
    name: 'Daily Flax (Kandarin diary)',
    description: 'Collect free flax from flax keeper',
    icon: Icons.spa,
    color: Color(0xFF9CCC65),
    frequency: TaskFrequency.daily,
    cooldown: Duration(hours: 24),
    enabledByDefault: false,
  ),
  TaskDef(
    id: 'daily_essence',
    name: 'Daily Pure Essence',
    description: 'Collect free pure essence from various NPCs',
    icon: Icons.auto_awesome,
    color: Color(0xFF90CAF9),
    frequency: TaskFrequency.daily,
    cooldown: Duration(hours: 24),
    enabledByDefault: false,
  ),
  // Weeklies
  TaskDef(
    id: 'weekly_tears',
    name: 'Tears of Guthix',
    description: 'Weekly free XP in lowest skill — Lumbridge Swamp',
    icon: Icons.water_drop,
    color: Color(0xFF42A5F5),
    frequency: TaskFrequency.weekly,
    cooldown: Duration(days: 7),
  ),
  TaskDef(
    id: 'weekly_nmz_herbs',
    name: 'NMZ Herb Boxes',
    description: 'Buy 15 herb boxes daily from NMZ (up to 105/week)',
    icon: Icons.inventory,
    color: Color(0xFF66BB6A),
    frequency: TaskFrequency.daily,
    cooldown: Duration(hours: 24),
    enabledByDefault: false,
  ),
  TaskDef(
    id: 'weekly_manage_kingdom',
    name: 'Collect Kingdom Rewards',
    description: 'Collect resources from Miscellania and top up coffers',
    icon: Icons.paid,
    color: Color(0xFFD4A017),
    frequency: TaskFrequency.weekly,
    cooldown: Duration(days: 7),
    enabledByDefault: false,
  ),
];

// ─── State ───────────────────────────────────────────

class _TaskState {
  final Set<String> enabledIds;
  final Map<String, DateTime> completedAt;

  const _TaskState({
    this.enabledIds = const {},
    this.completedAt = const {},
  });

  _TaskState copyWith({
    Set<String>? enabledIds,
    Map<String, DateTime>? completedAt,
  }) =>
      _TaskState(
        enabledIds: enabledIds ?? this.enabledIds,
        completedAt: completedAt ?? this.completedAt,
      );

  Map<String, dynamic> toJson() => {
        'enabledIds': enabledIds.toList(),
        'completedAt':
            completedAt.map((k, v) => MapEntry(k, v.toIso8601String())),
      };

  factory _TaskState.fromJson(Map<String, dynamic> json) {
    final enabled = (json['enabledIds'] as List?)?.cast<String>().toSet() ??
        _allTasks.where((t) => t.enabledByDefault).map((t) => t.id).toSet();
    final completed = <String, DateTime>{};
    if (json['completedAt'] is Map) {
      for (final e in (json['completedAt'] as Map).entries) {
        completed[e.key as String] = DateTime.parse(e.value as String);
      }
    }
    return _TaskState(enabledIds: enabled, completedAt: completed);
  }

  factory _TaskState.initial() => _TaskState(
        enabledIds:
            _allTasks.where((t) => t.enabledByDefault).map((t) => t.id).toSet(),
      );
}

final _taskStateProvider =
    StateNotifierProvider<_TaskNotifier, _TaskState>((ref) {
  return _TaskNotifier(ref.watch(dailyTasksRepositoryProvider));
});

class _TaskNotifier extends StateNotifier<_TaskState> {
  final DailyTasksRepository _repo;

  _TaskNotifier(this._repo) : super(_TaskState.initial()) {
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.loadState();
    if (data != null) {
      state = _TaskState.fromJson(data);
    }
  }

  Future<void> _save() async {
    await _repo.saveState(state.toJson());
  }

  void toggleEnabled(String id) {
    final updated = {...state.enabledIds};
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(enabledIds: updated);
    _save();
  }

  void markDone(String id) {
    final updated = {...state.completedAt};
    updated[id] = DateTime.now();
    state = state.copyWith(completedAt: updated);
    _save();
  }

  void reset(String id) {
    final updated = {...state.completedAt};
    updated.remove(id);
    state = state.copyWith(completedAt: updated);
    _save();
  }

  void resetAll() {
    state = state.copyWith(completedAt: {});
    _save();
  }
}

// ─── Screen ──────────────────────────────────────────

class DailyTasksScreen extends HookConsumerWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(_taskStateProvider);
    final showAll = useState(false);

    // Tick every 15 seconds to update timers
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 15), (_) {
        // Force rebuild by reading state
        ref.invalidate(_taskStateProvider);
      });
      return timer.cancel;
    }, []);

    final enabledTasks =
        _allTasks.where((t) => taskState.enabledIds.contains(t.id)).toList();
    final disabledTasks =
        _allTasks.where((t) => !taskState.enabledIds.contains(t.id)).toList();

    // Sort enabled: ready first, then by time remaining
    enabledTasks.sort((a, b) {
      final aReady = _isReady(a, taskState);
      final bReady = _isReady(b, taskState);
      if (aReady != bReady) return aReady ? -1 : 1;
      final aRemaining = _remainingDuration(a, taskState);
      final bRemaining = _remainingDuration(b, taskState);
      return aRemaining.compareTo(bRemaining);
    });

    final readyCount = enabledTasks.where((t) => _isReady(t, taskState)).length;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Flexible(
                  child: Text('Daily Tasks & Timers',
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 12),
                if (readyCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_active,
                            size: 14, color: Color(0xFF43A047)),
                        const SizedBox(width: 4),
                        Text('$readyCount ready',
                            style: const TextStyle(
                                color: Color(0xFF43A047),
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => showAll.value = !showAll.value,
                  icon: Icon(
                      showAll.value ? Icons.visibility_off : Icons.visibility,
                      size: 16),
                  label: Text(showAll.value
                      ? 'Hide Disabled'
                      : 'Show All (${disabledTasks.length} hidden)'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(_taskStateProvider.notifier).resetAll(),
                  icon: const Icon(Icons.restart_alt, size: 16),
                  label: const Text('Reset All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Task grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 360,
                  mainAxisExtent: 120,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: enabledTasks.length +
                    (showAll.value ? disabledTasks.length : 0),
                itemBuilder: (context, i) {
                  if (i < enabledTasks.length) {
                    return _TaskCard(
                      task: enabledTasks[i],
                      state: taskState,
                      onMarkDone: () => ref
                          .read(_taskStateProvider.notifier)
                          .markDone(enabledTasks[i].id),
                      onReset: () => ref
                          .read(_taskStateProvider.notifier)
                          .reset(enabledTasks[i].id),
                      onToggleEnabled: () => ref
                          .read(_taskStateProvider.notifier)
                          .toggleEnabled(enabledTasks[i].id),
                    );
                  } else {
                    final di = i - enabledTasks.length;
                    return _TaskCard(
                      task: disabledTasks[di],
                      state: taskState,
                      isDisabled: true,
                      onMarkDone: () {},
                      onReset: () {},
                      onToggleEnabled: () => ref
                          .read(_taskStateProvider.notifier)
                          .toggleEnabled(disabledTasks[di].id),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────

bool _isReady(TaskDef task, _TaskState state) {
  final completed = state.completedAt[task.id];
  if (completed == null) return true;
  return DateTime.now().difference(completed) >= task.cooldown;
}

Duration _remainingDuration(TaskDef task, _TaskState state) {
  final completed = state.completedAt[task.id];
  if (completed == null) return Duration.zero;
  final elapsed = DateTime.now().difference(completed);
  final remaining = task.cooldown - elapsed;
  return remaining.isNegative ? Duration.zero : remaining;
}

String _formatDuration(Duration d) {
  if (d <= Duration.zero) return 'Ready!';
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  return '${d.inMinutes}m';
}

String _formatCooldown(Duration d) {
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  return '${d.inMinutes}m';
}

// ─── Task Card ───────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskDef task;
  final _TaskState state;
  final bool isDisabled;
  final VoidCallback onMarkDone;
  final VoidCallback onReset;
  final VoidCallback onToggleEnabled;

  const _TaskCard({
    required this.task,
    required this.state,
    this.isDisabled = false,
    required this.onMarkDone,
    required this.onReset,
    required this.onToggleEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final ready = !isDisabled && _isReady(task, state);
    final remaining = _remainingDuration(task, state);
    final completed = state.completedAt[task.id];
    final progress = completed != null
        ? (DateTime.now().difference(completed).inSeconds /
                task.cooldown.inSeconds)
            .clamp(0.0, 1.0)
        : 1.0;

    return Card(
      color: isDisabled
          ? Colors.white.withValues(alpha: 0.03)
          : ready
              ? task.color.withValues(alpha: 0.1)
              : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isDisabled ? onToggleEnabled : (ready ? onMarkDone : null),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(task.icon,
                      size: 20,
                      color: isDisabled ? Colors.white24 : task.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(task.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDisabled ? Colors.white30 : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (!isDisabled && ready)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('READY',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF43A047))),
                    ),
                  if (!isDisabled && !ready)
                    Text(_formatDuration(remaining),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: remaining.inMinutes < 10
                                ? const Color(0xFFFF9800)
                                : Colors.white38)),
                  if (isDisabled)
                    const Text('Disabled',
                        style: TextStyle(fontSize: 10, color: Colors.white24)),
                  // Context menu
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        size: 16,
                        color: isDisabled ? Colors.white12 : Colors.white30),
                    padding: EdgeInsets.zero,
                    itemBuilder: (_) => [
                      if (!isDisabled) ...[
                        const PopupMenuItem(
                            value: 'done',
                            child: Text('Mark Done',
                                style: TextStyle(fontSize: 12))),
                        const PopupMenuItem(
                            value: 'reset',
                            child: Text('Reset Timer',
                                style: TextStyle(fontSize: 12))),
                      ],
                      PopupMenuItem(
                          value: 'toggle',
                          child: Text(isDisabled ? 'Enable' : 'Disable',
                              style: const TextStyle(fontSize: 12))),
                    ],
                    onSelected: (v) {
                      if (v == 'done') onMarkDone();
                      if (v == 'reset') onReset();
                      if (v == 'toggle') onToggleEnabled();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(task.description,
                  style: TextStyle(
                      fontSize: 10,
                      color: isDisabled ? Colors.white10 : Colors.white38),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const Spacer(),
              // Progress bar
              if (!isDisabled) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation(
                            ready
                                ? const Color(0xFF43A047)
                                : task.color.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CD: ${_formatCooldown(task.cooldown)}',
                      style:
                          const TextStyle(fontSize: 9, color: Colors.white24),
                    ),
                  ],
                ),
              ] else ...[
                const Center(
                  child: Text('Tap to enable',
                      style: TextStyle(fontSize: 10, color: Colors.white10)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
