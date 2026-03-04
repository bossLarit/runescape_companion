import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'local_storage_service.dart';

// ═══════════════════════════════════════════════════════════════════
//  OSRS Item ID ↔ Name mapping service
//  Uses the OSRS Wiki real-time prices mapping endpoint to build
//  a bidirectional lookup between item IDs and names.
// ═══════════════════════════════════════════════════════════════════

const _mappingUrl =
    'https://prices.runescape.wiki/api/v1/osrs/mapping';
const _cacheFile = 'item_mapping_cache.json';
const _userAgent = 'OSRS Companion Desktop App';

final itemMappingServiceProvider =
    Provider<ItemMappingService>((ref) {
  return ItemMappingService(ref.watch(localStorageServiceProvider));
});

class ItemMappingService {
  final LocalStorageService _storage;

  /// id -> name
  Map<int, String>? _idToName;

  /// lowercase name -> id
  Map<String, int>? _nameToId;

  bool _loading = false;

  ItemMappingService(this._storage);

  bool get isLoaded => _idToName != null;

  /// Ensure mappings are loaded (from cache or network).
  Future<void> ensureLoaded() async {
    if (_idToName != null) return;
    if (_loading) {
      // Wait for in-progress load
      while (_loading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }
    _loading = true;
    try {
      // Try cache first
      final cached = await _storage.loadJson(_cacheFile);
      if (cached is Map<String, dynamic> && cached.isNotEmpty) {
        _buildMaps(cached);
        // Refresh in background if cache is old
        _refreshInBackground();
        return;
      }
      // Fetch from network
      await _fetchAndCache();
    } finally {
      _loading = false;
    }
  }

  /// Look up item name by ID. Returns null if not found.
  String? nameForId(int id) => _idToName?[id];

  /// Look up item ID by name (case-insensitive). Returns null if not found.
  int? idForName(String name) => _nameToId?[name.toLowerCase()];

  void _buildMaps(Map<String, dynamic> data) {
    _idToName = {};
    _nameToId = {};
    for (final entry in data.entries) {
      final id = int.tryParse(entry.key);
      final name = entry.value as String?;
      if (id != null && name != null && name.isNotEmpty) {
        _idToName![id] = name;
        _nameToId![name.toLowerCase()] = id;
      }
    }
  }

  Future<void> _fetchAndCache() async {
    try {
      final response = await http.get(
        Uri.parse(_mappingUrl),
        headers: {'User-Agent': _userAgent},
      );
      if (response.statusCode != 200) return;

      final List<dynamic> items = jsonDecode(response.body);
      final map = <String, dynamic>{};
      for (final item in items) {
        final id = item['id'];
        final name = item['name'];
        if (id != null && name != null) {
          map[id.toString()] = name;
        }
      }

      if (map.isNotEmpty) {
        _buildMaps(map);
        await _storage.saveJson(_cacheFile, map);
      }
    } catch (_) {
      // Silently fail — will retry next time
    }
  }

  void _refreshInBackground() {
    Future.microtask(() => _fetchAndCache());
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Bank Tag Layout parser / exporter
//  Format: banktaglayoutsplugin:<name>,<id>:<pos>,<id>:<pos>,...
// ═══════════════════════════════════════════════════════════════════

class BankTagLayout {
  final String tagName;

  /// position -> item ID
  final Map<int, int> layout;

  /// All item IDs in the tag
  final List<int> tagItems;

  const BankTagLayout({
    required this.tagName,
    required this.layout,
    required this.tagItems,
  });

  /// Parse a banktaglayoutsplugin export string.
  /// Handles both the layout line and the banktag line.
  static BankTagLayout? parse(String raw) {
    final lines = raw.trim().split('\n').map((l) => l.trim()).toList();
    if (lines.isEmpty) return null;

    // Combine into one string if multiline
    final full = lines.join(',');

    String? tagName;
    final layout = <int, int>{};
    final tagItems = <int>[];

    // Find the banktaglayoutsplugin section
    final layoutMatch =
        RegExp(r'banktaglayoutsplugin:([^,]+),(.+?)(?:,banktag:|$)')
            .firstMatch(full);
    if (layoutMatch != null) {
      tagName = layoutMatch.group(1);
      final pairs = layoutMatch.group(2)!.split(',');
      for (final pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final id = int.tryParse(parts[0]);
          final pos = int.tryParse(parts[1]);
          if (id != null && pos != null) {
            layout[pos] = id;
          }
        }
      }
    }

    // Find the banktag section
    final tagMatch =
        RegExp(r'banktag:([^,]+),(.+)').firstMatch(full);
    if (tagMatch != null) {
      tagName ??= tagMatch.group(1);
      final ids = tagMatch.group(2)!.split(',');
      for (final idStr in ids) {
        final id = int.tryParse(idStr.trim());
        if (id != null) tagItems.add(id);
      }
    }

    if (tagName == null && layout.isEmpty) return null;

    return BankTagLayout(
      tagName: tagName ?? 'Imported',
      layout: layout,
      tagItems: tagItems,
    );
  }

  /// Convert layout positions to item names using the mapping service.
  /// Returns a map of position -> item name.
  Map<int, String> resolveNames(ItemMappingService mapping) {
    final result = <int, String>{};
    for (final entry in layout.entries) {
      final name = mapping.nameForId(entry.value);
      if (name != null) {
        result[entry.key] = name;
      }
    }
    return result;
  }

  /// Convert a loadout's inventory to banktaglayoutsplugin format.
  static String export({
    required String tagName,
    required Map<String, String> gear,
    required Map<String, String> inventory,
    required ItemMappingService mapping,
  }) {
    final allItems = <int, int>{}; // position -> item ID
    final allIds = <int>[];
    var pos = 0;

    // Equipment slots go first (positions 0-11)
    const slotOrder = [
      'head', 'cape', 'neck', 'ammo', 'weapon', '2h',
      'body', 'shield', 'legs', 'hands', 'feet', 'ring',
    ];
    for (final slot in slotOrder) {
      final itemName = gear[slot];
      if (itemName != null) {
        final id = mapping.idForName(itemName);
        if (id != null) {
          allItems[pos] = id;
          allIds.add(id);
        }
      }
      pos++;
    }

    // Skip a row (8 empty positions for visual separator)
    pos = 16; // Start inventory after 2 rows

    // Inventory items
    for (int i = 0; i < 28; i++) {
      final key = i.toString();
      final itemName = inventory[key];
      if (itemName != null) {
        final id = mapping.idForName(itemName);
        if (id != null) {
          allItems[pos + i] = id;
          allIds.add(id);
        }
      }
    }

    // Build string
    final layoutParts =
        allItems.entries.map((e) => '${e.value}:${e.key}').join(',');
    final tagParts = allIds.join(',');

    return 'banktaglayoutsplugin:$tagName,$layoutParts,banktag:$tagName,$tagParts';
  }
}
