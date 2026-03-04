import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/session_model.dart';
import 'providers/sessions_provider.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/screen_header.dart';

class SessionsScreen extends HookConsumerWidget {
  const SessionsScreen({super.key});

  static const _gold = Color(0xFFD4A017);
  static const _cream = Color(0xFFF5E6C8);
  static const _parchment = Color(0xFFD2C3A3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider);
    final sessions = ref.watch(activeCharacterSessionsProvider);
    final activeSession = ref.watch(activeSessionProvider);

    final sorted = [...sessions]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final history = sorted.where((s) => !s.isActive).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            ScreenHeader(
              title: 'Sessions',
              characterName: activeChar?.displayName,
              actions: [
                if (activeSession != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB33831),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () =>
                        _showStopDialog(context, ref, activeSession),
                    icon: const Icon(Icons.stop, size: 18),
                    label: const Text('Stop Session'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: activeChar == null
                        ? null
                        : () => _startSession(context, ref, activeChar.id),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Start Session'),
                  ),
              ],
            ),

            // ── Active session banner ──
            if (activeSession != null) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xFF1B3A1B).withValues(alpha: 0.7),
                    const Color(0xFF2D5F27).withValues(alpha: 0.4),
                  ]),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF43A047).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF43A047)
                                  .withValues(alpha: 0.5),
                              blurRadius: 6)
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Active',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _cream)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(activeSession.type.name,
                          style: TextStyle(
                              color: _parchment.withValues(alpha: 0.7),
                              fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.schedule,
                        size: 13, color: _parchment.withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
                    Text(
                        'Started ${DateFormat.Hm().format(activeSession.startTime)}',
                        style: TextStyle(
                            color: _parchment.withValues(alpha: 0.5),
                            fontSize: 12)),
                    if (activeSession.notes.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(activeSession.notes,
                            style: TextStyle(
                                color: _parchment.withValues(alpha: 0.4),
                                fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // ── History ──
            Row(
              children: [
                Icon(Icons.history,
                    size: 16, color: _gold.withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Text('History',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _cream.withValues(alpha: 0.8))),
                const SizedBox(width: 8),
                Text('${history.length} sessions',
                    style: TextStyle(
                        fontSize: 12,
                        color: _parchment.withValues(alpha: 0.4))),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_circle_outline,
                                size: 32, color: Colors.white12),
                          ),
                          const SizedBox(height: 14),
                          Text(
                              activeChar == null
                                  ? 'Create a character to start sessions'
                                  : 'No session history yet',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _parchment.withValues(alpha: 0.4))),
                          const SizedBox(height: 4),
                          Text('Start a session to track your progress',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _parchment.withValues(alpha: 0.25))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final session = history[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _gold.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(_sessionIcon(session.type),
                                      size: 18,
                                      color: _gold.withValues(alpha: 0.6)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(session.type.name,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: _cream)),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF42A5F5)
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                                session.durationFormatted,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF42A5F5))),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        [
                                          DateFormat.yMd()
                                              .add_Hm()
                                              .format(session.startTime),
                                          if (session.xpGained > 0)
                                            'XP: ${session.xpGained.toStringAsFixed(0)}',
                                          if (session.lootValue > 0)
                                            'GP: ${session.lootValue.toStringAsFixed(0)}',
                                          if (session.killCount > 0)
                                            'KC: ${session.killCount}',
                                        ].join(' · '),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: _parchment.withValues(
                                                alpha: 0.4)),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      size: 18,
                                      color: _parchment.withValues(alpha: 0.3)),
                                  onPressed: () async {
                                    final confirmed = await showConfirmDialog(
                                        context,
                                        title: 'Delete Session',
                                        message: 'Delete this session?');
                                    if (confirmed) {
                                      await ref
                                          .read(sessionsProvider.notifier)
                                          .delete(session.id);
                                    }
                                  },
                                ),
                              ],
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
