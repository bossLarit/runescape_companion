import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import 'slayer_task_data.dart';

// ═══════════════════════════════════════════════════════════════════
//  GEAR LOADOUT — data model + persistence
// ═══════════════════════════════════════════════════════════════════

enum LoadoutCategory { bossing, slayer, skilling, minigame, custom }

class GearLoadout {
  final String id;
  final String name;
  final LoadoutCategory category;
  final String? notes;
  final Map<String, String> gear; // slot -> item name
  final Map<String, String> inventory; // index (0-27) -> item name
  final DateTime createdAt;
  final DateTime updatedAt;

  const GearLoadout({
    required this.id,
    required this.name,
    this.category = LoadoutCategory.custom,
    this.notes,
    this.gear = const {},
    this.inventory = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  GearLoadout copyWith({
    String? name,
    LoadoutCategory? category,
    String? notes,
    Map<String, String>? gear,
    Map<String, String>? inventory,
    DateTime? updatedAt,
  }) =>
      GearLoadout(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        notes: notes ?? this.notes,
        gear: gear ?? this.gear,
        inventory: inventory ?? this.inventory,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'notes': notes,
        'gear': gear,
        'inventory': inventory,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory GearLoadout.fromJson(Map<String, dynamic> j) {
    return GearLoadout(
      id: j['id'] as String,
      name: j['name'] as String,
      category: LoadoutCategory.values.firstWhere(
        (e) => e.name == j['category'],
        orElse: () => LoadoutCategory.custom,
      ),
      notes: j['notes'] as String?,
      gear: (j['gear'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      inventory: (j['inventory'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  int get filledSlots => gear.length;
  int get filledInventory => inventory.length;
  bool get isEmpty => gear.isEmpty && inventory.isEmpty;
}

// ═══════════════════════════════════════════════════════════════════
//  STATE
// ═══════════════════════════════════════════════════════════════════

class GearLoadoutState {
  final List<GearLoadout> loadouts;
  final bool isLoaded;

  const GearLoadoutState({this.loadouts = const [], this.isLoaded = false});

  GearLoadoutState copyWith({List<GearLoadout>? loadouts, bool? isLoaded}) =>
      GearLoadoutState(
        loadouts: loadouts ?? this.loadouts,
        isLoaded: isLoaded ?? this.isLoaded,
      );
}

// ═══════════════════════════════════════════════════════════════════
//  PROVIDER
// ═══════════════════════════════════════════════════════════════════

final gearLoadoutProvider =
    StateNotifierProvider<GearLoadoutNotifier, GearLoadoutState>((ref) {
  return GearLoadoutNotifier(ref.watch(localStorageServiceProvider));
});

class GearLoadoutNotifier extends StateNotifier<GearLoadoutState> {
  final LocalStorageService _storage;

  GearLoadoutNotifier(this._storage) : super(const GearLoadoutState()) {
    _load();
  }

  Future<void> _load() async {
    final data = await _storage.loadJson(AppConstants.gearLoadoutsFile);
    if (data is List) {
      final loadouts = data
          .map((e) => GearLoadout.fromJson(e as Map<String, dynamic>))
          .toList();
      loadouts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = GearLoadoutState(loadouts: loadouts, isLoaded: true);
    } else {
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> _save() async {
    await _storage.saveJson(
      AppConstants.gearLoadoutsFile,
      state.loadouts.map((l) => l.toJson()).toList(),
    );
  }

  Future<GearLoadout> create({
    required String name,
    LoadoutCategory category = LoadoutCategory.custom,
    String? notes,
  }) async {
    final now = DateTime.now();
    final loadout = GearLoadout(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    state = state.copyWith(loadouts: [loadout, ...state.loadouts]);
    await _save();
    return loadout;
  }

  Future<void> update(GearLoadout loadout) async {
    final updated = loadout.copyWith(updatedAt: DateTime.now());
    final list =
        state.loadouts.map((l) => l.id == updated.id ? updated : l).toList();
    state = state.copyWith(loadouts: list);
    await _save();
  }

  Future<void> delete(String id) async {
    final list = state.loadouts.where((l) => l.id != id).toList();
    state = state.copyWith(loadouts: list);
    await _save();
  }

  Future<GearLoadout> duplicate(String id) async {
    final original = state.loadouts.firstWhere((l) => l.id == id);
    final now = DateTime.now();
    final copy = GearLoadout(
      id: now.millisecondsSinceEpoch.toString(),
      name: '${original.name} (copy)',
      category: original.category,
      notes: original.notes,
      gear: Map.of(original.gear),
      inventory: Map.of(original.inventory),
      createdAt: now,
      updatedAt: now,
    );
    state = state.copyWith(loadouts: [copy, ...state.loadouts]);
    await _save();
    return copy;
  }

  Future<void> setSlotItem(String loadoutId, String slot, String item) async {
    final loadout = state.loadouts.firstWhere((l) => l.id == loadoutId);
    final gear = Map<String, String>.from(loadout.gear);
    if (item.isEmpty) {
      gear.remove(slot);
    } else {
      gear[slot] = item;
    }
    await update(loadout.copyWith(gear: gear));
  }

  Future<void> clearSlot(String loadoutId, String slot) async {
    await setSlotItem(loadoutId, slot, '');
  }

  Future<void> setInventoryItem(
      String loadoutId, String index, String item) async {
    final loadout = state.loadouts.firstWhere((l) => l.id == loadoutId);
    final inv = Map<String, String>.from(loadout.inventory);
    if (item.isEmpty) {
      inv.remove(index);
    } else {
      inv[index] = item;
    }
    await update(loadout.copyWith(inventory: inv));
  }

  Future<void> clearInventorySlot(String loadoutId, String index) async {
    await setInventoryItem(loadoutId, index, '');
  }

  /// Auto-generate loadouts for every slayer monster using best owned gear.
  /// [bankItems] is the player's bank item set (lowercased names).
  /// [replaceExisting] controls whether previously auto-generated loadouts
  /// with the same name are replaced or skipped.
  /// Returns the number of loadouts created.
  /// The styles to generate loadouts for per monster.
  static const _generationStyles = [
    SlayerStyle.melee,
    SlayerStyle.ranged,
    SlayerStyle.magic,
    SlayerStyle.barrage,
    SlayerStyle.prayer,
  ];

  static String _styleLabel(SlayerStyle s) {
    switch (s) {
      case SlayerStyle.melee:
        return 'Melee';
      case SlayerStyle.ranged:
        return 'Ranged';
      case SlayerStyle.magic:
        return 'Magic';
      case SlayerStyle.barrage:
        return 'Barrage';
      case SlayerStyle.hybrid:
        return 'Hybrid';
      case SlayerStyle.prayer:
        return 'Prayer';
    }
  }

  Future<int> generateSlayerLoadouts({
    required Set<String> bankItems,
    bool replaceExisting = true,
  }) async {
    if (bankItems.isEmpty) return 0;

    // Work on a local copy — only set state once at the end
    final loadouts = List<GearLoadout>.from(state.loadouts);
    final newLoadouts = <GearLoadout>[];
    var baseTime = DateTime.now().millisecondsSinceEpoch;

    for (final monster in slayerMonsters) {
      for (final genStyle in _generationStyles) {
        // Skip barrage if monster can't barrage, and skip magic duplicate
        // if barrage is available (barrage uses magic gear anyway)
        if (genStyle == SlayerStyle.barrage && !monster.canBarrage) continue;
        if (genStyle == SlayerStyle.magic && monster.canBarrage) continue;

        final loadoutName =
            '${monster.name} – ${_styleLabel(genStyle)} (Slayer)';

        // Skip if already exists and not replacing
        if (!replaceExisting) {
          final exists = loadouts
              .any((l) => l.name.toLowerCase() == loadoutName.toLowerCase());
          if (exists) continue;
        }

        // If replacing, remove the old one first
        if (replaceExisting) {
          loadouts.removeWhere(
              (l) => l.name.toLowerCase() == loadoutName.toLowerCase());
        }

        // Build best gear from bank for each slot using this style
        final gear = <String, String>{};
        for (final slot in monster.relevantSlotsForStyle(genStyle)) {
          final best =
              monster.bestOwnedForSlotWithStyle(slot, bankItems, genStyle);
          if (best != null) gear[slot] = best;
        }

        // Only create if we have at least one item
        if (gear.isEmpty) continue;

        // Build special items into inventory
        final inventory = <String, String>{};
        var invIdx = 0;
        for (final special in monster.specialItems) {
          if (invIdx < 28) {
            inventory[invIdx.toString()] = special;
            invIdx++;
          }
        }

        final now = DateTime.fromMillisecondsSinceEpoch(baseTime);
        baseTime++; // ensure unique IDs

        newLoadouts.add(GearLoadout(
          id: baseTime.toString(),
          name: loadoutName,
          category: LoadoutCategory.slayer,
          notes: monster.notes != null
              ? '${monster.location} · ${monster.notes}'
              : monster.location,
          gear: gear,
          inventory: inventory,
          createdAt: now,
          updatedAt: now,
        ));
      }
    }

    // Single state update
    state = state.copyWith(loadouts: [...newLoadouts, ...loadouts]);
    await _save();
    return newLoadouts.length;
  }
}

// ─── Helpers ─────────────────────────────────────────────────────

String categoryLabel(LoadoutCategory c) {
  switch (c) {
    case LoadoutCategory.bossing:
      return 'Bossing';
    case LoadoutCategory.slayer:
      return 'Slayer';
    case LoadoutCategory.skilling:
      return 'Skilling';
    case LoadoutCategory.minigame:
      return 'Minigame';
    case LoadoutCategory.custom:
      return 'Custom';
  }
}

IconDataLookup categoryIconName(LoadoutCategory c) {
  switch (c) {
    case LoadoutCategory.bossing:
      return IconDataLookup.localFireDepartment;
    case LoadoutCategory.slayer:
      return IconDataLookup.pestControl;
    case LoadoutCategory.skilling:
      return IconDataLookup.construction;
    case LoadoutCategory.minigame:
      return IconDataLookup.sportsEsports;
    case LoadoutCategory.custom:
      return IconDataLookup.style;
  }
}

// Simple enum to avoid importing flutter/material in data layer
enum IconDataLookup {
  localFireDepartment,
  pestControl,
  construction,
  sportsEsports,
  style,
}
