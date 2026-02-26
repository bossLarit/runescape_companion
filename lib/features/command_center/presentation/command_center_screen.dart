import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../characters/domain/character_model.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import '../../goals/presentation/providers/goals_provider.dart';
import '../../sessions/presentation/providers/sessions_provider.dart';

class CommandCenterScreen extends HookConsumerWidget {
  const CommandCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charsAsync = ref.watch(charactersProvider);
    final searchQuery = useState('');
    final filterType = useState<CharacterType?>(null);
    final sortBy = useState('recent');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Command Center',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: const InputDecoration(
                        hintText: 'Search characters...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true),
                    onChanged: (v) => searchQuery.value = v,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<CharacterType?>(
                  value: filterType.value,
                  hint: const Text('Type'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...CharacterType.values.map((t) =>
                        DropdownMenuItem(value: t, child: Text(t.displayName))),
                  ],
                  onChanged: (v) => filterType.value = v,
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: sortBy.value,
                  items: const [
                    DropdownMenuItem(value: 'recent', child: Text('Recent')),
                    DropdownMenuItem(value: 'alpha', child: Text('A-Z')),
                    DropdownMenuItem(value: 'type', child: Text('Type')),
                  ],
                  onChanged: (v) => sortBy.value = v ?? 'recent',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: charsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (characters) {
                  var filtered = characters.where((c) {
                    if (filterType.value != null &&
                        c.characterType != filterType.value) {
                      return false;
                    }
                    if (searchQuery.value.isNotEmpty &&
                        !c.displayName
                            .toLowerCase()
                            .contains(searchQuery.value.toLowerCase())) {
                      return false;
                    }
                    return true;
                  }).toList();

                  switch (sortBy.value) {
                    case 'alpha':
                      filtered.sort(
                          (a, b) => a.displayName.compareTo(b.displayName));
                      break;
                    case 'type':
                      filtered.sort((a, b) => a.characterType.index
                          .compareTo(b.characterType.index));
                      break;
                    default:
                      filtered
                          .sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                  }

                  if (filtered.isEmpty) {
                    return const Center(
                        child: Text('No characters found',
                            style: TextStyle(color: Colors.white54)));
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 420,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _CommandCard(character: filtered[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandCard extends HookConsumerWidget {
  final Character character;
  const _CommandCard({required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allGoals = ref.watch(goalsProvider);
    final allSessions = ref.watch(sessionsProvider);

    final goalCount = allGoals.whenOrNull(
          data: (goals) => goals
              .where((g) =>
                  g.characterId == character.id && g.status.name == 'active')
              .length,
        ) ??
        0;

    final lastSession = allSessions.whenOrNull(
      data: (sessions) {
        final charSessions = sessions
            .where((s) => s.characterId == character.id && !s.isActive)
            .toList();
        if (charSessions.isEmpty) return null;
        charSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
        return charSessions.first;
      },
    );

    final securityScore = character.securityChecklist.completedCount;
    final securityTotal = character.securityChecklist.totalCount;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(character.avatarColorValue),
                  child: Text(
                      character.displayName.isNotEmpty
                          ? character.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(character.displayName,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(character.characterType.displayName,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                if (character.isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text('Active',
                        style: TextStyle(fontSize: 11, color: Colors.green)),
                  ),
              ],
            ),
            const Divider(height: 20),
            if (character.nextLoginPurpose.isNotEmpty) ...[
              Text('Next Login:',
                  style: TextStyle(
                      color: Colors.amber[200],
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              Text(character.nextLoginPurpose,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
            ],
            if (character.currentGrind.isNotEmpty) ...[
              Text('Current Grind:',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
              Text(character.currentGrind,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
            ],
            Row(
              children: [
                _InfoChip(icon: Icons.flag, label: '$goalCount goals'),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.timer,
                  label: lastSession != null
                      ? DateFormat.yMd().format(lastSession.startTime)
                      : 'No sessions',
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.shield,
                    size: 14,
                    color: securityScore == securityTotal
                        ? Colors.green
                        : Colors.orange),
                const SizedBox(width: 4),
                Text('Security: $securityScore/$securityTotal',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white54),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white54)),
        ],
      ),
    );
  }
}
