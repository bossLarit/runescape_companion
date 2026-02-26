import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/osrs_api_service.dart';

class PlayerTrackerScreen extends HookConsumerWidget {
  const PlayerTrackerScreen({super.key});

  static String _formatMetric(String metric) {
    return metric
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static String _formatNumber(num n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchCtrl = useTextEditingController();
    final loading = useState(false);
    final playerDetails = useState<WomPlayerDetails?>(null);
    final gains = useState<WomGains?>(null);
    final achievements = useState<List<WomAchievement>>([]);
    final gainsPeriod = useState('week');
    final error = useState<String?>(null);
    final tabCtrl = useTabController(initialLength: 4);

    Future<void> lookupPlayer(String username) async {
      if (username.trim().isEmpty) return;
      loading.value = true;
      error.value = null;
      playerDetails.value = null;
      gains.value = null;
      achievements.value = [];

      final api = ref.read(osrsApiServiceProvider);
      final details = await api.womGetPlayer(username.trim());
      if (details == null) {
        error.value =
            'Player not found. They may need to be tracked on wiseoldman.net first.';
        loading.value = false;
        return;
      }
      playerDetails.value = details;

      final g =
          await api.womGetGains(username.trim(), period: gainsPeriod.value);
      gains.value = g;

      final a = await api.womGetAchievements(username.trim());
      achievements.value = a;

      loading.value = false;
    }

    Future<void> refreshGains(String username) async {
      final api = ref.read(osrsApiServiceProvider);
      final g = await api.womGetGains(username, period: gainsPeriod.value);
      gains.value = g;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Player Tracker',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Powered by Wise Old Man',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, size: 20),
                      hintText: 'Enter RuneScape name...',
                      isDense: true,
                      suffixIcon: loading.value
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            )
                          : null,
                    ),
                    onSubmitted: (v) => lookupPlayer(v),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: loading.value
                      ? null
                      : () => lookupPlayer(searchCtrl.text),
                  child: const Text('Lookup'),
                ),
                if (playerDetails.value != null) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: loading.value
                        ? null
                        : () async {
                            loading.value = true;
                            final api = ref.read(osrsApiServiceProvider);
                            await api.womUpdatePlayer(
                                playerDetails.value!.player.username);
                            await lookupPlayer(
                                playerDetails.value!.player.username);
                          },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Update on WOM'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            if (error.value != null)
              Card(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(error.value!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error))),
                    ],
                  ),
                ),
              ),
            if (playerDetails.value == null &&
                error.value == null &&
                !loading.value)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_search,
                          size: 64, color: Colors.white24),
                      SizedBox(height: 16),
                      Text(
                          'Search for a player to view their stats, gains, and achievements'),
                      SizedBox(height: 4),
                      Text(
                          'Data from wiseoldman.net — the player must be tracked there',
                          style:
                              TextStyle(fontSize: 11, color: Colors.white38)),
                    ],
                  ),
                ),
              ),
            if (playerDetails.value != null) ...[
              _buildPlayerHeader(context, playerDetails.value!),
              const SizedBox(height: 12),
              TabBar(
                controller: tabCtrl,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'Skills'),
                  Tab(text: 'Gains'),
                  Tab(text: 'Bosses'),
                  Tab(text: 'Achievements'),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: tabCtrl,
                  children: [
                    _buildSkillsTab(context, playerDetails.value!),
                    _buildGainsTab(context, gains.value, gainsPeriod,
                        playerDetails.value!.player.username, refreshGains),
                    _buildBossesTab(context, playerDetails.value!),
                    _buildAchievementsTab(context, achievements.value),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerHeader(BuildContext context, WomPlayerDetails details) {
    final p = details.player;
    final overall = details.skills['overall'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.2),
              child: Text(
                p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : '?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.displayName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Chip(
                        label: Text(p.type.toUpperCase(),
                            style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact),
                    const SizedBox(width: 6),
                    Chip(
                        label: Text(p.build.toUpperCase(),
                            style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact),
                  ],
                ),
              ],
            ),
            const Spacer(),
            _statBox(context, 'Combat', '${details.combatLevel}'),
            _statBox(context, 'Total Level', '${overall?.level ?? 0}'),
            _statBox(context, 'Total XP', _formatNumber(p.exp)),
            _statBox(context, 'EHP', p.ehp.toStringAsFixed(1)),
            _statBox(context, 'EHB', p.ehb.toStringAsFixed(1)),
            _statBox(context, 'TTM', p.ttm.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }

  Widget _statBox(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildSkillsTab(BuildContext context, WomPlayerDetails details) {
    final skillOrder = [
      'attack',
      'hitpoints',
      'mining',
      'strength',
      'agility',
      'smithing',
      'defence',
      'herblore',
      'fishing',
      'ranged',
      'thieving',
      'cooking',
      'prayer',
      'crafting',
      'firemaking',
      'magic',
      'fletching',
      'woodcutting',
      'runecraft',
      'slayer',
      'farming',
      'construction',
      'hunter',
      'sailing',
    ];

    return GridView.builder(
      padding: const EdgeInsets.only(top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 4.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 4,
      ),
      itemCount: skillOrder.length,
      itemBuilder: (_, i) {
        final key = skillOrder[i];
        final skill = details.skills[key];
        if (skill == null) return const SizedBox.shrink();
        final pct = skill.level >= 99
            ? 1.0
            : (skill.experience / 13034431).clamp(0.0, 1.0);
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(_formatMetric(key),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                ),
                Text('${skill.level}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: skill.level >= 99
                            ? Theme.of(context).colorScheme.secondary
                            : null)),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatNumber(skill.experience),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white54)),
                      const SizedBox(height: 2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 3,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation(skill.level >= 99
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGainsTab(
      BuildContext context,
      WomGains? gainsData,
      ValueNotifier<String> period,
      String username,
      Future<void> Function(String) refresh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'day', label: Text('Day')),
                ButtonSegment(value: 'week', label: Text('Week')),
                ButtonSegment(value: 'month', label: Text('Month')),
                ButtonSegment(value: 'year', label: Text('Year')),
              ],
              selected: {period.value},
              onSelectionChanged: (v) {
                period.value = v.first;
                refresh(username);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (gainsData == null)
          const Expanded(
              child: Center(
                  child: Text('No gains data available for this period')))
        else
          Expanded(
            child: ListView(
              children: [
                if (gainsData.skills.values
                    .any((s) => s.experience.gained > 0)) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Skill Gains',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  for (final e in (gainsData.skills.entries
                      .where((e) =>
                          e.value.experience.gained > 0 && e.key != 'overall')
                      .toList()
                    ..sort((a, b) => b.value.experience.gained
                        .compareTo(a.value.experience.gained))))
                    Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        dense: true,
                        title: Text(_formatMetric(e.key)),
                        trailing: Text(
                            '+${_formatNumber(e.value.experience.gained)} XP',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold)),
                        subtitle: e.value.levelGained > 0
                            ? Text('+${e.value.levelGained} level(s)',
                                style: const TextStyle(fontSize: 11))
                            : null,
                      ),
                    ),
                ],
                if (gainsData.bosses.values.any((b) => b.killsGained > 0)) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Boss KC Gains',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  for (final e in gainsData.bosses.entries
                      .where((e) => e.value.killsGained > 0)
                      .toList()
                    ..sort((a, b) =>
                        b.value.killsGained.compareTo(a.value.killsGained)))
                    Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        dense: true,
                        title: Text(_formatMetric(e.key)),
                        trailing: Text('+${e.value.killsGained} KC',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
                if (!gainsData.skills.values
                        .any((s) => s.experience.gained > 0) &&
                    !gainsData.bosses.values.any((b) => b.killsGained > 0))
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                        child: Text('No gains recorded for this period')),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBossesTab(BuildContext context, WomPlayerDetails details) {
    final tracked = details.bosses.entries
        .where((e) => e.value.kills > 0)
        .toList()
      ..sort((a, b) => b.value.kills.compareTo(a.value.kills));

    if (tracked.isEmpty) {
      return const Center(child: Text('No boss kills tracked'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: tracked.length,
      itemBuilder: (_, i) {
        final e = tracked[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.whatshot, size: 20),
            title: Text(_formatMetric(e.key)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${e.value.kills} KC',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary)),
                if (e.value.rank > 0) ...[
                  const SizedBox(width: 12),
                  Text('Rank ${_formatNumber(e.value.rank)}',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white54)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementsTab(
      BuildContext context, List<WomAchievement> achList) {
    if (achList.isEmpty) {
      return const Center(child: Text('No achievements found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: achList.length,
      itemBuilder: (_, i) {
        final a = achList[i];
        String? dateStr;
        if (a.createdAt != null) {
          try {
            dateStr = DateFormat.yMMMd().format(DateTime.parse(a.createdAt!));
          } catch (_) {}
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          child: ListTile(
            dense: true,
            leading: Icon(Icons.emoji_events,
                size: 20, color: Theme.of(context).colorScheme.secondary),
            title: Text(a.name),
            subtitle: dateStr != null
                ? Text('Achieved $dateStr',
                    style: const TextStyle(fontSize: 11))
                : null,
            trailing: Chip(
              label: Text(_formatMetric(a.metric),
                  style: const TextStyle(fontSize: 10)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      },
    );
  }
}
