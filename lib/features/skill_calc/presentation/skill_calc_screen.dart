import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../characters/presentation/providers/characters_provider.dart';
import '../../characters/presentation/providers/hiscores_provider.dart';
import '../../characters/domain/character_model.dart';
import '../../goal_planner/data/training_methods_data.dart';
import '../../goal_planner/data/micro_goals_engine.dart';
import '../data/skill_actions_data.dart';

// ─── XP helpers (re-export from micro_goals_engine) ──

String _fmtNum(num n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(2)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return n.toStringAsFixed(n is double ? 1 : 0);
}

String _fmtInt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(2)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}

// ─── Superglass Make data ────────────────────────────

enum _SGMethod {
  twoSeaweed,
  threeSeaweedNoPick,
  threeSeaweedPick,
}

extension _SGMethodExt on _SGMethod {
  String get label {
    switch (this) {
      case _SGMethod.twoSeaweed:
        return '2 giant seaweed + 12 sand';
      case _SGMethod.threeSeaweedNoPick:
        return '3 giant seaweed + 18 sand (no pickup)';
      case _SGMethod.threeSeaweedPick:
        return '3 giant seaweed + 18 sand (pickup)';
    }
  }

  int get seaweedPerCast {
    switch (this) {
      case _SGMethod.twoSeaweed:
        return 2;
      case _SGMethod.threeSeaweedNoPick:
      case _SGMethod.threeSeaweedPick:
        return 3;
    }
  }

  int get sandPerCast {
    switch (this) {
      case _SGMethod.twoSeaweed:
        return 12;
      case _SGMethod.threeSeaweedNoPick:
      case _SGMethod.threeSeaweedPick:
        return 18;
    }
  }

  double get glassPerSeaweed {
    switch (this) {
      case _SGMethod.twoSeaweed:
        return 8.7;
      case _SGMethod.threeSeaweedNoPick:
        return 8.9;
      case _SGMethod.threeSeaweedPick:
        return 9.6;
    }
  }

  double get glassPerSand {
    switch (this) {
      case _SGMethod.twoSeaweed:
        return 1.45;
      case _SGMethod.threeSeaweedNoPick:
        return 1.49;
      case _SGMethod.threeSeaweedPick:
        return 1.6;
    }
  }
}

class _GlassProduct {
  final String name;
  final int levelReq;
  final double xpPerItem;
  const _GlassProduct(this.name, this.levelReq, this.xpPerItem);
}

const _glassProducts = [
  _GlassProduct('Beer glass', 1, 17.5),
  _GlassProduct('Candle lantern', 4, 19.0),
  _GlassProduct('Oil lamp', 12, 25.0),
  _GlassProduct('Vial', 33, 35.0),
  _GlassProduct('Fishbowl', 42, 42.5),
  _GlassProduct('Unpowered orb', 46, 52.5),
  _GlassProduct('Lantern lens', 49, 55.0),
  _GlassProduct('Dorgeshuun light orb', 87, 70.0),
];

// ─── Main Screen ─────────────────────────────────────

class SkillCalcScreen extends HookConsumerWidget {
  const SkillCalcScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider);
    final hiscoreState = ref.watch(hiscoresProvider);
    final tabIndex = useState(0);

    final isIronman = activeChar != null &&
        {
          CharacterType.iron,
          CharacterType.hcim,
          CharacterType.uim,
          CharacterType.gim,
          CharacterType.hcgim,
        }.contains(activeChar.characterType);

    final playerLevels = <String, int>{};
    hiscoreState.whenData((result) {
      if (result != null) {
        for (final entry in result.skills.entries) {
          playerLevels[entry.key] = entry.value.level;
        }
      }
    });

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
                  child: Text('Skill Calculator',
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                if (activeChar != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(activeChar.displayName,
                        style: const TextStyle(
                            color: Color(0xFFD4A017), fontSize: 12)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Tab bar
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                    value: 0,
                    label: Text('General Skill Calc',
                        style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.calculate, size: 16)),
                ButtonSegment(
                    value: 1,
                    label:
                        Text('Superglass Make', style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.science, size: 16)),
              ],
              selected: {tabIndex.value},
              onSelectionChanged: (s) => tabIndex.value = s.first,
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: tabIndex.value == 0
                  ? _GeneralCalcTab(
                      playerLevels: playerLevels, isIronman: isIronman)
                  : _SuperglassTab(playerLevels: playerLevels),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── General Skill Calculator ────────────────────────

class _GeneralCalcTab extends HookWidget {
  final Map<String, int> playerLevels;
  final bool isIronman;
  const _GeneralCalcTab({required this.playerLevels, required this.isIronman});

  @override
  Widget build(BuildContext context) {
    final skillNames = allSkillActions.keys.toList()..sort();
    final selectedSkill = useState(skillNames.first);
    final currentLvlCtrl = useTextEditingController(
        text: '${playerLevels[skillNames.first] ?? 1}');
    final targetLvlCtrl = useTextEditingController(text: '99');
    final selectedCategory = useState<String?>(null);
    final searchQuery = useState('');

    // Update current level when skill changes
    useValueChanged<String, bool>(selectedSkill.value, (_, __) {
      final lvl = playerLevels[selectedSkill.value] ?? 1;
      currentLvlCtrl.text = '$lvl';
      selectedCategory.value = null;
      searchQuery.value = '';
      return true;
    });

    // Rebuild when the user edits either level field
    useListenable(currentLvlCtrl);
    useListenable(targetLvlCtrl);

    final currentLevel = (int.tryParse(currentLvlCtrl.text) ?? 1).clamp(1, 99);
    final targetLevel =
        (int.tryParse(targetLvlCtrl.text) ?? 99).clamp(currentLevel + 1, 99);
    final xpNeeded = xpBetween(currentLevel, targetLevel);
    final currentXp = xpForLevel(currentLevel);
    final targetXp = xpForLevel(targetLevel);

    // Get actions for selected skill
    final allActions = allSkillActions[selectedSkill.value] ?? [];

    // Get categories
    final categories = allActions
        .map((a) => a.category)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();

    // Filter actions
    final filtered = allActions.where((a) {
      if (selectedCategory.value != null &&
          a.category != selectedCategory.value) {
        return false;
      }
      if (searchQuery.value.isNotEmpty) {
        final q = searchQuery.value.toLowerCase();
        if (!a.name.toLowerCase().contains(q) &&
            !(a.notes ?? '').toLowerCase().contains(q) &&
            !(a.category ?? '').toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Milestones from training data
    final info = trainingData[selectedSkill.value];
    final milestones = info?.milestones
            .where((m) => m.level > currentLevel && m.level <= 99)
            .toList() ??
        [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Inputs + Actions table
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input row
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              value: selectedSkill.value,
                              decoration: const InputDecoration(
                                  labelText: 'Skill', isDense: true),
                              items: skillNames
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (v) =>
                                  selectedSkill.value = v ?? skillNames.first,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: currentLvlCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Current', isDense: true),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: targetLvlCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Target', isDense: true),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _QuickBtn(
                              label: '99',
                              active: targetLevel == 99,
                              onTap: () => targetLvlCtrl.text = '99'),
                          if (milestones.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            _QuickBtn(
                                label: 'Next (${milestones.first.level})',
                                active: targetLevel == milestones.first.level,
                                onTap: () => targetLvlCtrl.text =
                                    '${milestones.first.level}'),
                          ],
                          const Spacer(),
                          // XP needed badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4A017)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('XP Needed',
                                    style: TextStyle(
                                        fontSize: 9, color: Colors.white38)),
                                Text(_fmtInt(xpNeeded),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD4A017))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Category chips + search
                      Row(
                        children: [
                          // Search
                          SizedBox(
                            width: 180,
                            height: 32,
                            child: TextField(
                              style: const TextStyle(fontSize: 11),
                              decoration: InputDecoration(
                                hintText: 'Search actions...',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                prefixIcon: const Icon(Icons.search, size: 14),
                                prefixIconConstraints: const BoxConstraints(
                                    minWidth: 28, minHeight: 0),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              onChanged: (v) => searchQuery.value = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Category filter chips
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterChip(
                                    label: 'All',
                                    selected: selectedCategory.value == null,
                                    onTap: () => selectedCategory.value = null,
                                  ),
                                  for (final cat in categories) ...[
                                    const SizedBox(width: 4),
                                    _FilterChip(
                                      label: cat,
                                      selected: selectedCategory.value == cat,
                                      onTap: () => selectedCategory.value = cat,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Actions table header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 40,
                        child: Text('Lv',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white30))),
                    const Expanded(
                        flex: 3,
                        child: Text('Action',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white30))),
                    const SizedBox(
                        width: 70,
                        child: Text('XP/action',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white30))),
                    const SizedBox(
                        width: 70,
                        child: Text('Actions',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white30))),
                    if (MediaQuery.of(context).size.width > 900)
                      const SizedBox(
                          width: 70,
                          child: Text('XP/hr',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white30))),
                    const SizedBox(
                        width: 70,
                        child: Text('Time',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white30))),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Actions list
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No actions found',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white38)))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final a = filtered[i];
                          final canDo = a.levelReq <= currentLevel;
                          final actionsNeeded = a.xpPerAction > 0
                              ? (xpNeeded / a.xpPerAction).ceil()
                              : null;
                          final hours = a.xpPerHour != null && a.xpPerHour! > 0
                              ? xpNeeded / a.xpPerHour!
                              : (a.xpPerAction > 0 ? null : null);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: i.isEven
                                  ? Colors.white.withValues(alpha: 0.02)
                                  : Colors.transparent,
                              border: canDo
                                  ? null
                                  : Border(
                                      left: BorderSide(
                                          color:
                                              Colors.red.withValues(alpha: 0.3),
                                          width: 2)),
                            ),
                            child: Row(
                              children: [
                                // Level
                                SizedBox(
                                  width: 40,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: canDo
                                          ? const Color(0xFF43A047)
                                              .withValues(alpha: 0.12)
                                          : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('${a.levelReq}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: canDo
                                                ? const Color(0xFF43A047)
                                                : Colors.red
                                                    .withValues(alpha: 0.6))),
                                  ),
                                ),
                                // Name + notes
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(a.name,
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: canDo
                                                        ? Colors.white
                                                        : Colors.white38),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          if (a.category != null) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 0),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.05),
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                              child: Text(a.category!,
                                                  style: const TextStyle(
                                                      fontSize: 8,
                                                      color: Colors.white24)),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (a.notes != null)
                                        Text(a.notes!,
                                            style: const TextStyle(
                                                fontSize: 9,
                                                color: Colors.white30),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                // XP/action
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                      a.xpPerAction > 0
                                          ? _fmtNum(a.xpPerAction)
                                          : '—',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white54)),
                                ),
                                // Actions needed
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                      actionsNeeded != null
                                          ? _fmtNum(actionsNeeded)
                                          : '—',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70)),
                                ),
                                // XP/hr
                                if (MediaQuery.of(context).size.width > 900)
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                        a.xpPerHour != null
                                            ? _fmtInt(a.xpPerHour!)
                                            : '—',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF43A047))),
                                  ),
                                // Time
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                      hours != null
                                          ? MicroGoalsEngine.formatHours(hours)
                                          : '—',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF42A5F5))),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Right: Summary + Milestones
        SizedBox(
          width: 240,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Level card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('$currentLevel',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w700)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.arrow_forward,
                                  size: 14, color: Colors.white30),
                            ),
                            Text('$targetLevel',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD4A017))),
                            const SizedBox(width: 8),
                            Text(selectedSkill.value,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white38)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: targetXp > 0
                                ? (currentXp / targetXp).clamp(0.0, 1.0)
                                : 0,
                            minHeight: 6,
                            backgroundColor: Colors.white10,
                            valueColor:
                                const AlwaysStoppedAnimation(Color(0xFFD4A017)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmtInt(currentXp),
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.white30)),
                            Text(_fmtInt(targetXp),
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.white30)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Milestones
                if (milestones.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.flag,
                                  size: 14, color: Color(0xFFD4A017)),
                              SizedBox(width: 4),
                              Text('Milestones',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD4A017))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          for (final m in milestones.take(8))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 1),
                                    decoration: BoxDecoration(
                                      color: m.level <= targetLevel
                                          ? const Color(0xFF43A047)
                                              .withValues(alpha: 0.15)
                                          : Colors.white
                                              .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('${m.level}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: m.level <= targetLevel
                                                ? const Color(0xFF43A047)
                                                : Colors.white30)),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(m.unlock,
                                        style: const TextStyle(
                                            fontSize: 9, color: Colors.white54),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                // Stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ResultRow(
                            label: 'XP Needed',
                            value: _fmtInt(xpNeeded),
                            valueColor: const Color(0xFFD4A017)),
                        _ResultRow(
                            label: 'Current XP', value: _fmtInt(currentXp)),
                        _ResultRow(
                            label: 'Target XP', value: _fmtInt(targetXp)),
                        _ResultRow(
                            label: 'Actions shown',
                            value: '${filtered.length}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFD4A017).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFD4A017) : Colors.white12,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? const Color(0xFFD4A017) : Colors.white38)),
      ),
    );
  }
}

// ─── Superglass Make Tab ─────────────────────────────

class _SuperglassTab extends HookWidget {
  final Map<String, int> playerLevels;
  const _SuperglassTab({required this.playerLevels});

  @override
  Widget build(BuildContext context) {
    final method = useState(_SGMethod.threeSeaweedPick);
    final product = useState(_glassProducts[5]); // Unpowered orb default
    final targetCtrl = useTextEditingController(text: '');
    final calcMode = useState<_CalcMode>(_CalcMode.targetLevel);
    final seaweedCount = useTextEditingController(text: '');
    final currentCtrl =
        useTextEditingController(text: '${playerLevels['Crafting'] ?? 1}');

    // Listen to controller changes so results update reactively
    useListenable(targetCtrl);
    useListenable(currentCtrl);
    useListenable(seaweedCount);

    final currentMagic = playerLevels['Magic'] ?? 1;
    final hasLunarDiplomacy = currentMagic >= 77;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Superglass info
          if (!hasLunarDiplomacy)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, size: 16, color: Color(0xFFFF9800)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Superglass Make requires 77 Magic and Lunar Diplomacy quest.',
                      style: TextStyle(fontSize: 11, color: Color(0xFFFF9800)),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Inputs
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Method card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.science,
                                    size: 16, color: Color(0xFF42A5F5)),
                                SizedBox(width: 6),
                                Text('Superglass Make Method',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF42A5F5))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            for (final m in _SGMethod.values)
                              RadioListTile<_SGMethod>(
                                value: m,
                                groupValue: method.value,
                                title: Text(m.label,
                                    style: const TextStyle(fontSize: 12)),
                                subtitle: Text(
                                    '~${m.glassPerSeaweed} glass/seaweed  ·  ~${m.glassPerSand} glass/sand',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white38)),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (v) =>
                                    method.value = v ?? method.value,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Glass product + calc mode
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_awesome,
                                    size: 16, color: Color(0xFFD4A017)),
                                SizedBox(width: 6),
                                Text('Glass Product',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD4A017))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<_GlassProduct>(
                              value: product.value,
                              decoration: const InputDecoration(
                                  labelText: 'Blow into...', isDense: true),
                              items: _glassProducts
                                  .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                          '${p.name} (Lv${p.levelReq}, ${p.xpPerItem} xp)',
                                          style:
                                              const TextStyle(fontSize: 12))))
                                  .toList(),
                              onChanged: (v) =>
                                  product.value = v ?? product.value,
                            ),
                            const SizedBox(height: 16),

                            // Calc mode
                            SegmentedButton<_CalcMode>(
                              segments: const [
                                ButtonSegment(
                                    value: _CalcMode.targetLevel,
                                    label: Text('Target Level',
                                        style: TextStyle(fontSize: 11))),
                                ButtonSegment(
                                    value: _CalcMode.seaweedAmount,
                                    label: Text('Seaweed Amount',
                                        style: TextStyle(fontSize: 11))),
                              ],
                              selected: {calcMode.value},
                              onSelectionChanged: (s) =>
                                  calcMode.value = s.first,
                            ),
                            const SizedBox(height: 12),

                            if (calcMode.value == _CalcMode.targetLevel)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: currentCtrl,
                                      decoration: const InputDecoration(
                                          labelText: 'Current Crafting',
                                          isDense: true),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: targetCtrl,
                                      decoration: const InputDecoration(
                                          labelText: 'Target Level',
                                          isDense: true,
                                          hintText: '99'),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: seaweedCount,
                                  decoration: const InputDecoration(
                                      labelText: 'Giant Seaweed Count',
                                      isDense: true,
                                      hintText: '1000'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Right: Results
              Expanded(
                flex: 2,
                child: _SuperglassResults(
                  method: method.value,
                  product: product.value,
                  calcMode: calcMode.value,
                  currentLevelText: currentCtrl.text,
                  targetLevelText: targetCtrl.text,
                  seaweedText: seaweedCount.text,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reference table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.table_chart, size: 16, color: Colors.white54),
                      SizedBox(width: 6),
                      Text('Superglass Make Reference',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                    },
                    children: [
                      const TableRow(
                        children: [
                          Text('Method',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white38)),
                          Text('Glass/Seaweed',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white38)),
                          Text('Glass/Sand',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white38)),
                          Text('XP/Seaweed (orbs)',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white38)),
                        ],
                      ),
                      for (final m in _SGMethod.values)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(m.label,
                                  style: const TextStyle(fontSize: 10)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text('~${m.glassPerSeaweed}',
                                  style: const TextStyle(fontSize: 10)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text('~${m.glassPerSand}',
                                  style: const TextStyle(fontSize: 10)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                  '~${(m.glassPerSeaweed * 52.5 + 10).toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 10)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CalcMode { targetLevel, seaweedAmount }

class _SuperglassResults extends HookWidget {
  final _SGMethod method;
  final _GlassProduct product;
  final _CalcMode calcMode;
  final String currentLevelText;
  final String targetLevelText;
  final String seaweedText;

  const _SuperglassResults({
    required this.method,
    required this.product,
    required this.calcMode,
    required this.currentLevelText,
    required this.targetLevelText,
    required this.seaweedText,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuild on text change
    useListenable(Listenable.merge([]));

    final currentLevel = (int.tryParse(currentLevelText) ?? 1).clamp(1, 99);

    int? seaweedNeeded;
    int? sandNeeded;
    int? glassProduced;
    int? xpFromBlowing;
    int? xpFromSpell;
    int? totalXp;
    int? castsNeeded;
    int? levelsGained;

    // Superglass Make gives 10 Magic XP + 3 Crafting XP per glass made via spell
    // Plus crafting XP from blowing
    const spellCraftXpPerGlass = 3.0; // from the spell itself
    const magicXpPerCast = 78.0;
    final blowXpPerGlass = product.xpPerItem;

    if (calcMode == _CalcMode.targetLevel) {
      final targetLvl = int.tryParse(targetLevelText) ?? 99;
      final effective = targetLvl.clamp(currentLevel + 1, 99);
      final xpNeeded = xpBetween(currentLevel, effective);

      // Total crafting XP per glass = spell XP + blow XP
      final totalXpPerGlass = spellCraftXpPerGlass + blowXpPerGlass;
      glassProduced = (xpNeeded / totalXpPerGlass).ceil();
      seaweedNeeded = (glassProduced / method.glassPerSeaweed).ceil();
      sandNeeded = (glassProduced / method.glassPerSand).ceil();
      castsNeeded = (seaweedNeeded / method.seaweedPerCast).ceil();
      xpFromBlowing = (glassProduced * blowXpPerGlass).round();
      xpFromSpell = (glassProduced * spellCraftXpPerGlass).round();
      totalXp = xpFromBlowing + xpFromSpell;
      levelsGained = effective - currentLevel;
    } else {
      final swCount = int.tryParse(seaweedText);
      if (swCount != null && swCount > 0) {
        seaweedNeeded = swCount;
        glassProduced = (swCount * method.glassPerSeaweed).round();
        sandNeeded =
            (swCount * method.sandPerCast / method.seaweedPerCast).ceil();
        castsNeeded = (swCount / method.seaweedPerCast).ceil();
        xpFromBlowing = (glassProduced * blowXpPerGlass).round();
        xpFromSpell = (glassProduced * spellCraftXpPerGlass).round();
        totalXp = xpFromBlowing + xpFromSpell;

        // Calculate levels gained
        final currentXp = xpForLevel(currentLevel);
        final finalXp = currentXp + totalXp;
        int finalLevel = currentLevel;
        for (int l = currentLevel + 1; l <= 99; l++) {
          if (finalXp >= xpForLevel(l)) {
            finalLevel = l;
          } else {
            break;
          }
        }
        levelsGained = finalLevel - currentLevel;
      }
    }

    final hasResult = seaweedNeeded != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calculate, size: 16, color: Color(0xFF43A047)),
                  SizedBox(width: 6),
                  Text('Results',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF43A047))),
                ],
              ),
              const Divider(height: 20),
              if (!hasResult)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Enter a target to see results',
                        style: TextStyle(fontSize: 11, color: Colors.white38)),
                  ),
                )
              else ...[
                _ResultRow(
                    label: 'Giant Seaweed',
                    value: _fmtNum(seaweedNeeded),
                    valueColor: const Color(0xFF43A047)),
                _ResultRow(
                    label: 'Buckets of Sand', value: _fmtNum(sandNeeded!)),
                _ResultRow(
                    label: 'Molten Glass',
                    value: _fmtNum(glassProduced!),
                    valueColor: const Color(0xFF42A5F5)),
                _ResultRow(label: 'Spell Casts', value: _fmtNum(castsNeeded!)),
                const Divider(height: 16),
                _ResultRow(
                    label: 'XP (blowing)', value: _fmtInt(xpFromBlowing!)),
                _ResultRow(label: 'XP (spell)', value: _fmtInt(xpFromSpell!)),
                _ResultRow(
                    label: 'Total Crafting XP',
                    value: _fmtInt(totalXp!),
                    valueColor: const Color(0xFFD4A017)),
                _ResultRow(
                    label: 'Magic XP',
                    value: _fmtInt((castsNeeded * magicXpPerCast).round())),
                if (levelsGained != null && levelsGained > 0)
                  _ResultRow(
                      label: 'Levels Gained',
                      value: '+$levelsGained',
                      valueColor: const Color(0xFFD4A017)),
                const Divider(height: 16),

                // Seaweed runs
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '≈ ${(seaweedNeeded / 30).ceil()} seaweed patch runs (6 patches × ~5 seaweed each)',
                    style: const TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '≈ ${(sandNeeded / 168).ceil()} Sandstorm mine trips (24 per inventory)',
                    style: const TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────

class _QuickBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _QuickBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFD4A017).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? const Color(0xFFD4A017) : Colors.white12,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: active ? const Color(0xFFD4A017) : Colors.white38)),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ResultRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white54)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.white70)),
        ],
      ),
    );
  }
}
