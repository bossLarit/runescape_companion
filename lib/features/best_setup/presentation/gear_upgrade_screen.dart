import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/bank_provider.dart';
import '../data/gear_upgrade_data.dart';
import '../../../shared/widgets/bank_import_dialog.dart';

class GearUpgradeScreen extends HookConsumerWidget {
  const GearUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bank = ref.watch(bankProvider);
    final styleFilter = useState<UpgradeStyle?>(null);

    if (bank.itemNames.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2,
                size: 48, color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: 12),
            const Text(
              'Import your bank first to see\npersonalized gear upgrade priorities',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => showBankImportDialog(context),
              icon: const Icon(Icons.file_upload, size: 16),
              label: const Text('Import Bank'),
            ),
          ],
        ),
      );
    }

    final allUpgrades = calculateUpgrades(bank.itemNames);
    final filtered = styleFilter.value != null
        ? allUpgrades.where((u) => u.style == styleFilter.value).toList()
        : allUpgrades;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left: Summary + filters ──
        SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              Card(
                color: const Color(0xFFD4A017).withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.trending_up,
                              size: 16, color: Color(0xFFD4A017)),
                          SizedBox(width: 6),
                          Text(
                            'Upgrade Summary',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD4A017),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _summaryRow(
                          'Total upgrades available', '${allUpgrades.length}'),
                      _summaryRow('Free upgrades',
                          '${allUpgrades.where((u) => u.gpCost == 0).length}'),
                      _summaryRow('Under 5M GP',
                          '${allUpgrades.where((u) => u.gpCost > 0 && u.gpCost < 5000000).length}'),
                      _summaryRow('Over 50M GP',
                          '${allUpgrades.where((u) => u.gpCost >= 50000000).length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Style filter
              const Text(
                'FILTER BY STYLE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white38,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _FilterChipWidget(
                    label: 'All',
                    isSelected: styleFilter.value == null,
                    color: const Color(0xFFD4A017),
                    onTap: () => styleFilter.value = null,
                  ),
                  _FilterChipWidget(
                    label: 'Melee',
                    isSelected: styleFilter.value == UpgradeStyle.melee,
                    color: const Color(0xFFE53935),
                    onTap: () => styleFilter.value = UpgradeStyle.melee,
                  ),
                  _FilterChipWidget(
                    label: 'Ranged',
                    isSelected: styleFilter.value == UpgradeStyle.ranged,
                    color: const Color(0xFF43A047),
                    onTap: () => styleFilter.value = UpgradeStyle.ranged,
                  ),
                  _FilterChipWidget(
                    label: 'Magic',
                    isSelected: styleFilter.value == UpgradeStyle.magic,
                    color: const Color(0xFF1E88E5),
                    onTap: () => styleFilter.value = UpgradeStyle.magic,
                  ),
                  _FilterChipWidget(
                    label: 'General',
                    isSelected: styleFilter.value == UpgradeStyle.general,
                    color: const Color(0xFF7E57C2),
                    onTap: () => styleFilter.value = UpgradeStyle.general,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Legend
              Card(
                color: Colors.white.withValues(alpha: 0.03),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HOW TO READ',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white38,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _legendRow(const Color(0xFF43A047),
                          'Best value — upgrade first'),
                      _legendRow(const Color(0xFFD4A017), 'Good value'),
                      _legendRow(
                          const Color(0xFFFF9800), 'Expensive but impactful'),
                      _legendRow(const Color(0xFFE53935), 'Endgame / luxury'),
                      const SizedBox(height: 8),
                      const Text(
                        'Sorted by GP per 1% DPS increase.\n'
                        'Free upgrades are always shown first.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white30,
                          height: 1.4,
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

        // ── Right: Upgrade list ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.upgrade, size: 16, color: Color(0xFFD4A017)),
                  const SizedBox(width: 6),
                  Text(
                    'Recommended Upgrades — ${filtered.length} available',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD4A017),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No upgrades available for this filter.\nYou may already have BiS!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _UpgradeCard(
                            upgrade: filtered[index],
                            rank: index + 1,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ),
          Text(value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD4A017),
              )),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: color, width: 1),
            ),
          ),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(fontSize: 10, color: Colors.white38)),
        ],
      ),
    );
  }
}

// ─── Filter Chip ─────────────────────────────────────────────────

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChipWidget({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? color.withValues(alpha: 0.4) : Colors.white12,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? color : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Upgrade Card ────────────────────────────────────────────────

class _UpgradeCard extends StatelessWidget {
  final GearUpgradeRecommendation upgrade;
  final int rank;

  const _UpgradeCard({required this.upgrade, required this.rank});

  Color get _valueColor {
    if (upgrade.gpCost == 0) return const Color(0xFF43A047);
    if (upgrade.gpPerPercent < 1000000) return const Color(0xFF43A047);
    if (upgrade.gpPerPercent < 5000000) return const Color(0xFFD4A017);
    if (upgrade.gpPerPercent < 20000000) return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  Color get _styleColor {
    switch (upgrade.style) {
      case UpgradeStyle.melee:
        return const Color(0xFFE53935);
      case UpgradeStyle.ranged:
        return const Color(0xFF43A047);
      case UpgradeStyle.magic:
        return const Color(0xFF1E88E5);
      case UpgradeStyle.general:
        return const Color(0xFF7E57C2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Card(
        color: _valueColor.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 30,
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: rank <= 3 ? _valueColor : Colors.white38,
                  ),
                ),
              ),

              // Value indicator bar
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _valueColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),

              // Upgrade info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Style badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: _styleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            styleLabel(upgrade.style),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _styleColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          upgrade.slot,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          upgrade.currentItem,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.arrow_forward,
                              size: 12, color: Colors.white24),
                        ),
                        Expanded(
                          child: Text(
                            upgrade.upgradeItem,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (upgrade.note != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        upgrade.note!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white30,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // DPS increase
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, size: 12, color: _valueColor),
                      const SizedBox(width: 3),
                      Text(
                        '+${upgrade.dpsIncrease.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _valueColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatGp(upgrade.gpCost),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: upgrade.gpCost == 0
                          ? const Color(0xFF43A047)
                          : Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
