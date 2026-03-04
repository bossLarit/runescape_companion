import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persists daily checklist state across navigation within the same app session.
/// Resets naturally when the app is restarted (new day).
final dailyChecklistProvider =
    StateNotifierProvider<DailyChecklistNotifier, Map<String, bool>>((ref) {
  return DailyChecklistNotifier();
});

class DailyChecklistNotifier extends StateNotifier<Map<String, bool>> {
  DailyChecklistNotifier()
      : super({
          'Herb run': false,
          'Birdhouse run': false,
          'Battlestaves': false,
          'Kingdom': false,
          'Farm contract': false,
          'Seaweed run': false,
        });

  void toggle(String key) {
    state = {...state, key: !(state[key] ?? false)};
  }
}
