import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/vault_repository.dart';
import '../../data/txt_import_parser.dart';
import '../../domain/vault_entry_model.dart';

final vaultProvider = StateNotifierProvider<VaultNotifier, VaultState>((ref) {
  return VaultNotifier(ref.watch(vaultRepositoryProvider));
});

class VaultNotifier extends StateNotifier<VaultState> {
  final VaultRepository _repo;
  String? _masterPassword;

  VaultNotifier(this._repo) : super(const VaultState()) {
    _checkVaultExists();
  }

  Future<void> _checkVaultExists() async {
    final exists = await _repo.vaultExists();
    state = VaultState(status: exists ? VaultStatus.locked : VaultStatus.noVault);
  }

  Future<void> createVault(String masterPassword) async {
    try {
      _masterPassword = masterPassword;
      await _repo.save([], masterPassword);
      state = const VaultState(status: VaultStatus.unlocked, entries: []);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create vault: $e');
    }
  }

  Future<void> unlock(String masterPassword) async {
    try {
      final entries = await _repo.unlock(masterPassword);
      _masterPassword = masterPassword;
      state = VaultState(status: VaultStatus.unlocked, entries: entries);
    } catch (e) {
      state = state.copyWith(error: 'Wrong password or corrupted vault');
    }
  }

  void lock() {
    _masterPassword = null;
    state = const VaultState(status: VaultStatus.locked);
  }

  Future<void> addEntry(VaultEntry entry) async {
    if (_masterPassword == null) return;
    final updated = [...state.entries, entry];
    await _repo.save(updated, _masterPassword!);
    state = state.copyWith(entries: updated, error: null);
  }

  Future<void> updateEntry(VaultEntry entry) async {
    if (_masterPassword == null) return;
    final updated = state.entries.map((e) => e.id == entry.id ? entry : e).toList();
    await _repo.save(updated, _masterPassword!);
    state = state.copyWith(entries: updated, error: null);
  }

  Future<void> deleteEntry(String id) async {
    if (_masterPassword == null) return;
    final updated = state.entries.where((e) => e.id != id).toList();
    await _repo.save(updated, _masterPassword!);
    state = state.copyWith(entries: updated, error: null);
  }

  Future<List<VaultEntry>> parseImportFile(String filePath) async {
    final content = await File(filePath).readAsString();
    final parser = TxtImportParser();
    return parser.parse(content);
  }

  Future<List<String>> validateImportFile(String filePath) async {
    final content = await File(filePath).readAsString();
    final parser = TxtImportParser();
    return parser.validate(content);
  }

  Future<void> importEntries(List<VaultEntry> entries) async {
    if (_masterPassword == null) return;
    final updated = [...state.entries, ...entries];
    await _repo.save(updated, _masterPassword!);
    state = state.copyWith(entries: updated, error: null);
  }

  Future<void> copyPassword(String password) async {
    await Clipboard.setData(ClipboardData(text: password));
    // Auto-clear after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
