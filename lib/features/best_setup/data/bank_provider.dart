import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';

final bankProvider = StateNotifierProvider<BankNotifier, BankState>((ref) {
  return BankNotifier(ref.watch(localStorageServiceProvider));
});

class BankState {
  final Set<String> itemNames;
  final bool isLoaded;

  const BankState({this.itemNames = const {}, this.isLoaded = false});

  BankState copyWith({Set<String>? itemNames, bool? isLoaded}) => BankState(
        itemNames: itemNames ?? this.itemNames,
        isLoaded: isLoaded ?? this.isLoaded,
      );

  bool owns(String name) =>
      itemNames.contains(name.toLowerCase());
}

class BankNotifier extends StateNotifier<BankState> {
  final LocalStorageService _storage;

  BankNotifier(this._storage) : super(const BankState()) {
    _load();
  }

  Future<void> _load() async {
    final data = await _storage.loadJson(AppConstants.bankItemsFile);
    if (data is List) {
      state = BankState(
        itemNames: data.map((e) => (e as String).toLowerCase()).toSet(),
        isLoaded: true,
      );
    } else {
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> _save() async {
    await _storage.saveJson(
      AppConstants.bankItemsFile,
      state.itemNames.toList()..sort(),
    );
  }

  Future<void> addItem(String name) async {
    final lower = name.trim().toLowerCase();
    if (lower.isEmpty) return;
    final updated = {...state.itemNames, lower};
    state = state.copyWith(itemNames: updated);
    await _save();
  }

  Future<void> addItems(Iterable<String> names) async {
    final updated = {
      ...state.itemNames,
      ...names.map((n) => n.trim().toLowerCase()).where((n) => n.isNotEmpty),
    };
    state = state.copyWith(itemNames: updated);
    await _save();
  }

  Future<void> removeItem(String name) async {
    final updated = {...state.itemNames}..remove(name.toLowerCase());
    state = state.copyWith(itemNames: updated);
    await _save();
  }

  Future<void> clearBank() async {
    state = state.copyWith(itemNames: {});
    await _save();
  }

  /// Import from RuneLite Bank Memory TSV format or plain text.
  /// Supports:
  ///   - TSV: "id\tname\tquantity" per line
  ///   - Plain: one item name per line
  ///   - Comma-separated item names
  Future<int> importFromText(String text) async {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
    final names = <String>{};

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
          // Try second column as name (id\tname\tqty)
          final possibleName = parts[1].trim();
          if (possibleName.isNotEmpty &&
              !RegExp(r'^\d+$').hasMatch(possibleName)) {
            names.add(possibleName);
            continue;
          }
          // Try first column as name (name\tqty)
          names.add(parts[0].trim());
          continue;
        }
      }

      // Comma-separated
      if (line.contains(',') && !line.contains('\t')) {
        for (final part in line.split(',')) {
          final name = part.trim();
          if (name.isNotEmpty && !RegExp(r'^\d+$').hasMatch(name)) {
            names.add(name);
          }
        }
        continue;
      }

      // Plain text: one item per line
      if (!RegExp(r'^\d+$').hasMatch(line)) {
        names.add(line);
      }
    }

    if (names.isEmpty) return 0;
    await addItems(names);
    return names.length;
  }
}
