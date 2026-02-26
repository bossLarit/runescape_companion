import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/session_model.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(localStorageServiceProvider));
});

class SessionRepository {
  final LocalStorageService _storage;

  SessionRepository(this._storage);

  Future<List<GameSession>> loadAll() async {
    final data = await _storage.loadJson(AppConstants.sessionsFile);
    if (data == null) return [];
    final list = data as List<dynamic>;
    return list.map((e) => GameSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAll(List<GameSession> sessions) async {
    await _storage.saveJson(AppConstants.sessionsFile, sessions.map((s) => s.toJson()).toList());
  }

  Future<void> add(GameSession session) async {
    final all = await loadAll();
    all.add(session);
    await saveAll(all);
  }

  Future<void> update(GameSession session) async {
    final all = await loadAll();
    final index = all.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      all[index] = session;
      await saveAll(all);
    }
  }

  Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((s) => s.id == id);
    await saveAll(all);
  }
}
