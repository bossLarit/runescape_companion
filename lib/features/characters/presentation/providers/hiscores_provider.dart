import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/osrs_api_service.dart';

final hiscoresProvider =
    StateNotifierProvider<HiscoresNotifier, AsyncValue<HiscoreResult?>>((ref) {
  return HiscoresNotifier(ref.watch(osrsApiServiceProvider));
});

class HiscoresNotifier extends StateNotifier<AsyncValue<HiscoreResult?>> {
  final OsrsApiService _api;

  HiscoresNotifier(this._api) : super(const AsyncValue.data(null));

  Future<void> lookup(String playerName, {String mode = 'normal'}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _api.fetchHiscores(playerName, mode: mode);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
