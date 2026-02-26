import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/note_model.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(ref.watch(localStorageServiceProvider));
});

class NotesRepository {
  final LocalStorageService _storage;

  NotesRepository(this._storage);

  Future<List<Note>> loadAll() async {
    final data = await _storage.loadJson(AppConstants.notesFile);
    if (data == null) return [];
    final list = data as List<dynamic>;
    return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAll(List<Note> notes) async {
    await _storage.saveJson(AppConstants.notesFile, notes.map((n) => n.toJson()).toList());
  }

  Future<void> add(Note note) async {
    final all = await loadAll();
    all.add(note);
    await saveAll(all);
  }

  Future<void> update(Note note) async {
    final all = await loadAll();
    final index = all.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      all[index] = note;
      await saveAll(all);
    }
  }

  Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((n) => n.id == id);
    await saveAll(all);
  }
}
