import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/services/item_mapping_service.dart';
import '../data/bank_provider.dart';
import '../data/gear_loadout_provider.dart';
import '../../../shared/widgets/bank_import_dialog.dart';

// ═══════════════════════════════════════════════════════════════════
//  GEAR LOADOUT PRESETS — main screen widget
// ═══════════════════════════════════════════════════════════════════

const _gold = kGold;
const _cardBg = Color(0xFF1E1408);

class GearLoadoutScreen extends HookConsumerWidget {
  const GearLoadoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadoutState = ref.watch(gearLoadoutProvider);
    final bank = ref.watch(bankProvider);
    final selectedId = useState<String?>(null);
    final filterCategory = useState<LoadoutCategory?>(null);
    final searchQuery = useState('');

    // Auto-select first loadout if none selected
    if (selectedId.value == null && loadoutState.loadouts.isNotEmpty) {
      selectedId.value = loadoutState.loadouts.first.id;
    }

    final filtered = loadoutState.loadouts.where((l) {
      if (filterCategory.value != null && l.category != filterCategory.value) {
        return false;
      }
      if (searchQuery.value.isNotEmpty) {
        return l.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      }
      return true;
    }).toList();

    final selected = selectedId.value != null
        ? loadoutState.loadouts
            .where((l) => l.id == selectedId.value)
            .firstOrNull
        : null;

    return Column(
      children: [
        const BankEmptyBanner(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left: Loadout list ──
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    // Search + create button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search loadouts...',
                              prefixIcon: Icon(Icons.search, size: 18),
                              isDense: true,
                            ),
                            onChanged: (v) => searchQuery.value = v,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.download, color: _gold),
                          tooltip: 'Import from RuneLite Bank Tag Layout',
                          onPressed: () =>
                              _importFromBankTag(context, ref, selectedId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.auto_awesome, color: _gold),
                          tooltip: 'Auto-generate Slayer Loadouts from Bank',
                          onPressed: () =>
                              _generateSlayerLoadouts(context, ref, selectedId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: _gold),
                          tooltip: 'New Loadout',
                          onPressed: () =>
                              _showCreateDialog(context, ref, selectedId),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Category filter chips
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            label: 'All',
                            isActive: filterCategory.value == null,
                            onTap: () => filterCategory.value = null,
                          ),
                          ...LoadoutCategory.values.map((c) => Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: _FilterChip(
                                  label: categoryLabel(c),
                                  isActive: filterCategory.value == c,
                                  onTap: () => filterCategory.value =
                                      filterCategory.value == c ? null : c,
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Count
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${filtered.length} loadout${filtered.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Loadout list
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.inventory_2_outlined,
                                      size: 40, color: Colors.white12),
                                  const SizedBox(height: 8),
                                  Text(
                                    loadoutState.loadouts.isEmpty
                                        ? 'No loadouts yet\nTap + to create one'
                                        : 'No matching loadouts',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final loadout = filtered[i];
                                final isSelected =
                                    loadout.id == selectedId.value;
                                return _LoadoutListTile(
                                  loadout: loadout,
                                  isSelected: isSelected,
                                  onTap: () => selectedId.value = loadout.id,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // ── Right: Loadout editor ──
              Expanded(
                child: selected != null
                    ? _LoadoutEditor(
                        loadout: selected,
                        bank: bank,
                        onDelete: () {
                          ref
                              .read(gearLoadoutProvider.notifier)
                              .delete(selected.id);
                          selectedId.value = null;
                        },
                        onDuplicate: () async {
                          final copy = await ref
                              .read(gearLoadoutProvider.notifier)
                              .duplicate(selected.id);
                          selectedId.value = copy.id;
                        },
                      )
                    : const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 48, color: Colors.white12),
                            SizedBox(height: 12),
                            Text(
                              'Select or create a loadout\nto start building',
                              textAlign: TextAlign.center,
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
    );
  }

  void _importFromBankTag(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<String?> selectedId,
  ) {
    showDialog(
      context: context,
      builder: (_) => _ImportBankTagDialog(
        onImported: (loadout) => selectedId.value = loadout.id,
      ),
    );
  }

  void _generateSlayerLoadouts(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<String?> selectedId,
  ) {
    final bank = ref.read(bankProvider);
    if (bank.itemNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Your bank is empty. Import your bank items first (BiS Gear tab → My Items → Manage Bank).'),
        ),
      );
      return;
    }

    // Capture messenger before entering async/dialog context
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: _gold, size: 22),
            SizedBox(width: 8),
            Text('Generate Slayer Loadouts'),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This will analyze every slayer monster\'s recommended gear '
                'and pick the best item you own for each slot.',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.inventory_2, size: 14, color: _gold),
                  const SizedBox(width: 6),
                  Text(
                    '${bank.itemNames.length} items in bank',
                    style: const TextStyle(
                        fontSize: 12,
                        color: _gold,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Existing auto-generated slayer loadouts with the same name will be replaced.',
                style: TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Generate'),
            onPressed: () async {
              Navigator.pop(dialogCtx);

              final count = await ref
                  .read(gearLoadoutProvider.notifier)
                  .generateSlayerLoadouts(bankItems: bank.itemNames);

              messenger.showSnackBar(
                SnackBar(
                  content: Text(count > 0
                      ? 'Created $count slayer loadout${count == 1 ? '' : 's'} from your bank!'
                      : 'No loadouts created — your bank didn\'t match any recommended gear.'),
                ),
              );

              // Select the first generated loadout
              final loadouts = ref.read(gearLoadoutProvider).loadouts;
              if (loadouts.isNotEmpty) {
                selectedId.value = loadouts.first.id;
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<String?> selectedId,
  ) {
    showDialog(
      context: context,
      builder: (_) => _CreateLoadoutDialog(
        onCreated: (loadout) => selectedId.value = loadout.id,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  CREATE DIALOG
// ═══════════════════════════════════════════════════════════════════

class _CreateLoadoutDialog extends HookConsumerWidget {
  final ValueChanged<GearLoadout> onCreated;
  const _CreateLoadoutDialog({required this.onCreated});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameCtrl = useTextEditingController();
    final notesCtrl = useTextEditingController();
    final category = useState(LoadoutCategory.custom);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_circle, color: _gold, size: 22),
          SizedBox(width: 8),
          Text('New Loadout'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Vorkath Setup',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g. Bring extra food for learning',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            // Category selector
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: LoadoutCategory.values.map((c) {
                final isActive = category.value == c;
                return ChoiceChip(
                  label: Text(categoryLabel(c),
                      style: const TextStyle(fontSize: 12)),
                  selected: isActive,
                  selectedColor: _gold.withValues(alpha: 0.2),
                  onSelected: (_) => category.value = c,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) return;
            final loadout = await ref.read(gearLoadoutProvider.notifier).create(
                  name: name,
                  category: category.value,
                  notes: notesCtrl.text.trim().isEmpty
                      ? null
                      : notesCtrl.text.trim(),
                );
            if (context.mounted) Navigator.pop(context);
            onCreated(loadout);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  IMPORT BANK TAG LAYOUT DIALOG
// ═══════════════════════════════════════════════════════════════════

class _ImportBankTagDialog extends HookConsumerWidget {
  final ValueChanged<GearLoadout> onImported;
  const _ImportBankTagDialog({required this.onImported});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = useTextEditingController();
    final isLoading = useState(false);
    final errorMsg = useState<String?>(null);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.download, color: _gold, size: 22),
          SizedBox(width: 8),
          Text('Import Bank Tag Layout'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste a RuneLite Bank Tag Layout export string below.\n'
              'Format: banktaglayoutsplugin:<name>,<id>:<pos>,...',
              style:
                  TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'banktaglayoutsplugin:toa,20371:0,20999:1,...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste, size: 16),
                  tooltip: 'Paste from clipboard',
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      ctrl.text = data!.text!;
                    }
                  },
                ),
              ),
            ),
            if (errorMsg.value != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMsg.value!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
            if (isLoading.value) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Fetching item names from OSRS Wiki...',
                      style: TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Import'),
          onPressed: isLoading.value
              ? null
              : () async {
                  final text = ctrl.text.trim();
                  if (text.isEmpty) {
                    errorMsg.value = 'Paste a layout string first.';
                    return;
                  }

                  final parsed = BankTagLayout.parse(text);
                  if (parsed == null || parsed.layout.isEmpty) {
                    errorMsg.value =
                        'Could not parse layout. Make sure it starts with "banktaglayoutsplugin:".';
                    return;
                  }

                  isLoading.value = true;
                  errorMsg.value = null;

                  try {
                    final mapping = ref.read(itemMappingServiceProvider);
                    await mapping.ensureLoaded();

                    if (!mapping.isLoaded) {
                      errorMsg.value =
                          'Failed to fetch item data from OSRS Wiki. Check your internet connection.';
                      isLoading.value = false;
                      return;
                    }

                    final resolvedNames = parsed.resolveNames(mapping);
                    if (resolvedNames.isEmpty) {
                      errorMsg.value =
                          'No item names could be resolved. The item database may be outdated.';
                      isLoading.value = false;
                      return;
                    }

                    // Build inventory map from layout positions
                    final inventory = <String, String>{};
                    final sortedPositions = resolvedNames.keys.toList()..sort();
                    for (var i = 0; i < sortedPositions.length; i++) {
                      inventory[i.toString()] =
                          resolvedNames[sortedPositions[i]]!;
                    }

                    // Create and populate loadout
                    final notifier = ref.read(gearLoadoutProvider.notifier);
                    final created = await notifier.create(
                      name: parsed.tagName,
                      category: LoadoutCategory.custom,
                      notes:
                          'Imported from RuneLite Bank Tag Layout (${resolvedNames.length} items)',
                    );
                    await notifier
                        .update(created.copyWith(inventory: inventory));

                    if (context.mounted) Navigator.pop(context);
                    onImported(created);
                  } catch (e) {
                    errorMsg.value = 'Import failed: $e';
                  } finally {
                    isLoading.value = false;
                  }
                },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  LOADOUT LIST TILE
// ═══════════════════════════════════════════════════════════════════

class _LoadoutListTile extends StatelessWidget {
  final GearLoadout loadout;
  final bool isSelected;
  final VoidCallback onTap;

  const _LoadoutListTile({
    required this.loadout,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? _gold.withValues(alpha: 0.12) : null,
      margin: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      _categoryColor(loadout.category).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _categoryIcon(loadout.category),
                  size: 16,
                  color: _categoryColor(loadout.category),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loadout.name,
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
                        _MiniTag(
                          label: categoryLabel(loadout.category),
                          color: _categoryColor(loadout.category),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${loadout.filledSlots} slot${loadout.filledSlots == 1 ? '' : 's'}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white30),
                        ),
                        if (loadout.filledInventory > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '· ${loadout.filledInventory} inv',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white30),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              if (isSelected)
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  LOADOUT EDITOR — equipment grid + inventory
// ═══════════════════════════════════════════════════════════════════

class _LoadoutEditor extends HookConsumerWidget {
  final GearLoadout loadout;
  final BankState bank;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const _LoadoutEditor({
    required this.loadout,
    required this.bank,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditingName = useState(false);
    final nameCtrl = useTextEditingController(text: loadout.name);

    // Sync controller when loadout changes
    useEffect(() {
      nameCtrl.text = loadout.name;
      return null;
    }, [loadout.id]);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Card(
            color: _categoryColor(loadout.category).withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Editable name
                      Expanded(
                        child: isEditingName.value
                            ? TextField(
                                controller: nameCtrl,
                                autofocus: true,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: UnderlineInputBorder(),
                                ),
                                onSubmitted: (v) {
                                  if (v.trim().isNotEmpty) {
                                    ref
                                        .read(gearLoadoutProvider.notifier)
                                        .update(
                                            loadout.copyWith(name: v.trim()));
                                  }
                                  isEditingName.value = false;
                                },
                              )
                            : GestureDetector(
                                onDoubleTap: () => isEditingName.value = true,
                                child: Text(
                                  loadout.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: _categoryColor(loadout.category),
                                      ),
                                ),
                              ),
                      ),
                      // Action buttons
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        tooltip: 'Rename',
                        onPressed: () => isEditingName.value = true,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        tooltip: 'Duplicate',
                        onPressed: onDuplicate,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 16, color: Colors.redAccent),
                        tooltip: 'Delete',
                        onPressed: () =>
                            _confirmDelete(context, loadout.name, onDelete),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Category selector row
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: LoadoutCategory.values.map((c) {
                      final isActive = loadout.category == c;
                      return ChoiceChip(
                        label: Text(categoryLabel(c),
                            style: const TextStyle(fontSize: 11)),
                        selected: isActive,
                        selectedColor:
                            _categoryColor(c).withValues(alpha: 0.25),
                        onSelected: (_) => ref
                            .read(gearLoadoutProvider.notifier)
                            .update(loadout.copyWith(category: c)),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  if (loadout.notes != null && loadout.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      loadout.notes!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white54, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Equipment Grid ──
          _sectionHeader('Equipment', Icons.shield),
          const SizedBox(height: 10),
          _EquipmentGrid(
            loadout: loadout,
            bank: bank,
          ),

          const SizedBox(height: 20),

          // ── Inventory Grid ──
          _sectionHeader('Inventory', Icons.grid_view),
          const SizedBox(height: 10),
          _InventoryGrid(
            loadout: loadout,
            bank: bank,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _gold),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _gold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
      BuildContext context, String name, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Loadout'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EQUIPMENT GRID — OSRS-style layout
// ═══════════════════════════════════════════════════════════════════

class _EquipmentGrid extends ConsumerWidget {
  final GearLoadout loadout;
  final BankState bank;

  const _EquipmentGrid({required this.loadout, required this.bank});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // OSRS-style grid: 4 columns, arranged like the equipment interface
    // Row 1: head
    // Row 2: cape, neck, ammo
    // Row 3: weapon/2h, body, shield
    // Row 4: legs
    // Row 5: hands, feet, ring

    return Center(
      child: SizedBox(
        width: 400,
        child: Column(
          children: [
            // Row 1: Head (centered)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _EquipSlotTile(
                  slot: 'head',
                  item: loadout.gear['head'],
                  bank: bank,
                  onChanged: (item) => _setSlot(ref, 'head', item),
                  onClear: () => _clearSlot(ref, 'head'),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Row 2: Cape, Neck, Ammo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _EquipSlotTile(
                  slot: 'cape',
                  item: loadout.gear['cape'],
                  bank: bank,
                  onChanged: (item) => _setSlot(ref, 'cape', item),
                  onClear: () => _clearSlot(ref, 'cape'),
                ),
                const SizedBox(width: 4),
                _EquipSlotTile(
                  slot: 'neck',
                  item: loadout.gear['neck'],
                  bank: bank,
                  onChanged: (item) => _setSlot(ref, 'neck', item),
                  onClear: () => _clearSlot(ref, 'neck'),
                ),
                const SizedBox(width: 4),
                _EquipSlotTile(
                  slot: 'ammo',
                  item: loadout.gear['ammo'],
                  bank: bank,
                  onChanged: (item) => _setSlot(ref, 'ammo', item),
                  onClear: () => _clearSlot(ref, 'ammo'),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Row 3: Weapon, Body, Shield
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _EquipSlotTile(
                  slot: 'weapon',
                  item: loadout.gear['weapon'] ?? loadout.gear['2h'],
                  bank: bank,
                  onChanged: (item) {
                    _setSlot(ref, 'weapon', item);
                    // Clear 2h if setting weapon
                    if (loadout.gear.containsKey('2h')) {
                      _clearSlot(ref, '2h');
                    }
                  },
                  onClear: () {
                    _clearSlot(ref, 'weapon');
                    _clearSlot(ref, '2h');
                  },
                  label: loadout.gear.containsKey('2h') ? '2H' : 'Weapon',
                ),
                const SizedBox(width: 4),
                _EquipSlotTile(
                  slot: 'body',
                  item: loadout.gear['body'],
                  bank: bank,
                  onChanged: (item) => _setSlot(ref, 'body', item),
                  onClear: () => _clearSlot(ref, 'body'),
                ),
                const SizedBox(width: 4),
                _EquipSlotTile(
                  slot: 'shield',
                  item: loadout.gear['shield'],
                  bank: bank,
                  isDisabled: loadout.gear.containsKey('2h'),
                  onChanged: (item) => _setSlot(ref, 'shield', item),
                  onClear: () => _clearSlot(ref, 'shield'),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Row 4: Legs (centered)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _EquipSlotTile(
                  slot: 'legs',
                  item: loadout.gear['legs'],
                  bank: bank,
                  onChanged: (item) => _setSlot(ref, 'legs', item),
                  onClear: () => _clearSlot(ref, 'legs'),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Row 5: Hands, Feet, Ring
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _EquipSlotTile(
                  slot: 'hands',
                  item: loadout.gear['hands'],
                  bank: bank,
                  onChanged: (item) => _setSlot(ref, 'hands', item),
                  onClear: () => _clearSlot(ref, 'hands'),
                ),
                const SizedBox(width: 4),
                _EquipSlotTile(
                  slot: 'feet',
                  item: loadout.gear['feet'],
                  bank: bank,
                  onChanged: (item) => _setSlot(ref, 'feet', item),
                  onClear: () => _clearSlot(ref, 'feet'),
                ),
                const SizedBox(width: 4),
                _EquipSlotTile(
                  slot: 'ring',
                  item: loadout.gear['ring'],
                  bank: bank,
                  onChanged: (item) => _setSlot(ref, 'ring', item),
                  onClear: () => _clearSlot(ref, 'ring'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setSlot(WidgetRef ref, String slot, String item) {
    ref.read(gearLoadoutProvider.notifier).setSlotItem(loadout.id, slot, item);
  }

  void _clearSlot(WidgetRef ref, String slot) {
    ref.read(gearLoadoutProvider.notifier).clearSlot(loadout.id, slot);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SINGLE EQUIPMENT SLOT TILE
// ═══════════════════════════════════════════════════════════════════

class _EquipSlotTile extends StatelessWidget {
  final String slot;
  final String? item;
  final BankState bank;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String? label;
  final bool isDisabled;

  const _EquipSlotTile({
    required this.slot,
    required this.item,
    required this.bank,
    required this.onChanged,
    required this.onClear,
    this.label,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasItem = item != null && item!.isNotEmpty;
    final isOwned = hasItem && bank.owns(item!);
    final displayLabel = label ?? _slotLabel(slot);

    return Tooltip(
      message: hasItem ? item! : displayLabel,
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () => _showSlotEditor(context, slot, item, onChanged, onClear),
        child: Container(
          width: 110,
          height: 72,
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.white.withValues(alpha: 0.02)
                : hasItem
                    ? _cardBg
                    : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDisabled
                  ? Colors.white.withValues(alpha: 0.05)
                  : hasItem
                      ? isOwned
                          ? const Color(0xFF43A047).withValues(alpha: 0.5)
                          : _gold.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!hasItem) ...[
                  Icon(
                    _slotIcon(slot),
                    size: 20,
                    color: isDisabled
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayLabel,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDisabled
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white30,
                    ),
                  ),
                ] else ...[
                  // Item name
                  Row(
                    children: [
                      if (isOwned)
                        const Padding(
                          padding: EdgeInsets.only(right: 3),
                          child: Icon(Icons.check_circle,
                              size: 10, color: Color(0xFF43A047)),
                        ),
                      Expanded(
                        child: Text(
                          item!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isOwned
                                ? const Color(0xFF43A047)
                                : Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Slot label
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      displayLabel,
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showSlotEditor(
    BuildContext context,
    String slot,
    String? currentItem,
    ValueChanged<String> onChanged,
    VoidCallback onClear,
  ) {
    showDialog(
      context: context,
      builder: (_) => _SlotEditorDialog(
        slot: slot,
        currentItem: currentItem,
        onChanged: onChanged,
        onClear: onClear,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SLOT EDITOR DIALOG
// ═══════════════════════════════════════════════════════════════════

class _SlotEditorDialog extends HookConsumerWidget {
  final String slot;
  final String? currentItem;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SlotEditorDialog({
    required this.slot,
    required this.currentItem,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = useTextEditingController(text: currentItem ?? '');
    final bank = ref.watch(bankProvider);
    final searchQuery = useState(currentItem ?? '');

    // Filter bank items that could be relevant
    final suggestions = bank.itemNames.where((name) {
      if (searchQuery.value.isEmpty) return true;
      return name.contains(searchQuery.value.toLowerCase());
    }).toList()
      ..sort();

    return AlertDialog(
      title: Row(
        children: [
          Icon(_slotIcon(slot), color: _gold, size: 20),
          const SizedBox(width: 8),
          Text('Set ${_slotLabel(slot)}'),
        ],
      ),
      content: SizedBox(
        width: 400,
        height: 350,
        child: Column(
          children: [
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type item name...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          ctrl.clear();
                          searchQuery.value = '';
                        },
                      )
                    : null,
              ),
              onChanged: (v) => searchQuery.value = v,
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  onChanged(v.trim());
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 8),
            if (bank.itemNames.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${suggestions.length} bank items',
                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                ),
              ),
            const SizedBox(height: 4),
            Expanded(
              child: suggestions.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching bank items\nYou can type any item name',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white30, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (context, i) {
                        final name = suggestions[i];
                        final isCurrentItem =
                            name == currentItem?.toLowerCase();
                        return ListTile(
                          dense: true,
                          title: Text(
                            _titleCase(name),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrentItem
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isCurrentItem ? _gold : Colors.white70,
                            ),
                          ),
                          leading: Icon(
                            isCurrentItem
                                ? Icons.check_circle
                                : Icons.inventory_2_outlined,
                            size: 16,
                            color: isCurrentItem ? _gold : Colors.white30,
                          ),
                          onTap: () {
                            onChanged(_titleCase(name));
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        if (currentItem != null && currentItem!.isNotEmpty)
          TextButton(
            onPressed: () {
              onClear();
              Navigator.pop(context);
            },
            child: const Text('Clear Slot',
                style: TextStyle(color: Colors.redAccent)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final text = ctrl.text.trim();
            if (text.isNotEmpty) {
              onChanged(text);
            }
            Navigator.pop(context);
          },
          child: const Text('Set'),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  INVENTORY GRID — 4×7 = 28 slots like OSRS
// ═══════════════════════════════════════════════════════════════════

class _InventoryGrid extends ConsumerWidget {
  final GearLoadout loadout;
  final BankState bank;

  const _InventoryGrid({required this.loadout, required this.bank});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: SizedBox(
        width: 400,
        child: Wrap(
          spacing: 3,
          runSpacing: 3,
          children: List.generate(28, (i) {
            final key = i.toString();
            final item = loadout.inventory[key];
            final hasItem = item != null && item.isNotEmpty;
            final isOwned = hasItem && bank.owns(item);

            return Tooltip(
              message: hasItem ? item : 'Slot ${i + 1}',
              child: GestureDetector(
                onTap: () => _showInventorySlotEditor(
                  context,
                  ref,
                  i,
                  item,
                ),
                child: Container(
                  width: 46,
                  height: 42,
                  decoration: BoxDecoration(
                    color: hasItem
                        ? _cardBg
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: hasItem
                          ? isOwned
                              ? const Color(0xFF43A047).withValues(alpha: 0.4)
                              : _gold.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: hasItem
                      ? Padding(
                          padding: const EdgeInsets.all(2),
                          child: Center(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w500,
                                color: isOwned
                                    ? const Color(0xFF43A047)
                                    : Colors.white54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showInventorySlotEditor(
    BuildContext context,
    WidgetRef ref,
    int index,
    String? currentItem,
  ) {
    showDialog(
      context: context,
      builder: (_) => _SlotEditorDialog(
        slot: 'inventory ${index + 1}',
        currentItem: currentItem,
        onChanged: (item) => ref
            .read(gearLoadoutProvider.notifier)
            .setInventoryItem(loadout.id, index.toString(), item),
        onClear: () => ref
            .read(gearLoadoutProvider.notifier)
            .clearInventorySlot(loadout.id, index.toString()),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SHARED WIDGETS & HELPERS
// ═══════════════════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? _gold.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? _gold.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? _gold : Colors.white54,
          ),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniTag({required this.label, required this.color});

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

Color _categoryColor(LoadoutCategory c) {
  switch (c) {
    case LoadoutCategory.bossing:
      return const Color(0xFFE53935);
    case LoadoutCategory.slayer:
      return const Color(0xFFAB47BC);
    case LoadoutCategory.skilling:
      return const Color(0xFF43A047);
    case LoadoutCategory.minigame:
      return const Color(0xFF1E88E5);
    case LoadoutCategory.custom:
      return _gold;
  }
}

IconData _categoryIcon(LoadoutCategory c) {
  switch (c) {
    case LoadoutCategory.bossing:
      return Icons.local_fire_department;
    case LoadoutCategory.slayer:
      return Icons.pest_control;
    case LoadoutCategory.skilling:
      return Icons.construction;
    case LoadoutCategory.minigame:
      return Icons.sports_esports;
    case LoadoutCategory.custom:
      return Icons.style;
  }
}

String _slotLabel(String slot) {
  const labels = {
    'head': 'Head',
    'cape': 'Cape',
    'neck': 'Neck',
    'ammo': 'Ammo',
    'weapon': 'Weapon',
    '2h': '2H Weapon',
    'shield': 'Shield',
    'body': 'Body',
    'legs': 'Legs',
    'hands': 'Hands',
    'feet': 'Feet',
    'ring': 'Ring',
  };
  return labels[slot] ?? slot;
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

String _titleCase(String s) {
  if (s.isEmpty) return s;
  return s.split(' ').map((w) {
    if (w.isEmpty) return w;
    return w[0].toUpperCase() + w.substring(1);
  }).join(' ');
}
