import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../domain/vault_entry_model.dart';
import 'providers/vault_provider.dart';
import '../../../core/widgets/confirm_dialog.dart';

class VaultScreen extends HookConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vault = ref.watch(vaultProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: switch (vault.status) {
          VaultStatus.noVault => _CreateVaultView(),
          VaultStatus.locked => _UnlockVaultView(),
          VaultStatus.unlocked => _VaultContentView(entries: vault.entries),
        },
      ),
    );
  }
}

class _CreateVaultView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passCtrl = useTextEditingController();
    final confirmCtrl = useTextEditingController();
    final error = useState<String?>(null);
    final obscure = useState(true);

    return Center(
      child: SizedBox(
        width: 400,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48, color: Colors.amber),
                const SizedBox(height: 16),
                Text('Create Vault',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text('Set a master password to encrypt your vault.',
                    style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 24),
                TextField(
                  controller: passCtrl,
                  obscureText: obscure.value,
                  decoration: InputDecoration(
                    labelText: 'Master Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscure.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => obscure.value = !obscure.value,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscure.value,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                ),
                if (error.value != null) ...[
                  const SizedBox(height: 8),
                  Text(error.value!,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (passCtrl.text.isEmpty) {
                        error.value = 'Password cannot be empty';
                        return;
                      }
                      if (passCtrl.text.length < 8) {
                        error.value = 'Password must be at least 8 characters';
                        return;
                      }
                      if (passCtrl.text != confirmCtrl.text) {
                        error.value = 'Passwords do not match';
                        return;
                      }
                      error.value = null;
                      ref
                          .read(vaultProvider.notifier)
                          .createVault(passCtrl.text);
                    },
                    child: const Text('Create Vault'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnlockVaultView extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passCtrl = useTextEditingController();
    final vault = ref.watch(vaultProvider);
    final obscure = useState(true);

    return Center(
      child: SizedBox(
        width: 400,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 48, color: Colors.amber),
                const SizedBox(height: 16),
                Text('Unlock Vault',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                TextField(
                  controller: passCtrl,
                  obscureText: obscure.value,
                  decoration: InputDecoration(
                    labelText: 'Master Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscure.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => obscure.value = !obscure.value,
                    ),
                  ),
                  onSubmitted: (_) =>
                      ref.read(vaultProvider.notifier).unlock(passCtrl.text),
                ),
                if (vault.error != null) ...[
                  const SizedBox(height: 8),
                  Text(vault.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(vaultProvider.notifier).unlock(passCtrl.text),
                    child: const Text('Unlock'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VaultContentView extends HookConsumerWidget {
  final List<VaultEntry> entries;
  const _VaultContentView({required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useState('');
    final selectedEntry = useState<VaultEntry?>(null);

    final filtered = entries.where((e) {
      if (searchQuery.value.isEmpty) return true;
      final q = searchQuery.value.toLowerCase();
      return e.title.toLowerCase().contains(q) ||
          e.username.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text('Password Vault',
                  style: Theme.of(context).textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.lock_open, color: Colors.green, size: 20),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _importFromTxt(context, ref),
              icon: const Icon(Icons.file_upload),
              label: const Text('Import .txt'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showEntryForm(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Entry'),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.lock, color: Colors.amber),
              tooltip: 'Lock Vault',
              onPressed: () => ref.read(vaultProvider.notifier).lock(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 300,
          child: TextField(
            decoration: const InputDecoration(
                hintText: 'Search entries...',
                prefixIcon: Icon(Icons.search),
                isDense: true),
            onChanged: (v) => searchQuery.value = v,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No vault entries',
                      style: TextStyle(color: Colors.white54)))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 380,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final entry = filtered[index];
                          final isSelected =
                              selectedEntry.value?.id == entry.id;
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
                              leading: const Icon(Icons.key, size: 20),
                              title: Text(entry.title,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(
                                '${entry.category.isNotEmpty ? entry.category : "No category"} | ${entry.username}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              onTap: () => selectedEntry.value = entry,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: selectedEntry.value != null
                          ? _VaultEntryDetail(
                              entry: selectedEntry.value!,
                              onEdit: () => _showEntryForm(
                                  context, ref, selectedEntry.value),
                              onDelete: () async {
                                final confirmed = await showConfirmDialog(
                                    context,
                                    title: 'Delete Entry',
                                    message:
                                        'Delete "${selectedEntry.value!.title}"?');
                                if (confirmed) {
                                  await ref
                                      .read(vaultProvider.notifier)
                                      .deleteEntry(selectedEntry.value!.id);
                                  selectedEntry.value = null;
                                }
                              },
                            )
                          : const Center(
                              child: Text('Select an entry',
                                  style: TextStyle(color: Colors.white38))),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _showEntryForm(BuildContext context, WidgetRef ref,
      [VaultEntry? existing]) {
    showDialog(
      context: context,
      builder: (ctx) => _VaultEntryFormDialog(
        entry: existing,
        onSave: (entry) {
          if (existing != null) {
            ref.read(vaultProvider.notifier).updateEntry(entry);
          } else {
            ref.read(vaultProvider.notifier).addEntry(entry);
          }
        },
      ),
    );
  }

  Future<void> _importFromTxt(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;

    try {
      final errors =
          await ref.read(vaultProvider.notifier).validateImportFile(path);
      final entries =
          await ref.read(vaultProvider.notifier).parseImportFile(path);

      if (!context.mounted) return;
      unawaited(showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Import Preview'),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Found ${entries.length} entries'),
                if (errors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Warnings:',
                      style: TextStyle(color: Colors.orange[300])),
                  ...errors.take(5).map((e) => Text('  - $e',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.orange))),
                ],
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (_, i) => ListTile(
                      dense: true,
                      title: Text(entries[i].title),
                      subtitle: Text(
                          '${entries[i].category} | ${entries[i].username}'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(vaultProvider.notifier).importEntries(entries);
                Navigator.of(ctx).pop();
              },
              child: Text('Import ${entries.length} entries'),
            ),
          ],
        ),
      ));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Import error: $e')));
    }
  }
}

class _VaultEntryDetail extends HookConsumerWidget {
  final VaultEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _VaultEntryDetail(
      {required this.entry, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showPassword = useState(false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(entry.title,
                          style: Theme.of(context).textTheme.headlineSmall)),
                  IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: onDelete,
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.red)),
                ],
              ),
              if (entry.category.isNotEmpty)
                Text('Category: ${entry.category}',
                    style: const TextStyle(color: Colors.white54)),
              const Divider(height: 24),
              _field('Username', entry.username),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field('Password',
                        showPassword.value ? entry.password : '\u2022' * 12),
                  ),
                  IconButton(
                    icon: Icon(showPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => showPassword.value = !showPassword.value,
                    tooltip: showPassword.value ? 'Hide' : 'Show',
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy (auto-clears in 30s)',
                    onPressed: () {
                      ref
                          .read(vaultProvider.notifier)
                          .copyPassword(entry.password);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Password copied! Clipboard clears in 30s.'),
                            duration: Duration(seconds: 2)),
                      );
                    },
                  ),
                ],
              ),
              if (entry.email.isNotEmpty) ...[
                const SizedBox(height: 12),
                _field('Email', entry.email)
              ],
              if (entry.url.isNotEmpty) ...[
                const SizedBox(height: 12),
                _field('URL', entry.url)
              ],
              if (entry.character.isNotEmpty) ...[
                const SizedBox(height: 12),
                _field('Character', entry.character)
              ],
              if (entry.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                _field('Notes', entry.notes)
              ],
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                    spacing: 4,
                    children: entry.tags
                        .map((t) => Chip(
                            label:
                                Text(t, style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap))
                        .toList()),
              ],
              if (entry.customFields.isNotEmpty) ...[
                const Divider(height: 24),
                Text('Custom Fields',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ...entry.customFields.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _field(e.key, e.value),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 2),
        SelectableText(value.isEmpty ? '-' : value),
      ],
    );
  }
}

class _VaultEntryFormDialog extends HookWidget {
  final VaultEntry? entry;
  final void Function(VaultEntry) onSave;
  const _VaultEntryFormDialog({this.entry, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final isEditing = entry != null;
    final titleCtrl = useTextEditingController(text: entry?.title ?? '');
    final categoryCtrl = useTextEditingController(text: entry?.category ?? '');
    final usernameCtrl = useTextEditingController(text: entry?.username ?? '');
    final passwordCtrl = useTextEditingController(text: entry?.password ?? '');
    final emailCtrl = useTextEditingController(text: entry?.email ?? '');
    final urlCtrl = useTextEditingController(text: entry?.url ?? '');
    final characterCtrl =
        useTextEditingController(text: entry?.character ?? '');
    final notesCtrl = useTextEditingController(text: entry?.notes ?? '');
    final tagsCtrl =
        useTextEditingController(text: entry?.tags.join(', ') ?? '');
    final obscure = useState(true);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Entry' : 'New Entry'),
      content: SizedBox(
        width: 450,
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
                  controller: categoryCtrl,
                  decoration: const InputDecoration(labelText: 'Category')),
              const SizedBox(height: 8),
              TextField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 8),
              TextField(
                controller: passwordCtrl,
                obscureText: obscure.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(obscure.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => obscure.value = !obscure.value,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(labelText: 'URL')),
              const SizedBox(height: 8),
              TextField(
                  controller: characterCtrl,
                  decoration: const InputDecoration(labelText: 'Character')),
              const SizedBox(height: 8),
              TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2),
              const SizedBox(height: 8),
              TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Tags (comma separated)')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
            final result = (entry ?? VaultEntry(title: title)).copyWith(
              title: title,
              category: categoryCtrl.text.trim(),
              username: usernameCtrl.text.trim(),
              password: passwordCtrl.text,
              email: emailCtrl.text.trim(),
              url: urlCtrl.text.trim(),
              character: characterCtrl.text.trim(),
              notes: notesCtrl.text.trim(),
              tags: tags,
            );
            onSave(result);
            Navigator.of(context).pop();
          },
          child: Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
