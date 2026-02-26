import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/session_repository.dart';
import '../../domain/session_model.dart';
import '../../../characters/presentation/providers/characters_provider.dart';

final sessionsProvider =
    StateNotifierProvider<SessionsNotifier, AsyncValue<List<GameSession>>>((ref) {
  return SessionsNotifier(ref.watch(sessionRepositoryProvider));
});

final activeCharacterSessionsProvider = Provider<List<GameSession>>((ref) {
  final activeChar = ref.watch(activeCharacterProvider);
  final sessions = ref.watch(sessionsProvider);
  if (activeChar == null) return [];
  return sessions.whenOrNull(
        data: (list) => list.where((s) => s.characterId == activeChar.id).toList(),
      ) ??
      [];
});

final activeSessionProvider = Provider<GameSession?>((ref) {
  final sessions = ref.watch(activeCharacterSessionsProvider);
  try {
    return sessions.firstWhere((s) => s.isActive);
  } catch (_) {
    return null;
  }
});

class SessionsNotifier extends StateNotifier<AsyncValue<List<GameSession>>> {
  final SessionRepository _repo;

  SessionsNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final sessions = await _repo.loadAll();
      state = AsyncValue.data(sessions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startSession(GameSession session) async {
    try {
      await _repo.add(session);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> stopSession(String id, {double xpGained = 0, double lootValue = 0, int killCount = 0, String notes = ''}) async {
    try {
      final all = await _repo.loadAll();
      final index = all.indexWhere((s) => s.id == id);
      if (index >= 0) {
        all[index] = all[index].copyWith(
          endTime: DateTime.now(),
          xpGained: xpGained,
          lootValue: lootValue,
          killCount: killCount,
          notes: notes.isNotEmpty ? notes : all[index].notes,
        );
        await _repo.saveAll(all);
        await load();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(GameSession session) async {
    try {
      await _repo.update(session);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.delete(id);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
