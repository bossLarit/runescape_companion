import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';

const _onboardingFile = 'onboarding_state.json';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.watch(localStorageServiceProvider));
});

class OnboardingRepository {
  final LocalStorageService _storage;
  OnboardingRepository(this._storage);

  Future<bool> isOnboardingComplete() async {
    final data = await _storage.loadJson(_onboardingFile);
    if (data is Map<String, dynamic>) {
      return data['completed'] == true;
    }
    return false;
  }

  Future<void> completeOnboarding() async {
    await _storage.saveJson(_onboardingFile, {
      'completed': true,
      'completedAt': DateTime.now().toIso8601String(),
    });
  }
}
