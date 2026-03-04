import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/osrs_api_service.dart';
import '../data/wiki_item_parser.dart';

class ItemLookupScreen extends HookConsumerWidget {
  const ItemLookupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchCtrl = useTextEditingController();
    final searchQuery = useState('');
    final searchResults = useState<List<WikiSearchResult>>([]);
    final isSearching = useState(false);
    final selectedItem = useState<WikiItemInfo?>(null);
    final selectedTitle = useState<String?>(null);
    final isLoadingItem = useState(false);
    final loadError = useState<String?>(null);
    final recentSearches = useState<List<String>>([]);

    Future<void> doSearch(String query) async {
      if (query.trim().isEmpty) return;
      isSearching.value = true;
      searchResults.value = [];
      selectedItem.value = null;
      final api = ref.read(osrsApiServiceProvider);
      final results = await api.searchWiki(query, limit: 20);
      searchResults.value = results;
      isSearching.value = false;
      // Add to recents
      final recents = List<String>.from(recentSearches.value);
      recents.remove(query);
      recents.insert(0, query);
      if (recents.length > 8) recents.removeLast();
      recentSearches.value = recents;
    }

    Future<void> loadItem(String title) async {
      selectedTitle.value = title;
      isLoadingItem.value = true;
      loadError.value = null;
      selectedItem.value = null;
      final api = ref.read(osrsApiServiceProvider);
      final wikitext = await api.fetchWikiPageWikitext(title);
      if (wikitext == null) {
        loadError.value = 'Could not load wiki page for "$title"';
        isLoadingItem.value = false;
        return;
      }
      final info = parseWikitext(title, wikitext);
      selectedItem.value = info;
      isLoadingItem.value = false;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item Lookup',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            const Text(
              'Search for any OSRS item to see how it is made or obtained',
              style: TextStyle(fontSize: 12, color: Colors.white38),
            ),
            const SizedBox(height: 16),

            // ── Search bar ──
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search item name...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      isDense: true,
                      suffixIcon: searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                searchCtrl.clear();
                                searchQuery.value = '';
                                searchResults.value = [];
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) => searchQuery.value = v,
                    onSubmitted: doSearch,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: searchQuery.value.isEmpty
                      ? null
                      : () => doSearch(searchQuery.value),
                  icon: const Icon(Icons.search, size: 16),
                  label: const Text('Search'),
                ),
              ],
            ),

            // Recent searches
            if (recentSearches.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: recentSearches.value
                    .map((s) => ActionChip(
                          label: Text(s, style: const TextStyle(fontSize: 11)),
                          onPressed: () {
                            searchCtrl.text = s;
                            searchQuery.value = s;
                            doSearch(s);
                          },
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),

            // ── Content ──
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left: Search results ──
                  SizedBox(
                    width: 320,
                    child: isSearching.value
                        ? const Center(child: CircularProgressIndicator())
                        : searchResults.value.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.inventory_2,
                                        size: 48,
                                        color: Colors.white
                                            .withValues(alpha: 0.08)),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Search for an item to see\nhow it is created',
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: Colors.white38),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: searchResults.value.length,
                                itemBuilder: (context, index) {
                                  final result =
                                      searchResults.value[index];
                                  final isSelected =
                                      selectedTitle.value == result.title;
                                  return Card(
                                    color: isSelected
                                        ? const Color(0xFFD4A017)
                                            .withValues(alpha: 0.12)
                                        : null,
                                    margin:
                                        const EdgeInsets.only(bottom: 2),
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      onTap: () => loadItem(result.title),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              result.title,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? const Color(
                                                        0xFFD4A017)
                                                    : Colors.white70,
                                              ),
                                            ),
                                            if (result.snippet
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                result.snippet,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white38,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                  const SizedBox(width: 16),

                  // ── Right: Item detail ──
                  Expanded(
                    child: isLoadingItem.value
                        ? const Center(child: CircularProgressIndicator())
                        : loadError.value != null
                            ? Center(
                                child: Text(loadError.value!,
                                    style:
                                        const TextStyle(color: Colors.red)))
                            : selectedItem.value != null
                                ? _ItemDetailPanel(
                                    info: selectedItem.value!,
                                    wikiTitle: selectedTitle.value ?? '',
                                  )
                                : const Center(
                                    child: Text(
                                      'Select a search result to see\nhow to make or obtain it',
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: Colors.white38),
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

// ─── Item Detail Panel ───────────────────────────────────────────

class _ItemDetailPanel extends StatelessWidget {
  final WikiItemInfo info;
  final String wikiTitle;

  const _ItemDetailPanel({required this.info, required this.wikiTitle});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Item header ──
          Card(
            color: const Color(0xFFD4A017).withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFD4A017),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (info.examine != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      info.examine!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (info.members)
                        _chip(Icons.star, 'Members', const Color(0xFFD4A017)),
                      if (!info.tradeable)
                        _chip(Icons.block, 'Untradeable',
                            const Color(0xFFE53935)),
                      if (info.tradeable)
                        _chip(Icons.swap_horiz, 'Tradeable',
                            const Color(0xFF43A047)),
                      if (info.quest != null)
                        _chip(Icons.auto_stories, info.quest!,
                            const Color(0xFF64B5F6)),
                      if (info.weight != null)
                        _chip(Icons.fitness_center, '${info.weight} kg',
                            Colors.white38),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Creation methods ──
          if (info.creationMethods.isNotEmpty) ...[
            _sectionHeader('Creation', Icons.build),
            const SizedBox(height: 8),
            ...info.creationMethods
                .asMap()
                .entries
                .map((e) => _CreationMethodCard(
                      method: e.value,
                      index: e.key,
                      total: info.creationMethods.length,
                    )),
            const SizedBox(height: 16),
          ],

          // ── Obtain methods ──
          if (info.obtainMethods.isNotEmpty) ...[
            _sectionHeader('How to Obtain', Icons.explore),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: info.obtainMethods
                      .map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white38)),
                                Expanded(
                                  child: Text(
                                    m,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── No creation info ──
          if (info.creationMethods.isEmpty && info.obtainMethods.isEmpty)
            Card(
              color: const Color(0xFFFF9800).withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: Color(0xFFFF9800)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No creation recipe found on the wiki page.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This item may be a drop, quest reward, shop item, '
                            'or the wiki uses a format we could not parse. '
                            'Check the wiki link below for full details.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.4),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Wiki link ──
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              final url = Uri.parse(
                  'https://oldschool.runescape.wiki/w/${Uri.encodeComponent(wikiTitle)}');
              launchUrl(url);
            },
            child: Row(
              children: [
                const Icon(Icons.open_in_new,
                    size: 14, color: Color(0xFF64B5F6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'https://oldschool.runescape.wiki/w/$wikiTitle',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64B5F6),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFD4A017)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD4A017),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Creation Method Card ────────────────────────────────────────

class _CreationMethodCard extends StatelessWidget {
  final CreationMethod method;
  final int index;
  final int total;

  const _CreationMethodCard({
    required this.method,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  if (total > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A017)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Method ${index + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD4A017),
                        ),
                      ),
                    ),
                  if (method.facility != null) ...[
                    if (total > 1) const SizedBox(width: 8),
                    Icon(Icons.location_on,
                        size: 13, color: Colors.white.withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
                    Text(
                      method.facility!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  if (method.ticks != null) ...[
                    const Spacer(),
                    Icon(Icons.timer,
                        size: 12, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(width: 4),
                    Text(
                      '${method.ticks} ticks (${(method.ticks! * 0.6).toStringAsFixed(1)}s)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ],
              ),

              // Skills required
              if (method.skills.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'SKILLS REQUIRED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: method.skills
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF43A047)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF43A047)
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${s.level}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF43A047),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  s.skill,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF81C784),
                                  ),
                                ),
                                if (s.xp != null) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${s.xp} xp)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],

              // Materials
              if (method.materials.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'MATERIALS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white38,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                ...method.materials.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4A017)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${m.quantity}x',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFD4A017),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            m.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              // Output quantity
              if (method.outputQuantity > 1) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.output,
                        size: 14, color: Color(0xFF64B5F6)),
                    const SizedBox(width: 6),
                    Text(
                      'Makes ${method.outputQuantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64B5F6),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
