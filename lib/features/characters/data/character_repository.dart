import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/character_model.dart';

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository(ref.watch(localStorageServiceProvider));
});

class CharacterRepository {
  final LocalStorageService _storage;

  CharacterRepository(this._storage);

  Future<List<Character>> loadAll() async {
    final data = await _storage.loadJson(AppConstants.charactersFile);
    if (data == null) return [];
    final list = data as List<dynamic>;
    return list.map((e) => Character.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAll(List<Character> characters) async {
    final data = characters.map((c) => c.toJson()).toList();
    await _storage.saveJson(AppConstants.charactersFile, data);
  }

  Future<void> add(Character character) async {
    final all = await loadAll();
    all.add(character);
    await saveAll(all);
  }

  Future<void> update(Character character) async {
    final all = await loadAll();
    final index = all.indexWhere((c) => c.id == character.id);
    if (index >= 0) {
      all[index] = character;
      await saveAll(all);
    }
  }

  Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((c) => c.id == id);
    await saveAll(all);
  }
}
