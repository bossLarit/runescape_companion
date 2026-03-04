import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/osrs_api_service.dart';

final _geMappingProvider = FutureProvider<List<GeItemMapping>>((ref) async {
  return ref.watch(osrsApiServiceProvider).fetchItemMapping();
});

final _gePricesProvider = FutureProvider<Map<int, GeItemPrice>?>((ref) async {
  return ref.watch(osrsApiServiceProvider).fetchLatestPrices();
});

class GePricesScreen extends HookConsumerWidget {
  const GePricesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mappingAsync = ref.watch(_geMappingProvider);
    final pricesAsync = ref.watch(_gePricesProvider);
    final searchQuery = useState('');
    final selectedItem = useState<GeItemMapping?>(null);
    final sortBy = useState('name');
    final membersOnly = useState(false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text('GE Price Checker',
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 12),
                const Text('Live from OSRS Wiki',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh prices',
                  onPressed: () {
                    ref.invalidate(_gePricesProvider);
                    ref.invalidate(_geMappingProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 350,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText:
                          'Search items (e.g. "abyssal whip", "dragon")...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (v) => searchQuery.value = v,
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: sortBy.value,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(
                        value: 'price_high', child: Text('Price ↓')),
                    DropdownMenuItem(
                        value: 'price_low', child: Text('Price ↑')),
                  ],
                  onChanged: (v) => sortBy.value = v ?? 'name',
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Members only'),
                  selected: membersOnly.value,
                  onSelected: (v) => membersOnly.value = v,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: mappingAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Failed to load item data: $e')),
                data: (mapping) {
                  final prices = pricesAsync.valueOrNull ?? {};
                  var filtered = mapping.where((item) {
                    if (searchQuery.value.length < 2) return false;
                    if (membersOnly.value && !item.members) return false;
                    return item.name
                        .toLowerCase()
                        .contains(searchQuery.value.toLowerCase());
                  }).toList();

                  switch (sortBy.value) {
                    case 'price_high':
                      filtered.sort((a, b) {
                        final pa = prices[a.id]?.high ?? 0;
                        final pb = prices[b.id]?.high ?? 0;
                        return pb.compareTo(pa);
                      });
                    case 'price_low':
                      filtered.sort((a, b) {
                        final pa = prices[a.id]?.high ?? 0;
                        final pb = prices[b.id]?.high ?? 0;
                        return pa.compareTo(pb);
                      });
                    default:
                      filtered.sort((a, b) => a.name.compareTo(b.name));
                  }

                  if (searchQuery.value.length < 2) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monetization_on,
                              size: 48,
                              color: Colors.amber.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          const Text('Type at least 2 characters to search',
                              style: TextStyle(color: Colors.white54)),
                          Text('${mapping.length} items loaded',
                              style: const TextStyle(
                                  color: Colors.white24, fontSize: 12)),
                        ],
                      ),
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 450,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${filtered.length} results',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white38)),
                            const SizedBox(height: 4),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filtered.length.clamp(0, 200),
                                itemBuilder: (_, i) {
                                  final item = filtered[i];
                                  final price = prices[item.id];
                                  final isSelected =
                                      selectedItem.value?.id == item.id;
                                  return Card(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.2)
                                        : null,
                                    margin: const EdgeInsets.only(bottom: 2),
                                    child: ListTile(
                                      dense: true,
                                      title: Text(item.name,
                                          style: const TextStyle(fontSize: 13)),
                                      subtitle: Text(
                                        item.members ? 'Members' : 'F2P',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white38),
                                      ),
                                      trailing: price != null
                                          ? Text(
                                              _formatGp(price.high),
                                              style: const TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600),
                                            )
                                          : const Text('-',
                                              style: TextStyle(
                                                  color: Colors.white38)),
                                      onTap: () => selectedItem.value = item,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: selectedItem.value != null
                            ? _ItemDetailPanel(
                                item: selectedItem.value!,
                                price: prices[selectedItem.value!.id])
                            : const Center(
                                child: Text('Select an item',
                                    style: TextStyle(color: Colors.white38))),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatGp(int gp) {
    if (gp >= 1000000000) return '${(gp / 1000000000).toStringAsFixed(1)}B';
    if (gp >= 1000000) return '${(gp / 1000000).toStringAsFixed(1)}M';
    if (gp >= 1000) return '${(gp / 1000).toStringAsFixed(1)}K';
    return NumberFormat('#,###').format(gp);
  }
}

class _ItemDetailPanel extends StatelessWidget {
  final GeItemMapping item;
  final GeItemPrice? price;
  const _ItemDetailPanel({required this.item, this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(item.examine,
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                    label: Text(item.members ? 'Members' : 'F2P',
                        style: const TextStyle(fontSize: 11))),
                const SizedBox(width: 8),
                Chip(
                    label: Text('ID: ${item.id}',
                        style: const TextStyle(fontSize: 11))),
                if (item.limit != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                      label: Text('Buy limit: ${item.limit}',
                          style: const TextStyle(fontSize: 11))),
                ],
              ],
            ),
            const Divider(height: 32),
            if (price != null) ...[
              Text('Grand Exchange Prices',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  _PriceCard(
                      'Instant Buy (High)', price!.high, Colors.red[300]!),
                  const SizedBox(width: 16),
                  _PriceCard(
                      'Instant Sell (Low)', price!.low, Colors.green[300]!),
                  const SizedBox(width: 16),
                  _PriceCard('Average', price!.avgPrice, Colors.amber),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _PriceCard(
                      'Margin', price!.high - price!.low, Colors.blue[300]!),
                  const SizedBox(width: 16),
                  if (item.highalch != null)
                    _PriceCard(
                        'High Alch', item.highalch!, Colors.purple[300]!),
                  if (item.lowalch != null) ...[
                    const SizedBox(width: 16),
                    _PriceCard('Low Alch', item.lowalch!, Colors.purple[200]!),
                  ],
                ],
              ),
              if (item.highalch != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Alch profit: ${NumberFormat('#,###').format(item.highalch! - price!.high)} gp (buy) / '
                  '${NumberFormat('#,###').format(item.highalch! - price!.low)} gp (sell)',
                  style: TextStyle(
                    fontSize: 12,
                    color: (item.highalch! - price!.high) > 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ] else
              const Text('No price data available',
                  style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _PriceCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: color)),
            const SizedBox(height: 4),
            Text(
              '${NumberFormat('#,###').format(value)} gp',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
