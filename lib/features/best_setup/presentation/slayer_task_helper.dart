import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/bank_provider.dart';
import '../data/slayer_task_data.dart';
import '../../../core/services/osrs_api_service.dart';

class SlayerTaskHelper extends HookConsumerWidget {
  const SlayerTaskHelper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedMonster = useState<SlayerMonster?>(null);
    final bank = ref.watch(bankProvider);
    final showOnlyOwned = useState(false);

    // Filter monsters by search
    final filtered = slayerMonsters.where((m) {
      if (searchQuery.value.isEmpty) return true;
      final q = searchQuery.value.toLowerCase();
      return m.name.toLowerCase().contains(q) ||
          m.alternatives.any((a) => a.toLowerCase().contains(q));
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left: Monster list ──
        SizedBox(
          width: 320,
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search slayer task...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  suffixIcon: searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            searchController.clear();
                            searchQuery.value = '';
                          },
                        )
                      : null,
                ),
                onChanged: (v) => searchQuery.value = v,
              ),
              const SizedBox(height: 8),

              // Monster count
              Row(
                children: [
                  Text(
                    '${filtered.length} slayer tasks',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white38),
                  ),
                  const Spacer(),
                  Text(
                    'Bank: ${bank.itemNames.length} items',
                    style: TextStyle(
                      fontSize: 11,
                      color: bank.itemNames.isNotEmpty
                          ? const Color(0xFFD4A017)
                          : Colors.white38,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Monster list
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final monster = filtered[index];
                    final isSelected =
                        selectedMonster.value?.name == monster.name;
                    return _MonsterListTile(
                      monster: monster,
                      isSelected: isSelected,
                      onTap: () => selectedMonster.value = monster,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // ── Right: Gear recommendation panel ──
        Expanded(
          child: selectedMonster.value != null
              ? _GearRecommendationPanel(
                  monster: selectedMonster.value!,
                  bank: bank,
                  showOnlyOwned: showOnlyOwned.value,
                  onToggleOwned: (v) => showOnlyOwned.value = v,
                )
              : const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pest_control, size: 48, color: Colors.white12),
                      SizedBox(height: 12),
                      Text(
                        'Select a slayer task to see\nrecommended gear',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Monster List Tile ───────────────────────────────────────────

class _MonsterListTile extends StatelessWidget {
  final SlayerMonster monster;
  final bool isSelected;
  final VoidCallback onTap;

  const _MonsterListTile({
    required this.monster,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final styleColor = _slayerStyleColor(monster.style);
    return Card(
      color: isSelected ? styleColor.withValues(alpha: 0.15) : null,
      margin: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Slayer level badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: styleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${monster.slayerLevel}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: monster.slayerLevel > 1
                          ? styleColor
                          : Colors.white38,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Name + info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monster.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _StyleBadge(style: monster.style),
                        if (monster.canCannon) ...[
                          const SizedBox(width: 4),
                          _TagBadge(
                              label: 'Cannon',
                              color: const Color(0xFFFF9800)),
                        ],
                        if (monster.canBarrage) ...[
                          const SizedBox(width: 4),
                          _TagBadge(
                              label: 'Barrage',
                              color: const Color(0xFF1E88E5)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Special items indicator
              if (monster.specialItems.isNotEmpty)
                const Tooltip(
                  message: 'Special item required',
                  child: Icon(Icons.warning_amber,
                      size: 16, color: Color(0xFFFF9800)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gear Recommendation Panel ───────────────────────────────────

class _GearRecommendationPanel extends StatelessWidget {
  final SlayerMonster monster;
  final BankState bank;
  final bool showOnlyOwned;
  final ValueChanged<bool> onToggleOwned;

  const _GearRecommendationPanel({
    required this.monster,
    required this.bank,
    required this.showOnlyOwned,
    required this.onToggleOwned,
  });

  @override
  Widget build(BuildContext context) {
    final styleColor = _slayerStyleColor(monster.style);
    final slots = monster.relevantSlots;

    // Count how many slots have a bank match
    int ownedSlotCount = 0;
    for (final slot in slots) {
      if (monster.bestOwnedForSlot(slot, bank.itemNames) != null) {
        ownedSlotCount++;
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Monster header ──
          Card(
            color: styleColor.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          monster.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: styleColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      _StyleBadge(style: monster.style, large: true),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (monster.slayerLevel > 1)
                        _InfoChip(
                          icon: Icons.star,
                          label: '${monster.slayerLevel} Slayer',
                          color: const Color(0xFFD4A017),
                        ),
                      _InfoChip(
                        icon: Icons.location_on,
                        label: monster.location,
                        color: Colors.white54,
                      ),
                      if (monster.canCannon)
                        const _InfoChip(
                          icon: Icons.rocket_launch,
                          label: 'Cannon',
                          color: Color(0xFFFF9800),
                        ),
                      if (monster.canBarrage)
                        const _InfoChip(
                          icon: Icons.auto_fix_high,
                          label: 'Barrage',
                          color: Color(0xFF1E88E5),
                        ),
                    ],
                  ),
                  if (monster.specialItems.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              const Color(0xFFFF9800).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber,
                              size: 16, color: Color(0xFFFF9800)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Required: ${monster.specialItems.join(', ')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFF9800),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (monster.notes != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      monster.notes!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white54, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Bank match summary ──
          if (bank.itemNames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.inventory_2,
                      size: 16, color: styleColor),
                  const SizedBox(width: 6),
                  Text(
                    'You own gear for $ownedSlotCount / ${slots.length} slots',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ownedSlotCount == slots.length
                          ? const Color(0xFF43A047)
                          : styleColor,
                    ),
                  ),
                  const Spacer(),
                  FilterChip(
                    label: const Text('Owned only',
                        style: TextStyle(fontSize: 11)),
                    selected: showOnlyOwned,
                    onSelected: onToggleOwned,
                    visualDensity: VisualDensity.compact,
                    selectedColor: styleColor.withValues(alpha: 0.2),
                    showCheckmark: true,
                    checkmarkColor: styleColor,
                  ),
                ],
              ),
            ),

          // ── Gear slots ──
          ...slots.map((slot) => _GearSlotCard(
                slot: slot,
                items: monster.gearForSlot(slot),
                bestOwned: monster.bestOwnedForSlot(slot, bank.itemNames),
                bankItems: bank.itemNames,
                styleColor: styleColor,
                showOnlyOwned: showOnlyOwned,
              )),

          // ── Notable drops ──
          if (monster.notableDrops.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionHeader('Notable Drops', Icons.card_giftcard),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: monster.notableDrops
                  .map((d) => Chip(
                        label: Text(d, style: const TextStyle(fontSize: 11)),
                        backgroundColor:
                            const Color(0xFFD4A017).withValues(alpha: 0.1),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(
                          color:
                              const Color(0xFFD4A017).withValues(alpha: 0.3),
                        ),
                      ))
                  .toList(),
            ),
          ],

          // ── Alternatives ──
          if (monster.alternatives.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionHeader('Alternatives / Boss Variants', Icons.swap_horiz),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: monster.alternatives
                  .map((a) => Chip(
                        label: Text(a, style: const TextStyle(fontSize: 11)),
                        avatar: const Icon(Icons.star_outline,
                            size: 14, color: Color(0xFFD4A017)),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],

          // ── Wiki link ──
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.open_in_new, size: 14, color: Colors.white38),
              const SizedBox(width: 6),
              Expanded(
                child: SelectableText(
                  'https://oldschool.runescape.wiki/w/${monster.wikiPath}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64B5F6),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFD4A017)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD4A017),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Gear Slot Card ──────────────────────────────────────────────

class _GearSlotCard extends StatelessWidget {
  final String slot;
  final List<String> items;
  final String? bestOwned;
  final Set<String> bankItems;
  final Color styleColor;
  final bool showOnlyOwned;

  const _GearSlotCard({
    required this.slot,
    required this.items,
    required this.bestOwned,
    required this.bankItems,
    required this.styleColor,
    required this.showOnlyOwned,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = showOnlyOwned
        ? items
            .where((i) => bankItems.contains(i.toLowerCase()))
            .toList()
        : items;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slot header
              Row(
                children: [
                  Icon(_slotIcon(slot), size: 16, color: styleColor),
                  const SizedBox(width: 8),
                  Text(
                    slotDisplayName(slot),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: styleColor,
                    ),
                  ),
                  if (bestOwned != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 12, color: Color(0xFF43A047)),
                          const SizedBox(width: 4),
                          Text(
                            'Owned',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF43A047),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),

              // Item list
              ...displayItems.asMap().entries.map((entry) {
                final rank = entry.key;
                final item = entry.value;
                final isOwned =
                    bankItems.contains(item.toLowerCase());
                final isBestOwned = item == bestOwned;
                final isTop = rank == 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                      // Rank
                      SizedBox(
                        width: 22,
                        child: Text(
                          '${rank + 1}.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isTop
                                ? const Color(0xFFD4A017)
                                : Colors.white30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Owned indicator
                      if (isOwned)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: isBestOwned
                                ? const Color(0xFF43A047)
                                : const Color(0xFF43A047)
                                    .withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(width: 12),
                      // Item name
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isBestOwned
                                ? FontWeight.w700
                                : isTop
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                            color: isBestOwned
                                ? const Color(0xFF43A047)
                                : isOwned
                                    ? Colors.white
                                    : isTop
                                        ? Colors.white70
                                        : Colors.white38,
                          ),
                        ),
                      ),
                      if (isBestOwned)
                        const Text(
                          '← YOUR BEST',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF43A047),
                            letterSpacing: 0.5,
                          ),
                        ),
                    ],
                  ),
                );
              }),

              if (displayItems.isEmpty)
                const Text(
                  'No matching items in bank',
                  style: TextStyle(fontSize: 11, color: Colors.white30),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared widgets ──────────────────────────────────────────────

class _StyleBadge extends StatelessWidget {
  final SlayerStyle style;
  final bool large;

  const _StyleBadge({required this.style, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = _slayerStyleColor(style);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 8 : 5,
        vertical: large ? 3 : 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        _slayerStyleLabel(style),
        style: TextStyle(
          fontSize: large ? 11 : 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TagBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────

Color _slayerStyleColor(SlayerStyle style) {
  switch (style) {
    case SlayerStyle.melee:
      return const Color(0xFFE53935);
    case SlayerStyle.ranged:
      return const Color(0xFF43A047);
    case SlayerStyle.magic:
    case SlayerStyle.barrage:
      return const Color(0xFF1E88E5);
    case SlayerStyle.hybrid:
      return const Color(0xFFAB47BC);
  }
}

String _slayerStyleLabel(SlayerStyle style) {
  switch (style) {
    case SlayerStyle.melee:
      return 'MELEE';
    case SlayerStyle.ranged:
      return 'RANGED';
    case SlayerStyle.magic:
      return 'MAGIC';
    case SlayerStyle.barrage:
      return 'BARRAGE';
    case SlayerStyle.hybrid:
      return 'HYBRID';
  }
}

IconData _slotIcon(String slot) {
  switch (slot) {
    case 'head':
      return Icons.face;
    case 'cape':
      return Icons.curtains;
    case 'neck':
      return Icons.circle_outlined;
    case 'ammo':
      return Icons.bolt;
    case 'weapon':
      return Icons.gavel;
    case '2h':
      return Icons.sports_martial_arts;
    case 'shield':
      return Icons.shield;
    case 'body':
      return Icons.checkroom;
    case 'legs':
      return Icons.airline_seat_legroom_normal;
    case 'hands':
      return Icons.back_hand_outlined;
    case 'feet':
      return Icons.do_not_step;
    case 'ring':
      return Icons.trip_origin;
    default:
      return Icons.help_outline;
  }
}
