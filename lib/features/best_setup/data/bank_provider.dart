import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';

final bankProvider = StateNotifierProvider<BankNotifier, BankState>((ref) {
  return BankNotifier(ref.watch(localStorageServiceProvider));
});

class BankState {
  /// Item name (lowercase) → quantity.
  final Map<String, int> items;
  final bool isLoaded;

  const BankState({this.items = const {}, this.isLoaded = false});

  BankState copyWith({Map<String, int>? items, bool? isLoaded}) => BankState(
        items: items ?? this.items,
        isLoaded: isLoaded ?? this.isLoaded,
      );

  /// Backward-compatible set of item names.
  Set<String> get itemNames => items.keys.toSet();

  bool owns(String name) => items.containsKey(name.toLowerCase());

  /// Get the quantity of a specific item (0 if not owned).
  int quantityOf(String name) => items[name.toLowerCase()] ?? 0;

  /// Sum quantities of all items whose name contains [keyword].
  int quantityMatching(String keyword) {
    final kw = keyword.toLowerCase();
    int total = 0;
    for (final entry in items.entries) {
      if (entry.key.contains(kw)) total += entry.value;
    }
    return total;
  }
}

class BankNotifier extends StateNotifier<BankState> {
  final LocalStorageService _storage;

  BankNotifier(this._storage) : super(const BankState()) {
    _load();
  }

  Future<void> _load() async {
    final data = await _storage.loadJson(AppConstants.bankItemsFile);
    if (data is Map) {
      // New format: {"item_name": quantity, ...}
      final items = <String, int>{};
      for (final entry in (data as Map<String, dynamic>).entries) {
        items[entry.key.toLowerCase()] = entry.value is int ? entry.value : 1;
      }
      state = BankState(items: items, isLoaded: true);
    } else if (data is List) {
      // Legacy format: ["item_name", ...] — treat each as qty 1
      final items = <String, int>{};
      for (final e in data) {
        items[(e as String).toLowerCase()] = 1;
      }
      state = BankState(items: items, isLoaded: true);
    } else {
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> _save() async {
    // Save as Map for quantity support
    final sorted = Map.fromEntries(
      state.items.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    await _storage.saveJson(AppConstants.bankItemsFile, sorted);
  }

  Future<void> addItem(String name, [int quantity = 1]) async {
    final lower = name.trim().toLowerCase();
    if (lower.isEmpty) return;
    final updated = {...state.items, lower: quantity};
    state = state.copyWith(items: updated);
    await _save();
  }

  Future<void> addItems(Map<String, int> nameQuantities) async {
    final updated = {...state.items};
    for (final entry in nameQuantities.entries) {
      final lower = entry.key.trim().toLowerCase();
      if (lower.isEmpty) continue;
      updated[lower] = entry.value;
    }
    state = state.copyWith(items: updated);
    await _save();
  }

  Future<void> removeItem(String name) async {
    final updated = {...state.items}..remove(name.toLowerCase());
    state = state.copyWith(items: updated);
    await _save();
  }

  Future<void> clearBank() async {
    state = state.copyWith(items: {});
    await _save();
  }

  /// Import from RuneLite Bank Memory TSV format or plain text.
  /// Supports:
  ///   - TSV: "id\tname\tquantity" per line
  ///   - Plain: one item name per line
  ///   - Comma-separated: "name x qty" or "name, name"
  Future<int> importFromText(String text) async {
    final lines =
        text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
    final parsed = <String, int>{};

    for (final line in lines) {
      // Skip header lines
      if (line.toLowerCase().startsWith('id\t') ||
          line.toLowerCase().startsWith('item id')) {
        continue;
      }

      // TSV format: id\tname\tquantity or name\tquantity
      if (line.contains('\t')) {
        final parts = line.split('\t');
        if (parts.length >= 2) {
          // Try: id\tname\tqty
          final possibleName = parts[1].trim();
          if (possibleName.isNotEmpty &&
              !RegExp(r'^\d+$').hasMatch(possibleName)) {
            final qty =
                parts.length >= 3 ? (int.tryParse(parts[2].trim()) ?? 1) : 1;
            parsed[possibleName] = qty;
            continue;
          }
          // Try: name\tqty
          final qty = int.tryParse(parts[1].trim()) ?? 1;
          parsed[parts[0].trim()] = qty;
          continue;
        }
      }

      // Comma-separated
      if (line.contains(',') && !line.contains('\t')) {
        for (final part in line.split(',')) {
          final cleaned = part.trim();
          if (cleaned.isEmpty || RegExp(r'^\d+$').hasMatch(cleaned)) continue;
          // Check for "name x qty" or "name xqty" pattern
          final xMatch = RegExp(r'^(.+?)\s+x\s*(\d+)$', caseSensitive: false)
              .firstMatch(cleaned);
          if (xMatch != null) {
            parsed[xMatch.group(1)!.trim()] =
                int.tryParse(xMatch.group(2)!) ?? 1;
          } else {
            parsed[cleaned] = 1;
          }
        }
        continue;
      }

      // Plain text: one item per line, optionally "name x qty"
      if (!RegExp(r'^\d+$').hasMatch(line)) {
        final xMatch = RegExp(r'^(.+?)\s+x\s*(\d+)$', caseSensitive: false)
            .firstMatch(line);
        if (xMatch != null) {
          parsed[xMatch.group(1)!.trim()] = int.tryParse(xMatch.group(2)!) ?? 1;
        } else {
          parsed[line] = 1;
        }
      }
    }

    if (parsed.isEmpty) return 0;
    await addItems(parsed);
    return parsed.length;
  }
}
