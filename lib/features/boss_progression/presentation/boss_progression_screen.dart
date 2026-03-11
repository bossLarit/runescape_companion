import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import '../../characters/presentation/providers/hiscores_provider.dart';
import '../data/boss_progression_data.dart';

Color _tierColor(BossTier tier) {
  switch (tier) {
    case BossTier.easy:
      return const Color(0xFF4CAF50);
    case BossTier.medium:
      return const Color(0xFF42A5F5);
    case BossTier.hard:
      return const Color(0xFFFF9800);
    case BossTier.elite:
      return const Color(0xFFE040FB);
    case BossTier.master:
      return const Color(0xFFFF5252);
    case BossTier.grandmaster:
      return kGold;
  }
}

IconData _tierIcon(BossTier tier) {
  switch (tier) {
    case BossTier.easy:
      return Icons.star_border;
    case BossTier.medium:
      return Icons.star_half;
    case BossTier.hard:
      return Icons.star;
    case BossTier.elite:
      return Icons.whatshot;
    case BossTier.master:
      return Icons.local_fire_department;
    case BossTier.grandmaster:
      return Icons.emoji_events;
  }
}

class BossProgressionScreen extends HookConsumerWidget {
  const BossProgressionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider);
    final hiscoreState = ref.watch(hiscoresProvider);
    final selectedTier = useState<BossTier?>(null);
    final selectedBoss = useState<BossEntry?>(null);
    final showOnlyReady = useState(false);

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

    // Filter bosses
    final displayBosses = allBosses.where((b) {
      if (selectedTier.value != null && b.tier != selectedTier.value) {
        return false;
      }
      if (showOnlyReady.value && playerLevels.isNotEmpty) {
        if (!b.meetsRequirements(playerLevels)) return false;
      }
      return true;
    }).toList();

    // Group by tier for display
    final grouped = <BossTier, List<BossEntry>>{};
    for (final b in displayBosses) {
      grouped.putIfAbsent(b.tier, () => []).add(b);
    }

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
                  child: Text('Boss Progression',
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                if (activeChar != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(activeChar.displayName,
                        style: const TextStyle(color: kGold, fontSize: 12)),
                  ),
                ],
                const Spacer(),
                if (playerLevels.isNotEmpty)
                  Row(
                    children: [
                      const Text('Ready only',
                          style:
                              TextStyle(fontSize: 12, color: Colors.white54)),
                      const SizedBox(width: 6),
                      Switch(
                        value: showOnlyReady.value,
                        onChanged: (v) => showOnlyReady.value = v,
                        activeColor: kGold,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Beginner to pro — based on the OSRS Wiki Bossing Ladder',
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 16),

            // Tier filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _TierChip(
                    label: 'All Tiers',
                    color: Colors.white54,
                    selected: selectedTier.value == null,
                    onTap: () {
                      selectedTier.value = null;
                      selectedBoss.value = null;
                    },
                    count: allBosses.length,
                  ),
                  const SizedBox(width: 6),
                  for (final tier in BossTier.values) ...[
                    _TierChip(
                      label: tier.label,
                      color: _tierColor(tier),
                      selected: selectedTier.value == tier,
                      onTap: () {
                        selectedTier.value = tier;
                        selectedBoss.value = null;
                      },
                      count: allBosses.where((b) => b.tier == tier).length,
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Boss list
                  Expanded(
                    flex: 3,
                    child: displayBosses.isEmpty
                        ? const Center(
                            child: Text('No bosses match your filters',
                                style: TextStyle(color: Colors.white38)),
                          )
                        : ListView(
                            children: [
                              for (final tier in BossTier.values)
                                if (grouped.containsKey(tier)) ...[
                                  _TierHeader(
                                      tier: tier, count: grouped[tier]!.length),
                                  for (final boss in grouped[tier]!)
                                    _BossTile(
                                      boss: boss,
                                      isSelected:
                                          selectedBoss.value?.name == boss.name,
                                      meetsReqs: playerLevels.isEmpty ||
                                          boss.meetsRequirements(playerLevels),
                                      onTap: () => selectedBoss.value = boss,
                                    ),
                                  const SizedBox(height: 12),
                                ],
                            ],
                          ),
                  ),
                  const SizedBox(width: 16),

                  // Detail panel
                  Expanded(
                    flex: 2,
                    child: selectedBoss.value != null
                        ? _BossDetailPanel(
                            boss: selectedBoss.value!,
                            playerLevels: playerLevels,
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.ads_click,
                                    size: 48,
                                    color: Colors.white.withValues(alpha: 0.1)),
                                const SizedBox(height: 12),
                                const Text(
                                  'Select a boss to see details',
                                  style: TextStyle(color: Colors.white38),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TIER CHIP
// ═══════════════════════════════════════════════════════════════════

class _TierChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final int count;

  const _TierChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : kMedBrown,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : kLightBrown.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? color : Colors.white54,
                )),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count',
                  style: TextStyle(
                    fontSize: 10,
                    color: selected ? color : Colors.white38,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TIER HEADER
// ═══════════════════════════════════════════════════════════════════

class _TierHeader extends StatelessWidget {
  final BossTier tier;
  final int count;
  const _TierHeader({required this.tier, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(tier);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Row(
        children: [
          Icon(_tierIcon(tier), size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '${tier.label} Tier',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            tier.description,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.5),
            ),
          ),
          const Spacer(),
          Text(
            '~${tier.suggestedCombat}+ cb',
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BOSS TILE
// ═══════════════════════════════════════════════════════════════════

class _BossTile extends StatelessWidget {
  final BossEntry boss;
  final bool isSelected;
  final bool meetsReqs;
  final VoidCallback onTap;

  const _BossTile({
    required this.boss,
    required this.isSelected,
    required this.meetsReqs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(boss.tier);
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: isSelected ? color.withValues(alpha: 0.1) : kBrown,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.4)
                    : kLightBrown.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // Readiness indicator
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: meetsReqs
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                // Boss info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              boss.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: meetsReqs ? kCream : Colors.white38,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (boss.isWilderness)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.warning_amber,
                                  size: 14,
                                  color: Colors.red.withValues(alpha: 0.6)),
                            ),
                          if (boss.isSkillingBoss)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.construction,
                                  size: 14,
                                  color: kGold.withValues(alpha: 0.5)),
                            ),
                          if (boss.groupSize != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.group,
                                  size: 14,
                                  color: Colors.blue.withValues(alpha: 0.5)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        boss.description,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white38),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BOSS DETAIL PANEL
// ═══════════════════════════════════════════════════════════════════

class _BossDetailPanel extends StatelessWidget {
  final BossEntry boss;
  final Map<String, int> playerLevels;

  const _BossDetailPanel({
    required this.boss,
    required this.playerLevels,
  });

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(boss.tier);
    final meetsReqs =
        playerLevels.isEmpty || boss.meetsRequirements(playerLevels);

    return Card(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Boss name + tier
            Row(
              children: [
                Icon(_tierIcon(boss.tier), size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    boss.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${boss.tier.label} Tier',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ),
                const SizedBox(width: 8),
                if (meetsReqs && playerLevels.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 12, color: Colors.green),
                        SizedBox(width: 4),
                        Text('Ready',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.green)),
                      ],
                    ),
                  )
                else if (playerLevels.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 12, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('Not Ready',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange)),
                      ],
                    ),
                  ),
                if (boss.isWilderness) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber, size: 12, color: Colors.red),
                        SizedBox(width: 4),
                        Text('Wilderness',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(boss.description,
                style: TextStyle(
                  fontSize: 13,
                  color: kCream.withValues(alpha: 0.8),
                  height: 1.5,
                )),
            const SizedBox(height: 20),

            // Requirements
            if (boss.combatReqs.isNotEmpty || boss.slayerReq != null) ...[
              const Text('Requirements',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kGold,
                  )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final entry in boss.combatReqs.entries)
                    _ReqChip(
                      skill: entry.key,
                      level: entry.value,
                      met: playerLevels.isEmpty ||
                          (playerLevels[entry.key] ?? 1) >= entry.value,
                    ),
                  if (boss.slayerReq != null)
                    _ReqChip(
                      skill: 'Slayer',
                      level: boss.slayerReq!,
                      met: playerLevels.isEmpty ||
                          (playerLevels['Slayer'] ?? 1) >= boss.slayerReq!,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Quest requirement
            if (boss.questReq != null) ...[
              const Text('Quest Required',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kGold,
                  )),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kDarkBrown.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: kLightBrown.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book,
                        size: 14, color: Colors.white38),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(boss.questReq!,
                          style: TextStyle(
                              fontSize: 12,
                              color: kCream.withValues(alpha: 0.7))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Group size
            if (boss.groupSize != null) ...[
              Row(
                children: [
                  const Icon(Icons.group, size: 14, color: Colors.white38),
                  const SizedBox(width: 6),
                  Text('Group: ${boss.groupSize}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Key drops
            if (boss.keyDrops.isNotEmpty) ...[
              const Text('Key Drops',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kGold,
                  )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final drop in boss.keyDrops)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: kGold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: kGold.withValues(alpha: 0.15)),
                      ),
                      child: Text(drop,
                          style: TextStyle(
                            fontSize: 11,
                            color: kCream.withValues(alpha: 0.8),
                          )),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Wiki link
            OutlinedButton.icon(
              onPressed: () {
                final url = Uri.parse(
                    'https://oldschool.runescape.wiki/w/${boss.wikiPath}');
                launchUrl(url);
              },
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text('View on OSRS Wiki'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kGold,
                side: BorderSide(color: kGold.withValues(alpha: 0.4)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            // Try in Idle Adventurer
            OutlinedButton.icon(
              onPressed: () => context.go('/idle-adventure'),
              icon: const Icon(Icons.sports_esports, size: 14),
              label: const Text('Try in Idle Adventurer'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFCE93D8),
                side: BorderSide(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.3)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReqChip extends StatelessWidget {
  final String skill;
  final int level;
  final bool met;
  const _ReqChip({required this.skill, required this.level, required this.met});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: met
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: met
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 12,
            color: met ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text('$level $skill',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: met ? Colors.green : Colors.orange,
              )),
        ],
      ),
    );
  }
}
