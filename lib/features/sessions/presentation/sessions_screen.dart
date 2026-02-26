import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/session_model.dart';
import 'providers/sessions_provider.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import '../../../core/widgets/confirm_dialog.dart';

class SessionsScreen extends HookConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider);
    final sessions = ref.watch(activeCharacterSessionsProvider);
    final activeSession = ref.watch(activeSessionProvider);

    final sorted = [...sessions]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Sessions',
                    style: Theme.of(context).textTheme.headlineMedium),
                if (activeChar != null) ...[
                  const SizedBox(width: 12),
                  Chip(label: Text(activeChar.displayName)),
                ],
                const Spacer(),
                if (activeSession != null)
                  ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () =>
                        _showStopDialog(context, ref, activeSession),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Session'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: activeChar == null
                        ? null
                        : () => _startSession(context, ref, activeChar.id),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Session'),
                  ),
              ],
            ),
            if (activeSession != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 12),
                      const SizedBox(width: 8),
                      Text('Active: ${activeSession.type.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Text(
                          'Started ${DateFormat.Hm().format(activeSession.startTime)}'),
                      if (activeSession.notes.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Text(activeSession.notes,
                            style: const TextStyle(color: Colors.white54)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text('History', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: sorted.where((s) => !s.isActive).isEmpty
                  ? Center(
                      child: Text(
                          activeChar == null
                              ? 'Create a character in the Characters tab to start sessions'
                              : 'No session history yet',
                          style: const TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: sorted.where((s) => !s.isActive).length,
                      itemBuilder: (context, index) {
                        final session =
                            sorted.where((s) => !s.isActive).toList()[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(_sessionIcon(session.type)),
                            title: Text(
                                '${session.type.name} - ${session.durationFormatted}'),
                            subtitle: Text(
                              '${DateFormat.yMd().add_Hm().format(session.startTime)}'
                              '${session.xpGained > 0 ? ' | XP: ${session.xpGained.toStringAsFixed(0)}' : ''}'
                              '${session.lootValue > 0 ? ' | GP: ${session.lootValue.toStringAsFixed(0)}' : ''}'
                              '${session.killCount > 0 ? ' | KC: ${session.killCount}' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () async {
                                final confirmed = await showConfirmDialog(
                                    context,
                                    title: 'Delete Session',
                                    message: 'Delete this session?');
                                if (confirmed) {
                                  ref
                                      .read(sessionsProvider.notifier)
                                      .delete(session.id);
                                }
                              },
                            ),
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

  IconData _sessionIcon(SessionType type) {
    switch (type) {
      case SessionType.bossing:
        return Icons.whatshot;
      case SessionType.skilling:
        return Icons.construction;
      case SessionType.slayer:
        return Icons.dangerous;
      case SessionType.questing:
        return Icons.explore;
      case SessionType.custom:
        return Icons.star;
    }
  }

  void _startSession(BuildContext context, WidgetRef ref, String characterId) {
    final typeState = ValueNotifier(SessionType.custom);
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Session'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<SessionType>(
                valueListenable: typeState,
                builder: (_, val, __) => DropdownButtonFormField<SessionType>(
                  key: ValueKey(val),
                  value: val,
                  decoration: const InputDecoration(labelText: 'Session Type'),
                  items: SessionType.values
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t.name)))
                      .toList(),
                  onChanged: (v) => typeState.value = v ?? SessionType.custom,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notes')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(sessionsProvider.notifier).startSession(
                    GameSession(
                      characterId: characterId,
                      type: typeState.value,
                      notes: notesCtrl.text.trim(),
                    ),
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showStopDialog(
      BuildContext context, WidgetRef ref, GameSession session) {
    final xpCtrl = TextEditingController();
    final gpCtrl = TextEditingController();
    final kcCtrl = TextEditingController();
    final notesCtrl = TextEditingController(text: session.notes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop Session'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: xpCtrl,
                  decoration: const InputDecoration(labelText: 'XP Gained'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(
                  controller: gpCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Loot Value (GP)'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(
                  controller: kcCtrl,
                  decoration: const InputDecoration(labelText: 'Kill Count'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(sessionsProvider.notifier).stopSession(
                    session.id,
                    xpGained: double.tryParse(xpCtrl.text) ?? 0,
                    lootValue: double.tryParse(gpCtrl.text) ?? 0,
                    killCount: int.tryParse(kcCtrl.text) ?? 0,
                    notes: notesCtrl.text.trim(),
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }
}
