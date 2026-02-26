import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/osrs_api_service.dart';
import '../data/bank_provider.dart';
import 'slayer_task_helper.dart';

class BestSetupScreen extends HookConsumerWidget {
  const BestSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewTab = useState(0); // 0 = BiS Gear, 1 = Slayer Task
    final selectedStyle = useState(CombatStyle.melee);
    final selectedSlot = useState('head');
    final items = useState<List<EquipmentItem>>([]);
    final isLoading = useState(false);
    final error = useState<String?>(null);
    final selectedItem = useState<EquipmentItem?>(null);
    final searchQuery = useState('');
    final onlyMyItems = useState(false);
    final bank = ref.watch(bankProvider);

    // Fetch items when slot or style changes
    useEffect(() {
      _fetchItems(
        selectedSlot.value,
        selectedStyle.value,
        items,
        isLoading,
        error,
        selectedItem,
      );
      return null;
    }, [selectedSlot.value, selectedStyle.value]);

    final filtered = items.value.where((e) {
      if (onlyMyItems.value && !bank.owns(e.name)) return false;
      if (searchQuery.value.isEmpty) return true;
      return e.name.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header with tabs ──
            Row(
              children: [
                Text('Best-in-Slot Gear',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(width: 24),
                _ViewTabButton(
                  label: 'BiS Gear',
                  icon: Icons.shield_outlined,
                  isActive: viewTab.value == 0,
                  onTap: () => viewTab.value = 0,
                ),
                const SizedBox(width: 8),
                _ViewTabButton(
                  label: 'Slayer Task',
                  icon: Icons.pest_control,
                  isActive: viewTab.value == 1,
                  onTap: () => viewTab.value = 1,
                ),
                const Spacer(),
                if (viewTab.value == 0) ...[
                  _BankToggle(
                    enabled: onlyMyItems.value,
                    bankCount: bank.itemNames.length,
                    onToggle: (v) => onlyMyItems.value = v,
                    onManageBank: () => _showBankDialog(context, ref),
                  ),
                  const SizedBox(width: 12),
                  _buildStyleSelector(selectedStyle),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // ── Content ──
            Expanded(
              child: viewTab.value == 1
                  ? const SlayerTaskHelper()
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Slot sidebar
                        _SlotSidebar(
                          selectedSlot: selectedSlot.value,
                          onSlotChanged: (s) => selectedSlot.value = s,
                          style: selectedStyle.value,
                        ),
                        const SizedBox(width: 16),

                        // Item list
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              // Search + info
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        hintText: 'Filter items...',
                                        prefixIcon: Icon(Icons.search),
                                        isDense: true,
                                      ),
                                      onChanged: (v) => searchQuery.value = v,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      '${filtered.length}',
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Items
                              Expanded(
                                child: isLoading.value
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : error.value != null
                                        ? Center(
                                            child: Text(error.value!,
                                                style: const TextStyle(
                                                    color: Colors.red)))
                                        : filtered.isEmpty
                                            ? const Center(
                                                child: Text('No items found',
                                                    style: TextStyle(
                                                        color: Colors.white38)))
                                            : _ItemList(
                                                items: filtered,
                                                style: selectedStyle.value,
                                                selectedItem:
                                                    selectedItem.value,
                                                onSelect: (item) =>
                                                    selectedItem.value = item,
                                              ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Detail panel
                        SizedBox(
                          width: 300,
                          child: selectedItem.value != null
                              ? _ItemDetailPanel(
                                  item: selectedItem.value!,
                                  style: selectedStyle.value,
                                )
                              : const Center(
                                  child: Text('Select an item',
                                      style: TextStyle(color: Colors.white38)),
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

  Widget _buildStyleSelector(ValueNotifier<CombatStyle> style) {
    return SegmentedButton<CombatStyle>(
      segments: [
        ButtonSegment(
          value: CombatStyle.melee,
          label: const Text('Melee'),
          icon: Icon(Icons.gavel,
              size: 16, color: _styleColor(CombatStyle.melee)),
        ),
        ButtonSegment(
          value: CombatStyle.ranged,
          label: const Text('Ranged'),
          icon: Icon(Icons.arrow_forward,
              size: 16, color: _styleColor(CombatStyle.ranged)),
        ),
        ButtonSegment(
          value: CombatStyle.magic,
          label: const Text('Magic'),
          icon: Icon(Icons.auto_fix_high,
              size: 16, color: _styleColor(CombatStyle.magic)),
        ),
      ],
      selected: {style.value},
      onSelectionChanged: (s) => style.value = s.first,
    );
  }

  static void _showBankDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => const _BankManageDialog(),
    );
  }

  static Future<void> _fetchItems(
    String slot,
    CombatStyle style,
    ValueNotifier<List<EquipmentItem>> items,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> error,
    ValueNotifier<EquipmentItem?> selectedItem,
  ) async {
    isLoading.value = true;
    error.value = null;
    selectedItem.value = null;
    try {
      final result = await fetchBestInSlot(slot, style: style, limit: 100);
      items.value = result;
    } catch (e) {
      error.value = 'Failed to fetch: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

// ─── View Tab Button ─────────────────────────────────

class _ViewTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewTabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? const Color(0xFFD4A017).withValues(alpha: 0.15)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? const Color(0xFFD4A017) : Colors.white38,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? const Color(0xFFD4A017) : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bank Toggle ─────────────────────────────────────

class _BankToggle extends StatelessWidget {
  final bool enabled;
  final int bankCount;
  final ValueChanged<bool> onToggle;
  final VoidCallback onManageBank;

  const _BankToggle({
    required this.enabled,
    required this.bankCount,
    required this.onToggle,
    required this.onManageBank,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilterChip(
          label: Text(
            bankCount > 0 ? 'My Items ($bankCount)' : 'My Items',
            style: TextStyle(
              fontSize: 12,
              color: enabled ? Colors.white : Colors.white60,
            ),
          ),
          avatar: Icon(
            enabled ? Icons.inventory_2 : Icons.inventory_2_outlined,
            size: 16,
            color: enabled ? const Color(0xFFD4A017) : Colors.white38,
          ),
          selected: enabled,
          onSelected: bankCount > 0 ? onToggle : null,
          selectedColor: const Color(0xFFD4A017).withValues(alpha: 0.2),
          showCheckmark: false,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.settings, size: 16),
          tooltip: 'Manage Bank',
          onPressed: onManageBank,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
      ],
    );
  }
}

// ─── Bank Manage Dialog ──────────────────────────────

class _BankManageDialog extends HookConsumerWidget {
  const _BankManageDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bank = ref.watch(bankProvider);
    final searchCtrl = useTextEditingController();
    final searchQuery = useState('');
    final tabIndex = useState(0); // 0=My Bank, 1=Import

    final sortedItems = bank.itemNames.toList()..sort();
    final filtered = sortedItems.where((name) {
      if (searchQuery.value.isEmpty) return true;
      return name.contains(searchQuery.value.toLowerCase());
    }).toList();

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.inventory_2, color: Color(0xFFD4A017), size: 22),
          const SizedBox(width: 8),
          const Text('My Bank'),
          const Spacer(),
          Text('${bank.itemNames.length} items',
              style: const TextStyle(fontSize: 13, color: Colors.white54)),
        ],
      ),
      content: SizedBox(
        width: 550,
        height: 450,
        child: Column(
          children: [
            // Tab bar
            Row(
              children: [
                _tabButton('My Items', 0, tabIndex),
                const SizedBox(width: 8),
                _tabButton('Import', 1, tabIndex),
                const Spacer(),
                if (tabIndex.value == 0 && bank.itemNames.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Clear Bank?'),
                          content:
                              const Text('Remove all items from your bank?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel')),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Clear')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        ref.read(bankProvider.notifier).clearBank();
                      }
                    },
                    icon: const Icon(Icons.delete_outline,
                        size: 14, color: Colors.red),
                    label: const Text('Clear All',
                        style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
              ],
            ),
            const Divider(),

            // Tab content
            Expanded(
              child: tabIndex.value == 0
                  ? _buildMyItemsTab(
                      context, ref, searchCtrl, searchQuery, filtered)
                  : _buildImportTab(context, ref),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _tabButton(String label, int index, ValueNotifier<int> tabIndex) {
    final isActive = tabIndex.value == index;
    return TextButton(
      onPressed: () => tabIndex.value = index,
      style: TextButton.styleFrom(
        backgroundColor:
            isActive ? const Color(0xFFD4A017).withValues(alpha: 0.15) : null,
      ),
      child: Text(label,
          style: TextStyle(
            color: isActive ? const Color(0xFFD4A017) : Colors.white54,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          )),
    );
  }

  Widget _buildMyItemsTab(
    BuildContext context,
    WidgetRef ref,
    TextEditingController searchCtrl,
    ValueNotifier<String> searchQuery,
    List<String> filtered,
  ) {
    return Column(
      children: [
        // Search + manual add
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search or add item name...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                ),
                onChanged: (v) => searchQuery.value = v,
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) {
                    ref.read(bankProvider.notifier).addItem(v.trim());
                    searchCtrl.clear();
                    searchQuery.value = '';
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFFD4A017)),
              tooltip: 'Add item',
              onPressed: () {
                final name = searchCtrl.text.trim();
                if (name.isNotEmpty) {
                  ref.read(bankProvider.notifier).addItem(name);
                  searchCtrl.clear();
                  searchQuery.value = '';
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Item list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    searchQuery.value.isNotEmpty
                        ? 'No items matching "${searchQuery.value}"'
                        : 'No items in bank.\nUse Import tab or type an item name above.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white38),
                  ),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final name = filtered[i];
                    // Capitalize display name
                    final display = name
                        .split(' ')
                        .map((w) => w.isNotEmpty
                            ? '${w[0].toUpperCase()}${w.substring(1)}'
                            : '')
                        .join(' ');
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.shield_outlined,
                          size: 16, color: Colors.white38),
                      title:
                          Text(display, style: const TextStyle(fontSize: 13)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close,
                            size: 14, color: Colors.red),
                        onPressed: () =>
                            ref.read(bankProvider.notifier).removeItem(name),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildImportTab(BuildContext context, WidgetRef ref) {
    return _ImportTabContent(onImport: (text) async {
      final count = await ref.read(bankProvider.notifier).importFromText(text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported $count items to bank')),
        );
      }
    });
  }
}

class _ImportTabContent extends HookWidget {
  final Future<void> Function(String text) onImport;
  const _ImportTabContent({required this.onImport});

  @override
  Widget build(BuildContext context) {
    final pasteCtrl = useTextEditingController();
    final importing = useState(false);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RuneLite instructions
          Card(
            color: const Color(0xFF2A1A08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.extension, size: 18, color: Color(0xFFFF9800)),
                      SizedBox(width: 8),
                      Text('Import from RuneLite',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF9800))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _step('1',
                      'Install & enable the Bank Memory plugin from RuneLite Plugin Hub'),
                  _step('2', 'In the plugin panel, go to Saved Banks'),
                  _step('3',
                      'Right click Current Bank → Copy item data to clipboard'),
                  _step('4', 'Paste the data below and click Import'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Paste area
          TextField(
            controller: pasteCtrl,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText:
                  'Paste bank data here...\n\nSupports:\n• RuneLite Bank Memory TSV\n• One item name per line\n• Comma-separated item names',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: importing.value
                    ? null
                    : () async {
                        final text = pasteCtrl.text.trim();
                        if (text.isEmpty) return;
                        importing.value = true;
                        await onImport(text);
                        pasteCtrl.clear();
                        importing.value = false;
                      },
                icon: const Icon(Icons.file_download, size: 16),
                label: const Text('Import'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) {
                    pasteCtrl.text = data!.text!;
                  }
                },
                icon: const Icon(Icons.paste, size: 16),
                label: const Text('Paste from Clipboard'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _step(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFFF9800),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────

Color _styleColor(CombatStyle style) {
  switch (style) {
    case CombatStyle.melee:
      return const Color(0xFFE53935);
    case CombatStyle.ranged:
      return const Color(0xFF43A047);
    case CombatStyle.magic:
      return const Color(0xFF1E88E5);
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

// ─── Slot Sidebar ────────────────────────────────────

class _SlotSidebar extends StatelessWidget {
  final String selectedSlot;
  final ValueChanged<String> onSlotChanged;
  final CombatStyle style;

  const _SlotSidebar({
    required this.selectedSlot,
    required this.onSlotChanged,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Card(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for (final slot in equipmentSlots)
              _SlotTile(
                slot: slot,
                isSelected: selectedSlot == slot,
                onTap: () => onSlotChanged(slot),
                styleColor: _styleColor(style),
              ),
          ],
        ),
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  final String slot;
  final bool isSelected;
  final VoidCallback onTap;
  final Color styleColor;

  const _SlotTile({
    required this.slot,
    required this.isSelected,
    required this.onTap,
    required this.styleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: Material(
        color: isSelected
            ? styleColor.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  _slotIcon(slot),
                  size: 16,
                  color: isSelected ? styleColor : Colors.white38,
                ),
                const SizedBox(width: 8),
                Text(
                  slotDisplayName(slot),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? Colors.white : Colors.white60,
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

// ─── Item List ───────────────────────────────────────

class _ItemList extends StatelessWidget {
  final List<EquipmentItem> items;
  final CombatStyle style;
  final EquipmentItem? selectedItem;
  final ValueChanged<EquipmentItem> onSelect;

  const _ItemList({
    required this.items,
    required this.style,
    required this.selectedItem,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItem?.name == item.name;
        final primary = item.primaryOffence(style);
        final secondary = item.secondaryOffence(style);
        final isTop3 = index < 3;

        return Card(
          color: isSelected ? _styleColor(style).withValues(alpha: 0.15) : null,
          margin: const EdgeInsets.only(bottom: 2),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelect(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Rank
                  SizedBox(
                    width: 28,
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            isTop3 ? const Color(0xFFD4A017) : Colors.white38,
                      ),
                    ),
                  ),
                  // Item icon
                  Icon(
                    _slotIcon(item.slot),
                    size: 16,
                    color: isTop3 ? _styleColor(style) : Colors.white30,
                  ),
                  const SizedBox(width: 10),
                  // Name
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isTop3 ? FontWeight.w600 : FontWeight.w400,
                        color: isTop3 ? Colors.white : Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Primary stat
                  _StatChip(
                    label: _primaryLabel(style),
                    value: primary,
                    color: _styleColor(style),
                    bold: true,
                  ),
                  const SizedBox(width: 8),
                  // Secondary stat
                  _StatChip(
                    label: _secondaryLabel(style),
                    value: secondary,
                    color: Colors.white54,
                    bold: false,
                  ),
                  const SizedBox(width: 8),
                  // Prayer
                  if (item.prayerBonus > 0)
                    _StatChip(
                      label: 'Pray',
                      value: item.prayerBonus,
                      color: const Color(0xFFD4A017),
                      bold: false,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _primaryLabel(CombatStyle s) {
    switch (s) {
      case CombatStyle.melee:
        return 'Str';
      case CombatStyle.ranged:
        return 'RStr';
      case CombatStyle.magic:
        return 'MDmg';
    }
  }

  String _secondaryLabel(CombatStyle s) {
    switch (s) {
      case CombatStyle.melee:
        return 'Acc';
      case CombatStyle.ranged:
        return 'RAcc';
      case CombatStyle.magic:
        return 'MAcc';
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool bold;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bold,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = value >= 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $prefix$value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color,
        ),
      ),
    );
  }
}

// ─── Detail Panel ────────────────────────────────────

class _ItemDetailPanel extends StatelessWidget {
  final EquipmentItem item;
  final CombatStyle style;

  const _ItemDetailPanel({required this.item, required this.style});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item name
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _styleColor(style),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Slot: ${slotDisplayName(item.slot)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              if (item.weaponSpeed != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Attack speed: ${item.weaponSpeed} ticks (${(item.weaponSpeed! * 0.6).toStringAsFixed(1)}s)',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
              if (item.combatStyle != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Style: ${item.combatStyle}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
              const Divider(height: 24),

              // Attack bonuses
              _sectionHeader('Attack Bonuses', Icons.keyboard_double_arrow_up),
              const SizedBox(height: 6),
              _bonusRow('Stab', item.stabAttack, CombatStyle.melee),
              _bonusRow('Slash', item.slashAttack, CombatStyle.melee),
              _bonusRow('Crush', item.crushAttack, CombatStyle.melee),
              _bonusRow('Magic', item.magicAttack, CombatStyle.magic),
              _bonusRow('Range', item.rangeAttack, CombatStyle.ranged),

              const SizedBox(height: 12),

              // Defence bonuses
              _sectionHeader('Defence Bonuses', Icons.shield_outlined),
              const SizedBox(height: 6),
              _bonusRow('Stab', item.stabDefence, null),
              _bonusRow('Slash', item.slashDefence, null),
              _bonusRow('Crush', item.crushDefence, null),
              _bonusRow('Magic', item.magicDefence, null),
              _bonusRow('Range', item.rangeDefence, null),

              const SizedBox(height: 12),

              // Other bonuses
              _sectionHeader('Other Bonuses', Icons.star_outline),
              const SizedBox(height: 6),
              _bonusRow('Melee Str', item.strengthBonus, CombatStyle.melee),
              _bonusRow('Ranged Str', item.rangedStrength, CombatStyle.ranged),
              _bonusRow('Magic Dmg %', item.magicDamage, CombatStyle.magic),
              _bonusRow('Prayer', item.prayerBonus, null,
                  highlight: item.prayerBonus > 0),

              const SizedBox(height: 16),

              // Wiki link
              Row(
                children: [
                  const Icon(Icons.open_in_new,
                      size: 14, color: Colors.white38),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SelectableText(
                      'https://oldschool.runescape.wiki/w/${Uri.encodeComponent(item.name)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64B5F6),
                        decoration: TextDecoration.underline,
                      ),
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

  Widget _bonusRow(String label, int value, CombatStyle? relevantStyle,
      {bool highlight = false}) {
    final isRelevant = relevantStyle == style;
    final prefix = value >= 0 ? '+' : '';
    final color = highlight
        ? const Color(0xFFD4A017)
        : isRelevant
            ? _styleColor(style)
            : value > 0
                ? Colors.white70
                : value < 0
                    ? Colors.red[300]!
                    : Colors.white30;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isRelevant ? Colors.white : Colors.white54,
                fontWeight: isRelevant ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: isRelevant && value > 0
                ? BoxDecoration(
                    color: _styleColor(style).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                  )
                : null,
            child: Text(
              '$prefix$value',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isRelevant ? FontWeight.w700 : FontWeight.w400,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
