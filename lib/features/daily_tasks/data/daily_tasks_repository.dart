import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';

const _dailyTasksFile = 'daily_tasks_state.json';

final dailyTasksRepositoryProvider = Provider<DailyTasksRepository>((ref) {
  return DailyTasksRepository(ref.watch(localStorageServiceProvider));
});

class DailyTasksRepository {
  final LocalStorageService _storage;
  DailyTasksRepository(this._storage);

  Future<Map<String, dynamic>?> loadState() async {
    return await _storage.loadJson(_dailyTasksFile) as Map<String, dynamic>?;
  }

  Future<void> saveState(Map<String, dynamic> state) async {
    await _storage.saveJson(_dailyTasksFile, state);
  }
}
