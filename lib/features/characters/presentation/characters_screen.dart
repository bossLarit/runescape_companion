import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/character_model.dart';
import 'providers/characters_provider.dart';
import 'character_form_dialog.dart';
import 'hiscores_dialog.dart';
import '../../../core/widgets/confirm_dialog.dart';

class CharactersScreen extends HookConsumerWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(charactersProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Characters',
                    style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showCreateDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Character'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: charactersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (characters) {
                  if (characters.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text('No characters yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white54)),
                          const SizedBox(height: 8),
                          const Text(
                              'Create your first character to get started',
                              style: TextStyle(color: Colors.white38)),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: characters.length,
                    itemBuilder: (context, index) =>
                        _CharacterCard(character: characters[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CharacterFormDialog(
        onSave: (character) {
          ref.read(charactersProvider.notifier).add(character);
        },
      ),
    );
  }
}

class _CharacterCard extends HookConsumerWidget {
  final Character character;
  const _CharacterCard({required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = character.isActive;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(
                color: Theme.of(context).colorScheme.secondary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () =>
            ref.read(charactersProvider.notifier).setActive(character.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(character.avatarColorValue),
                    child: Text(
                      character.displayName.isNotEmpty
                          ? character.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(character.displayName,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(character.characterType.displayName,
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (isActive)
                    Chip(
                      label:
                          const Text('Active', style: TextStyle(fontSize: 11)),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.2),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'lookup') {
                        showDialog(
                          context: context,
                          builder: (_) => HiscoresDialog(
                            initialName: character.displayName,
                            mode: character.characterType == CharacterType.iron
                                ? 'ironman'
                                : character.characterType == CharacterType.hcim
                                    ? 'hardcore'
                                    : character.characterType ==
                                            CharacterType.uim
                                        ? 'ultimate'
                                        : 'normal',
                          ),
                        );
                      } else if (value == 'edit') {
                        showDialog(
                          context: context,
                          builder: (context) => CharacterFormDialog(
                            character: character,
                            onSave: (updated) {
                              ref
                                  .read(charactersProvider.notifier)
                                  .update(updated);
                            },
                          ),
                        );
                      } else if (value == 'delete') {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: 'Delete Character',
                          message:
                              'Delete "${character.displayName}"? This cannot be undone.',
                        );
                        if (confirmed) {
                          ref
                              .read(charactersProvider.notifier)
                              .delete(character.id);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'lookup', child: Text('Lookup Stats')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (character.currentGrind.isNotEmpty) ...[
                Text('Current Grind:',
                    style: TextStyle(color: Colors.white38, fontSize: 11)),
                Text(character.currentGrind,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
              ],
              if (character.nextLoginPurpose.isNotEmpty) ...[
                Text('Next Login:',
                    style: TextStyle(color: Colors.white38, fontSize: 11)),
                Text(character.nextLoginPurpose,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
              const Spacer(),
              if (character.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: character.tags
                      .take(3)
                      .map((t) => Chip(
                            label:
                                Text(t, style: const TextStyle(fontSize: 10)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
