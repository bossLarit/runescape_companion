import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/bingo_model.dart';

final bingoRepositoryProvider = Provider<BingoRepository>((ref) {
  return BingoRepository(ref.watch(localStorageServiceProvider));
});

class BingoRepository {
  final LocalStorageService _storage;

  BingoRepository(this._storage);

  Future<List<BingoCard>> loadAll() async {
    final data = await _storage.loadJson(AppConstants.bingoCardsFile);
    if (data == null) return [];
    final list = data as List<dynamic>;
    return list
        .map((e) => BingoCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<BingoCard> cards) async {
    await _storage.saveJson(
      AppConstants.bingoCardsFile,
      cards.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> add(BingoCard card) async {
    final all = await loadAll();
    all.add(card);
    await saveAll(all);
  }

  Future<void> update(BingoCard card) async {
    final all = await loadAll();
    final index = all.indexWhere((c) => c.id == card.id);
    if (index >= 0) {
      all[index] = card;
      await saveAll(all);
    }
  }

  Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((c) => c.id == id);
    await saveAll(all);
  }
}
