import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/services/osrs_api_service.dart';
import 'providers/hiscores_provider.dart';

class HiscoresDialog extends HookConsumerWidget {
  final String initialName;
  final String mode;

  const HiscoresDialog({super.key, this.initialName = '', this.mode = 'normal'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController(text: initialName);
    final selectedMode = useState(mode);
    final hiscoresAsync = ref.watch(hiscoresProvider);

    return AlertDialog(
      title: const Text('Hiscores Lookup'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Player Name', isDense: true),
                    onSubmitted: (_) => _doLookup(ref, nameCtrl.text, selectedMode.value),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedMode.value,
                  items: const [
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'ironman', child: Text('Ironman')),
                    DropdownMenuItem(value: 'hardcore', child: Text('HCIM')),
                    DropdownMenuItem(value: 'ultimate', child: Text('UIM')),
                  ],
                  onChanged: (v) => selectedMode.value = v ?? 'normal',
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _doLookup(ref, nameCtrl.text, selectedMode.value),
                  child: const Text('Lookup'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: hiscoresAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
                data: (result) {
                  if (result == null) {
                    return const Center(child: Text('Enter a player name and click Lookup', style: TextStyle(color: Colors.white54)));
                  }
                  return _HiscoresResultView(result: result);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }

  void _doLookup(WidgetRef ref, String name, String mode) {
    if (name.trim().isEmpty) return;
    ref.read(hiscoresProvider.notifier).lookup(name.trim(), mode: mode);
  }
}

class _HiscoresResultView extends StatelessWidget {
  final HiscoreResult result;
  const _HiscoresResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final skills = result.skills.entries.where((e) => e.key != 'Overall').toList();
    final overall = result.skills['Overall'];
    final bossKills = result.activities.entries.where((e) => e.value.score > 0).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          if (overall != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip('Player', result.playerName),
                    _StatChip('Combat', '${result.combatLevel}'),
                    _StatChip('Total', '${overall.level}'),
                    _StatChip('Total XP', _formatXp(overall.xp)),
                    _StatChip('Rank', _formatRank(overall.rank)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          const TabBar(tabs: [Tab(text: 'Skills'), Tab(text: 'Boss KC')]),
          Expanded(
            child: TabBarView(
              children: [
                GridView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3.2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: skills.length,
                  itemBuilder: (_, i) {
                    final skill = skills[i];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(skill.key, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              child: Text('${skill.value.level}', style: const TextStyle(fontSize: 13, color: Colors.amber)),
                            ),
                            Text(_formatXp(skill.value.xp), style: const TextStyle(fontSize: 10, color: Colors.white38)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                bossKills.isEmpty
                    ? const Center(child: Text('No boss kills found', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: bossKills.length,
                        itemBuilder: (_, i) {
                          final boss = bossKills[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 2),
                            child: ListTile(
                              dense: true,
                              title: Text(boss.key, style: const TextStyle(fontSize: 12)),
                              trailing: Text('${boss.value.score} KC', style: const TextStyle(fontSize: 12, color: Colors.amber)),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatXp(int xp) {
    if (xp < 0) return '-';
    if (xp >= 1000000) return '${(xp / 1000000).toStringAsFixed(1)}M';
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}K';
    return '$xp';
  }

  String _formatRank(int rank) {
    if (rank < 0) return '-';
    if (rank >= 1000000) return '${(rank / 1000000).toStringAsFixed(1)}M';
    if (rank >= 1000) return '${(rank / 1000).toStringAsFixed(1)}K';
    return '#$rank';
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ],
    );
  }
}
