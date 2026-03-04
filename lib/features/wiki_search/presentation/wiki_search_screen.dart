import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/osrs_api_service.dart';

class WikiSearchScreen extends HookConsumerWidget {
  const WikiSearchScreen({super.key});

  static const _slayerCreatures = [
    _WikiEntry('Abyssal Demon', 'slayer', 'Abyssal_demon'),
    _WikiEntry('Kraken', 'slayer', 'Kraken'),
    _WikiEntry('Cerberus', 'slayer', 'Cerberus'),
    _WikiEntry('Smoke Devil', 'slayer', 'Thermonuclear_smoke_devil'),
    _WikiEntry('Gargoyle', 'slayer', 'Gargoyle'),
    _WikiEntry('Nechryael', 'slayer', 'Nechryael'),
    _WikiEntry('Dark Beast', 'slayer', 'Dark_beast'),
    _WikiEntry('Basilisk Knight', 'slayer', 'Basilisk_Knight'),
    _WikiEntry('Hydra', 'slayer', 'Alchemical_Hydra'),
    _WikiEntry('Kurask', 'slayer', 'Kurask'),
    _WikiEntry('Bloodveld', 'slayer', 'Bloodveld'),
    _WikiEntry('Dust Devil', 'slayer', 'Dust_devil'),
    _WikiEntry('Wyrm', 'slayer', 'Wyrm'),
    _WikiEntry('Drake', 'slayer', 'Drake'),
    _WikiEntry('Greater Demon', 'slayer', 'Greater_demon'),
    _WikiEntry('Black Demon', 'slayer', 'Black_demon'),
    _WikiEntry('Hellhound', 'slayer', 'Hellhound'),
    _WikiEntry('Cave Kraken', 'slayer', 'Cave_kraken'),
    _WikiEntry('Skeletal Wyvern', 'slayer', 'Skeletal_Wyvern'),
    _WikiEntry('Grotesque Guardians', 'slayer', 'Grotesque_Guardians'),
  ];

  static const _bosses = [
    _WikiEntry('Zulrah', 'boss', 'Zulrah'),
    _WikiEntry('Vorkath', 'boss', 'Vorkath'),
    _WikiEntry('Theatre of Blood', 'boss', 'Theatre_of_Blood'),
    _WikiEntry('Chambers of Xeric', 'boss', 'Chambers_of_Xeric'),
    _WikiEntry('Corporeal Beast', 'boss', 'Corporeal_Beast'),
    _WikiEntry('General Graardor', 'boss', 'General_Graardor'),
    _WikiEntry("Kree'arra", 'boss', 'Kree%27arra'),
    _WikiEntry('Commander Zilyana', 'boss', 'Commander_Zilyana'),
    _WikiEntry("K'ril Tsutsaroth", 'boss', 'K%27ril_Tsutsaroth'),
    _WikiEntry('Giant Mole', 'boss', 'Giant_Mole'),
    _WikiEntry('Kalphite Queen', 'boss', 'Kalphite_Queen'),
    _WikiEntry('King Black Dragon', 'boss', 'King_Black_Dragon'),
    _WikiEntry('Dagannoth Kings', 'boss', 'Dagannoth_Kings'),
    _WikiEntry('Nightmare', 'boss', 'The_Nightmare'),
    _WikiEntry('Nex', 'boss', 'Nex'),
    _WikiEntry('Phantom Muspah', 'boss', 'Phantom_Muspah'),
    _WikiEntry('Duke Sucellus', 'boss', 'Duke_Sucellus'),
    _WikiEntry('The Leviathan', 'boss', 'The_Leviathan'),
    _WikiEntry('Vardorvis', 'boss', 'Vardorvis'),
    _WikiEntry('The Whisperer', 'boss', 'The_Whisperer'),
    _WikiEntry('Tombs of Amascut', 'boss', 'Tombs_of_Amascut'),
    _WikiEntry('Inferno', 'boss', 'Inferno'),
    _WikiEntry('Fight Caves', 'boss', 'TzHaar_Fight_Cave'),
    _WikiEntry('Gauntlet', 'boss', 'The_Gauntlet'),
    _WikiEntry('Corrupted Gauntlet', 'boss', 'Corrupted_Gauntlet'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useState('');
    final mode = useState('all');
    final recentSearches = useState<List<String>>([]);
    final wikiResults = useState<List<WikiSearchResult>>([]);
    final wikiLoading = useState(false);

    final List<_WikiEntry> allEntries = [];
    if (mode.value == 'slayer' || mode.value == 'all') {
      allEntries.addAll(_slayerCreatures);
    }
    if (mode.value == 'boss' || mode.value == 'all') {
      allEntries.addAll(_bosses);
    }

    final filtered = searchQuery.value.isEmpty
        ? allEntries
        : allEntries
            .where((e) =>
                e.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
            .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wiki Quick Search',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 350,
                  child: TextField(
                    decoration: const InputDecoration(
                        hintText: 'Search slayer creatures & bosses...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true),
                    onChanged: (v) => searchQuery.value = v,
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'all', label: Text('All')),
                            ButtonSegment(
                                value: 'slayer', label: Text('Slayer')),
                            ButtonSegment(value: 'boss', label: Text('Bosses')),
                            ButtonSegment(
                                value: 'wiki', label: Text('Wiki Search')),
                          ],
                          selected: {mode.value},
                          onSelectionChanged: (v) => mode.value = v.first,
                        ),
                        if (mode.value == 'wiki') ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: searchQuery.value.isEmpty
                                ? null
                                : () async {
                                    wikiLoading.value = true;
                                    final api =
                                        ref.read(osrsApiServiceProvider);
                                    wikiResults.value = await api.searchWiki(
                                        searchQuery.value,
                                        limit: 20);
                                    wikiLoading.value = false;
                                  },
                            icon: const Icon(Icons.search, size: 16),
                            label: const Text('Search Wiki'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (recentSearches.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: recentSearches.value
                    .map((s) => ActionChip(
                          label: Text(s, style: const TextStyle(fontSize: 11)),
                          onPressed: () => searchQuery.value = s,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: mode.value == 'wiki'
                  ? _buildWikiSearchResults(context, wikiResults.value,
                      wikiLoading.value, searchQuery.value, recentSearches)
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('No results found',
                                  style: TextStyle(color: Colors.white54)),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _openWikiSearch(searchQuery.value),
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text('Search on OSRS Wiki'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final entry = filtered[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: ListTile(
                                dense: true,
                                leading: Icon(
                                  entry.category == 'boss'
                                      ? Icons.whatshot
                                      : Icons.dangerous,
                                  color: entry.category == 'boss'
                                      ? Colors.red
                                      : Colors.purple,
                                  size: 20,
                                ),
                                title: Text(entry.name),
                                subtitle: Text(entry.category,
                                    style: const TextStyle(fontSize: 11)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.open_in_new, size: 18),
                                  tooltip: 'Open on Wiki',
                                  onPressed: () {
                                    if (!recentSearches.value
                                        .contains(entry.name)) {
                                      recentSearches.value = [
                                        entry.name,
                                        ...recentSearches.value.take(9)
                                      ];
                                    }
                                    _openWikiPage(entry.slug);
                                  },
                                ),
                                onTap: () {
                                  if (!recentSearches.value
                                      .contains(entry.name)) {
                                    recentSearches.value = [
                                      entry.name,
                                      ...recentSearches.value.take(9)
                                    ];
                                  }
                                  _openWikiPage(entry.slug);
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWikiSearchResults(
      BuildContext context,
      List<WikiSearchResult> results,
      bool loading,
      String query,
      ValueNotifier<List<String>> recentSearches) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter a search term and click "Search Wiki"',
                style: TextStyle(color: Colors.white54)),
            SizedBox(height: 8),
            Text('Powered by the OSRS Wiki MediaWiki API',
                style: TextStyle(color: Colors.white24, fontSize: 11)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final r = results[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.article, size: 20, color: Colors.blue),
            title: Text(r.title),
            subtitle: Text(r.snippet,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.white54)),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new, size: 18),
              tooltip: 'Open on Wiki',
              onPressed: () {
                if (!recentSearches.value.contains(r.title)) {
                  recentSearches.value = [
                    r.title,
                    ...recentSearches.value.take(9)
                  ];
                }
                _openWikiPage(Uri.encodeComponent(r.title));
              },
            ),
            onTap: () {
              if (!recentSearches.value.contains(r.title)) {
                recentSearches.value = [
                  r.title,
                  ...recentSearches.value.take(9)
                ];
              }
              _openWikiPage(Uri.encodeComponent(r.title));
            },
          ),
        );
      },
    );
  }

  void _openWikiPage(String slug) {
    launchUrl(Uri.parse('https://oldschool.runescape.wiki/w/$slug'));
  }

  void _openWikiSearch(String query) {
    final encoded = Uri.encodeComponent(query);
    launchUrl(Uri.parse(
        'https://oldschool.runescape.wiki/w/Special:Search?search=$encoded'));
  }
}

class _WikiEntry {
  final String name;
  final String category;
  final String slug;
  const _WikiEntry(this.name, this.category, this.slug);
}
