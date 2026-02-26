import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/character_model.dart';

class CharacterFormDialog extends HookConsumerWidget {
  final Character? character;
  final void Function(Character) onSave;

  const CharacterFormDialog({super.key, this.character, required this.onSave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = character != null;
    final nameController =
        useTextEditingController(text: character?.displayName ?? '');
    final notesController =
        useTextEditingController(text: character?.notes ?? '');
    final grindController =
        useTextEditingController(text: character?.currentGrind ?? '');
    final loginPurposeController =
        useTextEditingController(text: character?.nextLoginPurpose ?? '');
    final tagsController =
        useTextEditingController(text: character?.tags.join(', ') ?? '');
    final selectedType =
        useState(character?.characterType ?? CharacterType.main);
    final secJagex =
        useState(character?.securityChecklist.jagexAccountMigrated ?? false);
    final sec2fa =
        useState(character?.securityChecklist.twoFactorEnabled ?? false);
    final secEmail =
        useState(character?.securityChecklist.email2faEnabled ?? false);
    final secPin =
        useState(character?.securityChecklist.bankPinEnabled ?? false);
    final secBackup =
        useState(character?.securityChecklist.backupCodesStored ?? false);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Character' : 'New Character'),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CharacterType>(
                key: ValueKey(selectedType.value),
                value: selectedType.value,
                decoration: const InputDecoration(labelText: 'Type'),
                items: CharacterType.values
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t.displayName)))
                    .toList(),
                onChanged: (v) => selectedType.value = v ?? CharacterType.main,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: grindController,
                decoration: const InputDecoration(labelText: 'Current Grind'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: loginPurposeController,
                decoration:
                    const InputDecoration(labelText: 'Next Login Purpose'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagsController,
                decoration:
                    const InputDecoration(labelText: 'Tags (comma separated)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.shield, size: 18, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text('Security Checklist',
                        style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Jagex Account Migrated',
                    style: TextStyle(fontSize: 13)),
                value: secJagex.value,
                onChanged: (v) => secJagex.value = v,
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Two-Factor Auth (2FA)',
                    style: TextStyle(fontSize: 13)),
                value: sec2fa.value,
                onChanged: (v) => sec2fa.value = v,
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Email 2FA Enabled',
                    style: TextStyle(fontSize: 13)),
                value: secEmail.value,
                onChanged: (v) => secEmail.value = v,
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title:
                    const Text('Bank PIN Set', style: TextStyle(fontSize: 13)),
                value: secPin.value,
                onChanged: (v) => secPin.value = v,
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Unique Password',
                    style: TextStyle(fontSize: 13)),
                value: secBackup.value,
                onChanged: (v) => secBackup.value = v,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            final tags = tagsController.text
                .split(',')
                .map((t) => t.trim())
                .where((t) => t.isNotEmpty)
                .toList();
            final security = SecurityChecklist(
              jagexAccountMigrated: secJagex.value,
              twoFactorEnabled: sec2fa.value,
              email2faEnabled: secEmail.value,
              bankPinEnabled: secPin.value,
              backupCodesStored: secBackup.value,
            );
            final result = (character ?? Character(displayName: name)).copyWith(
              displayName: name,
              characterType: selectedType.value,
              notes: notesController.text.trim(),
              currentGrind: grindController.text.trim(),
              nextLoginPurpose: loginPurposeController.text.trim(),
              tags: tags,
              securityChecklist: security,
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
