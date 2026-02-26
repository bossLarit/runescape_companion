import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/character_repository.dart';
import '../../domain/character_model.dart';

final charactersProvider =
    StateNotifierProvider<CharactersNotifier, AsyncValue<List<Character>>>((ref) {
  return CharactersNotifier(ref.watch(characterRepositoryProvider));
});

final activeCharacterProvider = Provider<Character?>((ref) {
  final chars = ref.watch(charactersProvider);
  return chars.whenOrNull(
    data: (list) {
      try {
        return list.firstWhere((c) => c.isActive);
      } catch (_) {
        return list.isNotEmpty ? list.first : null;
      }
    },
  );
});

class CharactersNotifier extends StateNotifier<AsyncValue<List<Character>>> {
  final CharacterRepository _repo;

  CharactersNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final characters = await _repo.loadAll();
      state = AsyncValue.data(characters);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Character character) async {
    try {
      await _repo.add(character);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(Character character) async {
    try {
      await _repo.update(character);
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

  Future<void> setActive(String id) async {
    final current = state.valueOrNull ?? [];
    final updated = current.map((c) {
      return c.copyWith(isActive: c.id == id);
    }).toList();
    try {
      await _repo.saveAll(updated);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
