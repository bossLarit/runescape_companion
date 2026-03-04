import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../characters/presentation/providers/hiscores_provider.dart';
import '../data/pet_data.dart';

class PetHunterScreen extends HookConsumerWidget {
  const PetHunterScreen({super.key});

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
    final filterType = useState<PetSource?>(null);
    final showOnlyEligible = useState(false);
    final sortBy = useState<_PetSort>(_PetSort.efficiency);
    final searchQuery = useState('');
    final selectedPet = useState<PetInfo?>(null);
    final kcController = useTextEditingController(text: '0');

    var pets = List<PetInfo>.from(allPets);

    // Filter by type
    if (filterType.value != null) {
      pets = pets.where((p) => p.type == filterType.value).toList();
    }

    // Filter by eligibility
    if (showOnlyEligible.value && playerLevels.isNotEmpty) {
      pets = pets.where((p) => p.meetsRequirements(playerLevels)).toList();
    }

    // Search
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      pets = pets
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.source.toLowerCase().contains(q))
          .toList();
    }

    // Sort
    switch (sortBy.value) {
      case _PetSort.efficiency:
        pets.sort((a, b) => a.efficiencyScore.compareTo(b.efficiencyScore));
        break;
      case _PetSort.dropRate:
        pets.sort(
            (a, b) => a.dropRateDenominator.compareTo(b.dropRateDenominator));
        break;
      case _PetSort.name:
        pets.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _PetSort.source:
        pets.sort((a, b) => a.source.compareTo(b.source));
        break;
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
                  child: Text('Pet Hunting Planner',
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Pets',
                      style: TextStyle(color: Color(0xFFD4A017), fontSize: 12)),
                ),
                const Spacer(),
                Text('${pets.length} pets',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white38)),
              ],
            ),
            const SizedBox(height: 16),

            // Filters
            Row(
              children: [
                // Search
                SizedBox(
                  width: 200,
                  child: TextField(
                    onChanged: (v) => searchQuery.value = v,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Search pets...',
                      prefixIcon: Icon(Icons.search, size: 18),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),

                // Type filter
                ...PetSource.values.map((t) {
                  final isActive = filterType.value == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: FilterChip(
                      label: Text(t.name[0].toUpperCase() + t.name.substring(1),
                          style: TextStyle(
                              fontSize: 10,
                              color: isActive
                                  ? const Color(0xFFD4A017)
                                  : Colors.white54)),
                      selected: isActive,
                      selectedColor:
                          const Color(0xFFD4A017).withValues(alpha: 0.15),
                      onSelected: (_) => filterType.value = isActive ? null : t,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
                const SizedBox(width: 8),

                // Eligible only
                if (playerLevels.isNotEmpty)
                  FilterChip(
                    label: Text('Eligible only',
                        style: TextStyle(
                            fontSize: 10,
                            color: showOnlyEligible.value
                                ? const Color(0xFF43A047)
                                : Colors.white54)),
                    selected: showOnlyEligible.value,
                    selectedColor:
                        const Color(0xFF43A047).withValues(alpha: 0.15),
                    onSelected: (v) => showOnlyEligible.value = v,
                    visualDensity: VisualDensity.compact,
                  ),
                const Spacer(),

                // Sort
                const Text('Sort: ',
                    style: TextStyle(fontSize: 11, color: Colors.white38)),
                DropdownButton<_PetSort>(
                  value: sortBy.value,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                  items: _PetSort.values
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) sortBy.value = v;
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet list
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (_, i) {
                        final pet = pets[i];
                        final isSelected = selectedPet.value == pet;
                        final eligible = playerLevels.isEmpty ||
                            pet.meetsRequirements(playerLevels);
                        return _PetCard(
                          pet: pet,
                          isSelected: isSelected,
                          isEligible: eligible,
                          onTap: () {
                            selectedPet.value = pet;
                            kcController.text = '0';
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Detail panel
                  SizedBox(
                    width: 360,
                    child: selectedPet.value != null
                        ? _PetDetailPanel(
                            pet: selectedPet.value!,
                            kcController: kcController,
                            playerLevels: playerLevels,
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pets,
                                    size: 64, color: Colors.white12),
                                SizedBox(height: 12),
                                Text('Select a pet to see details',
                                    style: TextStyle(color: Colors.white38)),
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

// ─── Pet Card ────────────────────────────────────────

class _PetCard extends StatelessWidget {
  final PetInfo pet;
  final bool isSelected;
  final bool isEligible;
  final VoidCallback onTap;

  const _PetCard({
    required this.pet,
    required this.isSelected,
    required this.isEligible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(pet.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Card(
        color: isSelected
            ? const Color(0xFFD4A017).withValues(alpha: 0.08)
            : !isEligible
                ? Colors.white.withValues(alpha: 0.01)
                : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Type indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(pet.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color:
                                    isEligible ? Colors.white : Colors.white38,
                              )),
                          if (!isEligible) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.lock,
                                size: 11, color: Colors.white24),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(pet.source,
                          style: TextStyle(
                              fontSize: 10,
                              color: isEligible
                                  ? Colors.white54
                                  : Colors.white24)),
                    ],
                  ),
                ),

                // Rate
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('1/${_fmtNum(pet.dropRateDenominator)}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD4A017))),
                    const SizedBox(height: 2),
                    Text(PetHuntingEngine.formatHours(pet.hoursFor50),
                        style: TextStyle(
                            fontSize: 10,
                            color: pet.hoursFor50 < 50
                                ? const Color(0xFF43A047)
                                : pet.hoursFor50 < 200
                                    ? const Color(0xFFFF9800)
                                    : Colors.white38)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _typeColor(PetSource type) {
    switch (type) {
      case PetSource.boss:
        return const Color(0xFFE53935);
      case PetSource.skilling:
        return const Color(0xFF43A047);
      case PetSource.minigame:
        return const Color(0xFF2196F3);
      case PetSource.other:
        return const Color(0xFF9E9E9E);
    }
  }

  String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

// ─── Detail Panel ────────────────────────────────────

class _PetDetailPanel extends HookWidget {
  final PetInfo pet;
  final TextEditingController kcController;
  final Map<String, int> playerLevels;

  const _PetDetailPanel({
    required this.pet,
    required this.kcController,
    required this.playerLevels,
  });

  @override
  Widget build(BuildContext context) {
    final kcValue = useState(0);

    void updateKc() {
      kcValue.value = int.tryParse(kcController.text) ?? 0;
    }

    final kc = kcValue.value;
    final prob = pet.probAfterKills(kc);
    final eligible =
        playerLevels.isEmpty || pet.meetsRequirements(playerLevels);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet header
          Card(
            color: const Color(0xFFD4A017).withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pets,
                          size: 24, color: Color(0xFFD4A017)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pet.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            Text('From: ${pet.source}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white54)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: eligible
                              ? const Color(0xFF43A047).withValues(alpha: 0.15)
                              : const Color(0xFFE53935).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          eligible ? 'Eligible' : 'Locked',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: eligible
                                ? const Color(0xFF43A047)
                                : const Color(0xFFE53935),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (pet.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(pet.notes,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white54,
                            fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stats
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                      'Drop Rate', '1/${_fmtNum(pet.dropRateDenominator)}',
                      color: const Color(0xFFD4A017))),
              const SizedBox(width: 6),
              Expanded(
                  child: _StatTile(
                      'Kills/hr', pet.killsPerHour.toStringAsFixed(0),
                      color: const Color(0xFF2196F3))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                  child: _StatTile('50% chance',
                      '${_fmtNum(pet.killsFor50)} KC (${PetHuntingEngine.formatHours(pet.hoursFor50)})',
                      color: const Color(0xFFFF9800))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                  child: _StatTile('90% chance',
                      '${_fmtNum(pet.killsFor90)} KC (${PetHuntingEngine.formatHours(pet.hoursFor90)})',
                      color: const Color(0xFFE53935))),
            ],
          ),
          const SizedBox(height: 16),

          // KC Calculator
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calculate, size: 14, color: Color(0xFF2196F3)),
                      SizedBox(width: 6),
                      Text('Your Progress',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2196F3))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: kcController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Your Kill Count',
                            prefixIcon: Icon(Icons.repeat, size: 18),
                          ),
                          style: const TextStyle(fontSize: 14),
                          onChanged: (_) => updateKc(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: updateKc,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        child:
                            const Text('Calc', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  if (kc > 0) ...[
                    const SizedBox(height: 12),
                    // Probability result
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _verdictColor(prob).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                prob > 0.9
                                    ? Icons.sentiment_very_dissatisfied
                                    : prob > 0.5
                                        ? Icons.sentiment_dissatisfied
                                        : Icons.sentiment_neutral,
                                size: 28,
                                color: _verdictColor(prob),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${(prob * 100).toStringAsFixed(1)}% chance you should have it',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _verdictColor(prob),
                                      ),
                                    ),
                                    Text(
                                      _verdict(prob, kc),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: prob.clamp(0, 1),
                              minHeight: 8,
                              backgroundColor: Colors.white10,
                              valueColor:
                                  AlwaysStoppedAnimation(_verdictColor(prob)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // How much further
                    Text(
                      'Expected drops by now: ${(kc * pet.dropChance).toStringAsFixed(2)}',
                      style:
                          const TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                    Text(
                      'Kills to 50%: ${_fmtNum(pet.killsFor50)}  |  To 90%: ${_fmtNum(pet.killsFor90)}',
                      style:
                          const TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Requirements
          if (pet.requirements.isNotEmpty || pet.questReq != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Requirements',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54)),
                    const SizedBox(height: 6),
                    ...pet.requirements.entries.map((e) {
                      final has = (playerLevels[e.key] ?? 1) >= e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Icon(
                              has ? Icons.check_circle : Icons.cancel,
                              size: 12,
                              color: has
                                  ? const Color(0xFF43A047)
                                  : const Color(0xFFE53935),
                            ),
                            const SizedBox(width: 6),
                            Text('${e.key}: ${e.value}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        has ? Colors.white70 : Colors.white38)),
                            if (playerLevels.containsKey(e.key))
                              Text(' (you: ${playerLevels[e.key]})',
                                  style: const TextStyle(
                                      fontSize: 9, color: Colors.white30)),
                          ],
                        ),
                      );
                    }),
                    if (pet.questReq != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book,
                                size: 12, color: Colors.white38),
                            const SizedBox(width: 6),
                            Text('Quest: ${pet.questReq}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white54)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Also trains
          if (pet.alsoTrains.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              color: const Color(0xFF43A047).withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 14, color: Color(0xFF43A047)),
                        SizedBox(width: 6),
                        Text('Also trains while hunting:',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF43A047))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: pet.alsoTrains
                          .map((s) => Chip(
                                label: Text(s,
                                    style: const TextStyle(fontSize: 10)),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _verdictColor(double prob) {
    if (prob < 0.5) return const Color(0xFF43A047);
    if (prob < 0.75) return const Color(0xFFFF9800);
    if (prob < 0.9) return const Color(0xFFFF5722);
    if (prob < 0.95) return const Color(0xFFD32F2F);
    return const Color(0xFFB71C1C);
  }

  String _verdict(double prob, int kc) {
    final pct = (prob * 100).toStringAsFixed(0);
    if (prob < 0.25) return 'Still early — keep going!';
    if (prob < 0.5) {
      return 'Not dry yet. $pct% of players would have it by now.';
    }
    if (prob < 0.75) return 'Getting unlucky. $pct% of players would have it.';
    if (prob < 0.9) {
      return 'Pretty dry! Only ${(100 - prob * 100).toStringAsFixed(0)}% of players go this dry.';
    }
    if (prob < 0.95) {
      return 'Very dry! Top ${(100 - prob * 100).toStringAsFixed(1)}% unluckiest.';
    }
    return 'Astronomically dry! Top ${(100 - prob * 100).toStringAsFixed(2)}% unluckiest.';
  }

  String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatTile(this.label, this.value, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 9, color: Colors.white38)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

enum _PetSort {
  efficiency,
  dropRate,
  name,
  source;

  String get label {
    switch (this) {
      case _PetSort.efficiency:
        return 'Efficiency';
      case _PetSort.dropRate:
        return 'Drop Rate';
      case _PetSort.name:
        return 'Name';
      case _PetSort.source:
        return 'Source';
    }
  }
}
