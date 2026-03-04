import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../characters/presentation/providers/hiscores_provider.dart';
import '../data/supply_chain_data.dart';

class IronmanSupplyScreen extends HookConsumerWidget {
  const IronmanSupplyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiscoreState = ref.watch(hiscoresProvider);
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

    final selectedSkill = useState<String?>(null);
    final viewMode = useState(0); // 0=Bottlenecks, 1=Supply Chain, 2=Priority

    final bottlenecks = playerLevels.isNotEmpty
        ? SupplyChainEngine.findBottlenecks(playerLevels)
        : <Bottleneck>[];
    final priorities = playerLevels.isNotEmpty
        ? SupplyChainEngine.trainingPriority(playerLevels)
        : <String>[];

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
                  child: Text('Ironman Supply Chain',
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9E9E9E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Ironman',
                      style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
                ),
                const Spacer(),
                if (playerLevels.isEmpty)
                  const Text('Look up a character to see bottlenecks',
                      style: TextStyle(fontSize: 11, color: Colors.white38)),
              ],
            ),
            const SizedBox(height: 16),

            // View tabs
            Row(
              children: [
                _TabChip(
                    label: 'Bottlenecks',
                    icon: Icons.warning_amber,
                    isActive: viewMode.value == 0,
                    count: bottlenecks.length,
                    onTap: () => viewMode.value = 0),
                const SizedBox(width: 6),
                _TabChip(
                    label: 'Supply Chain Map',
                    icon: Icons.account_tree,
                    isActive: viewMode.value == 1,
                    onTap: () => viewMode.value = 1),
                const SizedBox(width: 6),
                _TabChip(
                    label: 'Training Priority',
                    icon: Icons.format_list_numbered,
                    isActive: viewMode.value == 2,
                    count: priorities.length,
                    onTap: () => viewMode.value = 2),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: viewMode.value == 0
                  ? _BottleneckView(
                      bottlenecks: bottlenecks,
                      playerLevels: playerLevels,
                    )
                  : viewMode.value == 1
                      ? _SupplyChainView(
                          selectedSkill: selectedSkill,
                          playerLevels: playerLevels,
                        )
                      : _PriorityView(
                          priorities: priorities,
                          playerLevels: playerLevels,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Chip ────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final int? count;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.icon,
    required this.isActive,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFD4A017).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive
                ? const Color(0xFFD4A017).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isActive ? const Color(0xFFD4A017) : Colors.white38),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? const Color(0xFFD4A017) : Colors.white54,
                )),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFD4A017).withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$count',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color:
                          isActive ? const Color(0xFFD4A017) : Colors.white38,
                    )),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Bottleneck View ─────────────────────────────────

class _BottleneckView extends StatelessWidget {
  final List<Bottleneck> bottlenecks;
  final Map<String, int> playerLevels;

  const _BottleneckView({
    required this.bottlenecks,
    required this.playerLevels,
  });

  @override
  Widget build(BuildContext context) {
    if (playerLevels.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.white12),
            SizedBox(height: 12),
            Text('Look up your character to analyze bottlenecks',
                style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    if (bottlenecks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Color(0xFF43A047)),
            SizedBox(height: 12),
            Text('No critical bottlenecks found!',
                style: TextStyle(
                    color: Color(0xFF43A047),
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Your supply chain looks healthy.',
                style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: bottlenecks.length,
      itemBuilder: (_, i) => _BottleneckCard(
        bottleneck: bottlenecks[i],
        playerLevels: playerLevels,
      ),
    );
  }
}

class _BottleneckCard extends StatelessWidget {
  final Bottleneck bottleneck;
  final Map<String, int> playerLevels;

  const _BottleneckCard({
    required this.bottleneck,
    required this.playerLevels,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityToColor(bottleneck.severity);
    final levelsNeeded = bottleneck.neededLevel - bottleneck.currentLevel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: severityColor.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, size: 18, color: severityColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${bottleneck.skill} is bottlenecking your progress',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: severityColor,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Lvl ${bottleneck.currentLevel} → ${bottleneck.neededLevel} (+$levelsNeeded)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: severityColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(bottleneck.reason,
                  style: const TextStyle(fontSize: 11, color: Colors.white54)),
              const SizedBox(height: 8),
              // Blocked skills
              Row(
                children: [
                  const Text('Blocks: ',
                      style: TextStyle(fontSize: 10, color: Colors.white38)),
                  ...bottleneck.blockedSkills.map((s) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(s,
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.white54)),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 8),
              // Suggestion
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: const Color(0xFF43A047).withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb,
                        size: 14, color: Color(0xFF43A047)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(bottleneck.suggestion,
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF43A047))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _severityToColor(int severity) {
    switch (severity) {
      case 5:
        return const Color(0xFFD32F2F);
      case 4:
        return const Color(0xFFFF5722);
      case 3:
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFD4A017);
    }
  }
}

// ─── Supply Chain View ───────────────────────────────

class _SupplyChainView extends StatelessWidget {
  final ValueNotifier<String?> selectedSkill;
  final Map<String, int> playerLevels;

  const _SupplyChainView({
    required this.selectedSkill,
    required this.playerLevels,
  });

  @override
  Widget build(BuildContext context) {
    final skills = SupplyChainEngine.allSkills;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skill list
        SizedBox(
          width: 160,
          child: ListView.builder(
            itemCount: skills.length,
            itemBuilder: (_, i) {
              final skill = skills[i];
              final isActive = selectedSkill.value == skill;
              final level = playerLevels[skill] ?? 1;
              final linksIn = SupplyChainEngine.linksInto(skill).length;
              final linksOut = SupplyChainEngine.linksFrom(skill).length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: InkWell(
                  onTap: () => selectedSkill.value = skill,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFD4A017).withValues(alpha: 0.12)
                          : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text('$level',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? const Color(0xFFD4A017)
                                    : Colors.white38,
                              )),
                        ),
                        Expanded(
                          child: Text(skill,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isActive
                                    ? const Color(0xFFD4A017)
                                    : Colors.white70,
                              )),
                        ),
                        Text('$linksIn↓ $linksOut↑',
                            style: const TextStyle(
                                fontSize: 9, color: Colors.white24)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // Detail
        Expanded(
          child: selectedSkill.value != null
              ? _SkillChainDetail(
                  skill: selectedSkill.value!,
                  playerLevels: playerLevels,
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_tree, size: 64, color: Colors.white12),
                      SizedBox(height: 12),
                      Text('Select a skill to see its supply chain',
                          style: TextStyle(color: Colors.white38)),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _SkillChainDetail extends StatelessWidget {
  final String skill;
  final Map<String, int> playerLevels;

  const _SkillChainDetail({
    required this.skill,
    required this.playerLevels,
  });

  @override
  Widget build(BuildContext context) {
    final incoming = SupplyChainEngine.linksInto(skill);
    final outgoing = SupplyChainEngine.linksFrom(skill);
    final level = playerLevels[skill] ?? 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            color: const Color(0xFFD4A017).withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('$level',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD4A017),
                          )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(skill,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(
                            '${incoming.length} inputs  •  ${outgoing.length} outputs',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Incoming
          if (incoming.isNotEmpty) ...[
            const _SectionHeader(
                icon: Icons.arrow_downward,
                label: 'Feeds INTO this skill',
                color: Color(0xFF2196F3)),
            const SizedBox(height: 6),
            ...incoming
                .map((l) => _LinkCard(link: l, playerLevels: playerLevels)),
            const SizedBox(height: 16),
          ],

          // Outgoing
          if (outgoing.isNotEmpty) ...[
            const _SectionHeader(
                icon: Icons.arrow_upward,
                label: 'This skill SUPPLIES',
                color: Color(0xFF43A047)),
            const SizedBox(height: 6),
            ...outgoing
                .map((l) => _LinkCard(link: l, playerLevels: playerLevels)),
          ],

          if (incoming.isEmpty && outgoing.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No supply chain links for this skill.',
                    style: TextStyle(color: Colors.white38)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionHeader(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _LinkCard extends StatelessWidget {
  final SupplyLink link;
  final Map<String, int> playerLevels;
  const _LinkCard({required this.link, required this.playerLevels});

  @override
  Widget build(BuildContext context) {
    final fromLevel = playerLevels[link.fromSkill] ?? 1;
    final meetsReq = fromLevel >= link.fromLevelNeeded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Card(
        color: meetsReq
            ? const Color(0xFF43A047).withValues(alpha: 0.04)
            : const Color(0xFFFF9800).withValues(alpha: 0.04),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                meetsReq ? Icons.check_circle : Icons.warning_amber,
                size: 14,
                color: meetsReq
                    ? const Color(0xFF43A047)
                    : const Color(0xFFFF9800),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${link.fromSkill} (${link.fromLevelNeeded}) → ${link.toSkill}',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(link.resource,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD4A017))),
                    const SizedBox(height: 2),
                    Text(link.description,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white38)),
                  ],
                ),
              ),
              // Importance dots
              Row(
                children: List.generate(
                    5,
                    (i) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(left: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < link.importance
                                ? const Color(0xFFD4A017)
                                : Colors.white10,
                          ),
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Priority View ───────────────────────────────────

class _PriorityView extends StatelessWidget {
  final List<String> priorities;
  final Map<String, int> playerLevels;

  const _PriorityView({
    required this.priorities,
    required this.playerLevels,
  });

  @override
  Widget build(BuildContext context) {
    if (playerLevels.isEmpty) {
      return const Center(
        child: Text('Look up your character to see training priorities',
            style: TextStyle(color: Colors.white38)),
      );
    }

    if (priorities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Color(0xFF43A047)),
            SizedBox(height: 12),
            Text('All supply chain requirements met!',
                style: TextStyle(
                    color: Color(0xFF43A047), fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: priorities.length,
      itemBuilder: (_, i) {
        final skill = priorities[i];
        final level = playerLevels[skill] ?? 1;
        final blocks = SupplyChainEngine.linksFrom(skill)
            .where((l) => level < l.fromLevelNeeded && l.importance >= 3)
            .toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Rank
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: i == 0
                          ? const Color(0xFFD32F2F).withValues(alpha: 0.15)
                          : i < 3
                              ? const Color(0xFFFF9800).withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text('#${i + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: i == 0
                                ? const Color(0xFFD32F2F)
                                : i < 3
                                    ? const Color(0xFFFF9800)
                                    : Colors.white38,
                          )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Skill info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(skill,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 6),
                            Text('(Lvl $level)',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white38)),
                          ],
                        ),
                        if (blocks.isNotEmpty)
                          Text(
                            'Blocking: ${blocks.map((l) => '${l.toSkill} (need ${l.fromLevelNeeded})').join(', ')}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white54),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
