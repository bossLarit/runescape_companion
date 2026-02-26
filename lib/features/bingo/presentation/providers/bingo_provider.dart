import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/bingo_repository.dart';
import '../../domain/bingo_model.dart';
import '../../../characters/presentation/providers/characters_provider.dart';

final bingoProvider =
    StateNotifierProvider<BingoNotifier, AsyncValue<List<BingoCard>>>((ref) {
  return BingoNotifier(ref.watch(bingoRepositoryProvider));
});

final activeCharBingoProvider = Provider<List<BingoCard>>((ref) {
  final activeChar = ref.watch(activeCharacterProvider);
  final cards = ref.watch(bingoProvider);
  if (activeChar == null) return [];
  return cards.whenOrNull(
        data: (list) =>
            list.where((c) => c.characterId == activeChar.id).toList(),
      ) ??
      [];
});

class BingoNotifier extends StateNotifier<AsyncValue<List<BingoCard>>> {
  final BingoRepository _repo;

  BingoNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final cards = await _repo.loadAll();
      state = AsyncValue.data(cards);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(BingoCard card) async {
    await _repo.add(card);
    await load();
  }

  Future<void> update(BingoCard card) async {
    await _repo.update(card);
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> toggleCell(String cardId, int cellIndex) async {
    final cards = state.valueOrNull ?? [];
    final card = cards.firstWhere((c) => c.id == cardId);
    final cells = List<BingoCell>.from(card.cells);
    final cell = cells[cellIndex];
    // Don't toggle FREE cell
    if (cell.text == 'FREE') return;
    cells[cellIndex] = cell.copyWith(completed: !cell.completed);
    await update(card.copyWith(cells: cells));
  }
}
