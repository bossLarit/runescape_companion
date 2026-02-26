import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/cookbook_models.dart';
import 'ironman_guide_data.dart';

final cookbookRepositoryProvider = Provider<CookbookRepository>((ref) {
  return CookbookRepository(ref.watch(localStorageServiceProvider));
});

class CookbookRepository {
  final LocalStorageService _storage;

  CookbookRepository(this._storage);

  Future<List<CookbookTemplate>> loadTemplates() async {
    final data = await _storage.loadJson(AppConstants.cookbookFile);
    if (data == null) return _sampleTemplates();
    final list = (data as List<dynamic>)
        .map((e) => CookbookTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
    return list.isEmpty ? _sampleTemplates() : list;
  }

  Future<void> saveTemplates(List<CookbookTemplate> templates) async {
    await _storage.saveJson(
        AppConstants.cookbookFile, templates.map((t) => t.toJson()).toList());
  }

  Future<List<CookbookProgress>> loadProgress() async {
    final data = await _storage.loadJson(AppConstants.cookbookProgressFile);
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((e) => CookbookProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProgress(List<CookbookProgress> progress) async {
    await _storage.saveJson(AppConstants.cookbookProgressFile,
        progress.map((p) => p.toJson()).toList());
  }

  List<CookbookTemplate> _sampleTemplates() => getBuiltInTemplates();
}
