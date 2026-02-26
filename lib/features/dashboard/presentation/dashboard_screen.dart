import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../characters/presentation/providers/characters_provider.dart';
import '../../goals/presentation/providers/goals_provider.dart';
import '../../sessions/presentation/providers/sessions_provider.dart';
import '../../goal_planner/presentation/providers/goal_planner_provider.dart';

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider);
    final goalsAsync = ref.watch(goalsProvider);
    final sessionsAsync = ref.watch(sessionsProvider);
    final nextBest = ref.watch(nextBestGoalsProvider);
    final activeSession = ref.watch(activeSessionProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            if (activeChar != null)
              Text(
                  'Active: ${activeChar.displayName} (${activeChar.characterType.displayName})',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary))
            else
              const Text(
                  'No active character selected. Go to Characters to create one.',
                  style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 24),

            // Active session banner
            if (activeSession != null)
              Card(
                color: Colors.green.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 12),
                      const SizedBox(width: 8),
                      Text('Active Session: ${activeSession.type.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Text(activeSession.durationFormatted,
                          style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _StatCard(
                  title: 'Active Goals',
                  value: goalsAsync.whenOrNull(
                        data: (goals) => activeChar != null
                            ? goals
                                .where((g) =>
                                    g.characterId == activeChar.id &&
                                    g.status.name == 'active')
                                .length
                                .toString()
                            : '0',
                      ) ??
                      '-',
                  icon: Icons.flag,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Sessions',
                  value: sessionsAsync.whenOrNull(
                        data: (sessions) => activeChar != null
                            ? sessions
                                .where((s) =>
                                    s.characterId == activeChar.id &&
                                    !s.isActive)
                                .length
                                .toString()
                            : '0',
                      ) ??
                      '-',
                  icon: Icons.timer,
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Next Steps',
                  value: nextBest.length.toString(),
                  icon: Icons.account_tree,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Current grind
            if (activeChar != null && activeChar.currentGrind.isNotEmpty) ...[
              Text('Current Grind',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(activeChar.currentGrind,
                      style: const TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Next login purpose
            if (activeChar != null &&
                activeChar.nextLoginPurpose.isNotEmpty) ...[
              Text('Next Login Purpose',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(activeChar.nextLoginPurpose,
                      style: const TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Next best goals
            if (nextBest.isNotEmpty) ...[
              Text('Suggested Next Goals',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...nextBest.take(3).map((node) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.arrow_right,
                          color: Theme.of(context).colorScheme.secondary),
                      title: Text(node.title),
                      subtitle: Text('${node.type.name} | ${node.priority.name}'
                          '${node.estimatedMinutes != null ? " | ~${node.estimatedMinutes}min" : ""}'),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title,
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
