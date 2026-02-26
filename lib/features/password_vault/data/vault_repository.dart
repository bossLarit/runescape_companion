import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/vault_entry_model.dart';
import 'vault_crypto_service.dart';

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  return VaultRepository(ref.watch(localStorageServiceProvider));
});

class VaultRepository {
  final LocalStorageService _storage;
  final VaultCryptoService _crypto = VaultCryptoService();

  VaultRepository(this._storage);

  Future<bool> vaultExists() async {
    return _storage.fileExists(AppConstants.vaultFile);
  }

  Future<List<VaultEntry>> unlock(String masterPassword) async {
    final bytes = await _storage.loadRawBytes(AppConstants.vaultFile);
    if (bytes == null) return [];

    final plaintext = await _crypto.decrypt(Uint8List.fromList(bytes), masterPassword);
    final data = jsonDecode(plaintext) as List<dynamic>;
    return data.map((e) => VaultEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> save(List<VaultEntry> entries, String masterPassword) async {
    final json = entries.map((e) => e.toJson()).toList();
    final plaintext = jsonEncode(json);
    final encrypted = await _crypto.encrypt(plaintext, masterPassword);
    await _storage.saveRawBytes(AppConstants.vaultFile, encrypted);
  }

  Future<void> deleteVault() async {
    await _storage.deleteFile(AppConstants.vaultFile);
  }
}
