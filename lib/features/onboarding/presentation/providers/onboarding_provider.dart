import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/onboarding_repository.dart';

/// Tracks whether onboarding has been completed.
/// `null` = still loading, `true` = done, `false` = needs onboarding.
final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingNotifier, AsyncValue<bool>>((ref) {
  return OnboardingNotifier(ref.watch(onboardingRepositoryProvider));
});

class OnboardingNotifier extends StateNotifier<AsyncValue<bool>> {
  final OnboardingRepository _repo;

  OnboardingNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final done = await _repo.isOnboardingComplete();
      state = AsyncValue.data(done);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> complete() async {
    await _repo.completeOnboarding();
    state = const AsyncValue.data(true);
  }
}
