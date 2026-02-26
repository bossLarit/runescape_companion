import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

class LocalStorageService {
  String? _basePath;

  Future<String> get basePath async {
    if (_basePath != null) return _basePath!;
    final dir = await getApplicationDocumentsDirectory();
    _basePath = '${dir.path}/osrs_companion';
    final folder = Directory(_basePath!);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return _basePath!;
  }

  Future<String> _filePath(String filename) async {
    final base = await basePath;
    return '$base/$filename';
  }

  Future<void> saveJson(String filename, dynamic data) async {
    final path = await _filePath(filename);
    final file = File(path);
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await file.writeAsString(jsonString);
  }

  Future<dynamic> loadJson(String filename) async {
    final path = await _filePath(filename);
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return null;
      return jsonDecode(content);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveRawBytes(String filename, List<int> bytes) async {
    final path = await _filePath(filename);
    final file = File(path);
    await file.writeAsBytes(bytes);
  }

  Future<List<int>?> loadRawBytes(String filename) async {
    final path = await _filePath(filename);
    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  Future<bool> fileExists(String filename) async {
    final path = await _filePath(filename);
    return File(path).exists();
  }

  Future<void> deleteFile(String filename) async {
    final path = await _filePath(filename);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
