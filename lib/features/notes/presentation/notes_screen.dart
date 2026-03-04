import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/note_model.dart';
import 'providers/notes_provider.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import '../../../core/widgets/confirm_dialog.dart';

class NotesScreen extends HookConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final activeChar = ref.watch(activeCharacterProvider);
    final searchQuery = useState('');
    final showGlobalOnly = useState(false);
    final selectedNote = useState<Note?>(null);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text('Notes',
                      style: Theme.of(context).textTheme.headlineMedium,
                      overflow: TextOverflow.ellipsis),
                ),
                if (activeChar != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              const Color(0xFFD4A017).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person,
                            size: 13,
                            color:
                                const Color(0xFFD4A017).withValues(alpha: 0.7)),
                        const SizedBox(width: 5),
                        Text(activeChar.displayName,
                            style: const TextStyle(
                                color: Color(0xFFD4A017),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                FilterChip(
                  label: const Text('Global Only'),
                  selected: showGlobalOnly.value,
                  onSelected: (v) => showGlobalOnly.value = v,
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showNoteEditor(context, ref, activeChar?.id),
                  icon: const Icon(Icons.add),
                  label: const Text('New Note'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              child: TextField(
                decoration: const InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true),
                onChanged: (v) => searchQuery.value = v,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: notesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (allNotes) {
                  var notes = allNotes.where((n) {
                    if (showGlobalOnly.value) return n.isGlobal;
                    if (activeChar != null) {
                      return n.isGlobal || n.characterId == activeChar.id;
                    }
                    return true;
                  }).where((n) {
                    if (searchQuery.value.isEmpty) return true;
                    final q = searchQuery.value.toLowerCase();
                    return n.title.toLowerCase().contains(q) ||
                        n.content.toLowerCase().contains(q) ||
                        n.tags.any((t) => t.toLowerCase().contains(q));
                  }).toList();
                  notes.sort((a, b) {
                    if (a.isPinned && !b.isPinned) return -1;
                    if (!a.isPinned && b.isPinned) return 1;
                    return b.updatedAt.compareTo(a.updatedAt);
                  });

                  if (notes.isEmpty) {
                    return const Center(
                        child: Text('No notes yet',
                            style: TextStyle(color: Colors.white54)));
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 350,
                        child: ListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            final isSelected =
                                selectedNote.value?.id == note.id;
                            return Card(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.2)
                                  : null,
                              margin: const EdgeInsets.only(bottom: 4),
                              child: ListTile(
                                dense: true,
                                leading: note.isPinned
                                    ? const Icon(Icons.push_pin,
                                        size: 16, color: Colors.amber)
                                    : null,
                                title: Text(note.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                  '${note.isGlobal ? "Global" : "Character"} | ${DateFormat.yMd().format(note.updatedAt)}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onTap: () => selectedNote.value = note,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18),
                                  onPressed: () async {
                                    final confirmed = await showConfirmDialog(
                                        context,
                                        title: 'Delete Note',
                                        message: 'Delete "${note.title}"?');
                                    if (confirmed) {
                                      if (selectedNote.value?.id == note.id) {
                                        selectedNote.value = null;
                                      }
                                      ref
                                          .read(notesProvider.notifier)
                                          .delete(note.id);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: selectedNote.value != null
                            ? _NoteDetailPanel(
                                note: selectedNote.value!,
                                onEdit: () => _showNoteEditor(context, ref,
                                    activeChar?.id, selectedNote.value),
                              )
                            : const Center(
                                child: Text('Select a note',
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

  void _showNoteEditor(BuildContext context, WidgetRef ref, String? characterId,
      [Note? existing]) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    final categoryCtrl = TextEditingController(text: existing?.category ?? '');
    final tagsCtrl =
        TextEditingController(text: existing?.tags.join(', ') ?? '');
    final isGlobal = ValueNotifier(existing?.isGlobal ?? (characterId == null));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? 'Edit Note' : 'New Note'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                    autofocus: true),
                const SizedBox(height: 8),
                TextField(
                    controller: contentCtrl,
                    decoration: const InputDecoration(labelText: 'Content'),
                    maxLines: 10,
                    minLines: 5),
                const SizedBox(height: 8),
                TextField(
                    controller: categoryCtrl,
                    decoration: const InputDecoration(labelText: 'Category')),
                const SizedBox(height: 8),
                TextField(
                    controller: tagsCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)')),
                const SizedBox(height: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: isGlobal,
                  builder: (_, val, __) => SwitchListTile(
                    title: const Text('Global Note'),
                    subtitle: const Text('Available across all characters'),
                    value: val,
                    onChanged: (v) => isGlobal.value = v,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              final tags = tagsCtrl.text
                  .split(',')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .toList();
              final charId = isGlobal.value ? null : characterId;
              final note = (existing ?? Note(title: title, characterId: charId))
                  .copyWith(
                title: title,
                content: contentCtrl.text,
                category: categoryCtrl.text.trim(),
                tags: tags,
                characterId: charId,
              );
              if (existing != null) {
                ref.read(notesProvider.notifier).update(note);
              } else {
                ref.read(notesProvider.notifier).add(note);
              }
              Navigator.of(ctx).pop();
            },
            child: Text(existing != null ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}

class _NoteDetailPanel extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  const _NoteDetailPanel({required this.note, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(note.title,
                        style: Theme.of(context).textTheme.headlineSmall)),
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
              ],
            ),
            const SizedBox(height: 4),
            if (note.category.isNotEmpty)
              Text('Category: ${note.category}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: note.tags
                    .map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap))
                    .toList(),
              ),
            ],
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  note.content.isEmpty ? 'No content' : note.content,
                  style: TextStyle(
                      color: note.content.isEmpty
                          ? Colors.white38
                          : Colors.white70,
                      height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
