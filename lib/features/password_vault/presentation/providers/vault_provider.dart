import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/vault_repository.dart';
import '../../data/txt_import_parser.dart';
import '../../domain/vault_entry_model.dart';

final vaultProvider = StateNotifierProvider<VaultNotifier, VaultState>((ref) {
  return VaultNotifier(ref.watch(vaultRepositoryProvider));
});

class VaultNotifier extends StateNotifier<VaultState> {
  final VaultRepository _repo;
  String? _masterPassword;

  // Auto-lock timer
  Timer? _autoLockTimer;

  // Brute force protection
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  static const int _maxAttemptsBeforeLockout = 5;

  // Clipboard clear tracking
  int _clipboardGeneration = 0;

  VaultNotifier(this._repo) : super(const VaultState()) {
    _checkVaultExists();
  }

  @override
  void dispose() {
    _autoLockTimer?.cancel();
    super.dispose();
  }

  /// Reset the auto-lock timer on any vault interaction.
  void _resetAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = Timer(AppConstants.vaultLockTimeout, () {
      if (mounted && state.status == VaultStatus.unlocked) {
        lock();
      }
    });
  }

  Future<void> _checkVaultExists() async {
    final exists = await _repo.vaultExists();
    state =
        VaultState(status: exists ? VaultStatus.locked : VaultStatus.noVault);
  }

  Future<void> createVault(String masterPassword) async {
    try {
      _masterPassword = masterPassword;
      await _repo.save([], masterPassword);
      _failedAttempts = 0;
      _resetAutoLockTimer();
      state = const VaultState(status: VaultStatus.unlocked, entries: []);
    } catch (e) {
      _masterPassword = null;
      state = state.copyWith(error: 'Failed to create vault: $e');
    }
  }

  Future<void> unlock(String masterPassword) async {
    // Brute force protection: enforce lockout
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      state = state.copyWith(
          error: 'Too many failed attempts. Try again in ${remaining}s.');
      return;
    }

    try {
      final entries = await _repo.unlock(masterPassword);
      _masterPassword = masterPassword;
      _failedAttempts = 0;
      _lockoutUntil = null;
      _resetAutoLockTimer();
      state = VaultState(status: VaultStatus.unlocked, entries: entries);
    } catch (e) {
      _failedAttempts++;
      if (_failedAttempts >= _maxAttemptsBeforeLockout) {
        // Exponential backoff: 30s, 60s, 120s, ...
        final lockoutSeconds =
            30 * (1 << (_failedAttempts - _maxAttemptsBeforeLockout));
        _lockoutUntil = DateTime.now().add(Duration(seconds: lockoutSeconds));
        state = state.copyWith(
            error: 'Too many failed attempts. Locked for ${lockoutSeconds}s.');
      } else {
        final remaining = _maxAttemptsBeforeLockout - _failedAttempts;
        state = state.copyWith(
            error: 'Wrong password. $remaining attempts remaining.');
      }
    }
  }

  void lock() {
    _masterPassword = null;
    _autoLockTimer?.cancel();
    state = const VaultState(status: VaultStatus.locked);
  }

  Future<void> addEntry(VaultEntry entry) async {
    if (_masterPassword == null) return;
    _resetAutoLockTimer();
    final updated = [...state.entries, entry];
    await _repo.save(updated, _masterPassword!);
    state = state.copyWith(entries: updated, error: null);
  }

  Future<void> updateEntry(VaultEntry entry) async {
    if (_masterPassword == null) return;
    _resetAutoLockTimer();
    final updated =
        state.entries.map((e) => e.id == entry.id ? entry : e).toList();
    await _repo.save(updated, _masterPassword!);
    state = state.copyWith(entries: updated, error: null);
  }

  Future<void> deleteEntry(String id) async {
    if (_masterPassword == null) return;
    _resetAutoLockTimer();
    final updated = state.entries.where((e) => e.id != id).toList();
    await _repo.save(updated, _masterPassword!);
    state = state.copyWith(entries: updated, error: null);
  }

  static const int _maxImportFileSize = 5 * 1024 * 1024; // 5 MB

  Future<String> _readImportFile(String filePath) async {
    final file = File(filePath);
    final size = await file.length();
    if (size > _maxImportFileSize) {
      throw Exception(
          'Import file too large (${(size / 1024 / 1024).toStringAsFixed(1)} MB). Max 5 MB.');
    }
    return file.readAsString();
  }

  Future<List<VaultEntry>> parseImportFile(String filePath) async {
    final content = await _readImportFile(filePath);
    final parser = TxtImportParser();
    return parser.parse(content);
  }

  Future<List<String>> validateImportFile(String filePath) async {
    final content = await _readImportFile(filePath);
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
    _resetAutoLockTimer();
    await Clipboard.setData(ClipboardData(text: password));
    // Track generation so we only clear *our* clipboard content
    final gen = ++_clipboardGeneration;
    Future.delayed(AppConstants.clipboardClearDuration, () {
      // Only clear if no newer copy happened and notifier is still alive
      if (mounted && _clipboardGeneration == gen) {
        Clipboard.setData(const ClipboardData(text: ''));
      }
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
