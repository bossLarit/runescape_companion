import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../config/environment.dart';
import '../constants/app_constants.dart';

// ─── Data classes ────────────────────────────────────────────────

class ReleaseInfo {
  final String version; // e.g. "1.2.0"
  final String tagName; // e.g. "v1.2.0"
  final String body; // release notes (markdown)
  final String? downloadUrl; // .zip asset URL
  final String? assetName;
  final DateTime publishedAt;

  const ReleaseInfo({
    required this.version,
    required this.tagName,
    required this.body,
    this.downloadUrl,
    this.assetName,
    required this.publishedAt,
  });

  bool get hasDownload => downloadUrl != null;
}

enum UpdateStatus {
  idle,
  checking,
  upToDate,
  updateAvailable,
  downloading,
  readyToInstall,
  error,
}

class UpdateState {
  final UpdateStatus status;
  final ReleaseInfo? release;
  final double downloadProgress; // 0.0 – 1.0
  final String? errorMessage;
  final String? downloadedPath;

  const UpdateState({
    this.status = UpdateStatus.idle,
    this.release,
    this.downloadProgress = 0,
    this.errorMessage,
    this.downloadedPath,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    ReleaseInfo? release,
    double? downloadProgress,
    String? errorMessage,
    String? downloadedPath,
  }) =>
      UpdateState(
        status: status ?? this.status,
        release: release ?? this.release,
        downloadProgress: downloadProgress ?? this.downloadProgress,
        errorMessage: errorMessage ?? this.errorMessage,
        downloadedPath: downloadedPath ?? this.downloadedPath,
      );
}

// ─── Provider ────────────────────────────────────────────────────

final updateProvider =
    StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  final env = ref.watch(envConfigProvider);
  return UpdateNotifier(env);
});

class UpdateNotifier extends StateNotifier<UpdateState> {
  final EnvConfig _env;

  UpdateNotifier(this._env) : super(const UpdateState());

  String get _apiBase =>
      'https://api.github.com/repos/${_env.githubOwner}/${_env.githubRepo}';

  /// Check GitHub for a newer release.
  Future<void> checkForUpdate() async {
    state = state.copyWith(
      status: UpdateStatus.checking,
      errorMessage: null,
    );

    try {
      // dev/qa check pre-releases, prod checks latest
      final endpoint = _env.updateChannel == 'pre-release'
          ? '$_apiBase/releases'
          : '$_apiBase/releases/latest';
      final uri = Uri.parse(endpoint);
      final resp = await http.get(uri, headers: {
        'Accept': 'application/vnd.github.v3+json',
      });

      if (resp.statusCode == 404) {
        // No releases yet
        state = state.copyWith(status: UpdateStatus.upToDate);
        return;
      }
      if (resp.statusCode != 200) {
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: 'GitHub API error ${resp.statusCode}',
        );
        return;
      }

      // /releases returns an array, /releases/latest returns an object
      final decoded = jsonDecode(resp.body);
      final Map<String, dynamic> json;
      if (decoded is List) {
        if (decoded.isEmpty) {
          state = state.copyWith(status: UpdateStatus.upToDate);
          return;
        }
        json = decoded.first as Map<String, dynamic>;
      } else {
        json = decoded as Map<String, dynamic>;
      }
      final tagName = json['tag_name'] as String? ?? '';
      final remoteVersion = tagName.replaceFirst(RegExp(r'^v'), '');
      final body = json['body'] as String? ?? '';
      final publishedAt =
          DateTime.tryParse(json['published_at'] as String? ?? '') ??
              DateTime.now();

      // Find a Windows .zip asset
      String? downloadUrl;
      String? assetName;
      final assets = json['assets'] as List<dynamic>? ?? [];
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.contains('windows') && name.endsWith('.zip')) {
          downloadUrl = asset['browser_download_url'] as String?;
          assetName = asset['name'] as String?;
          break;
        }
      }
      // Fallback: any .zip
      if (downloadUrl == null) {
        for (final asset in assets) {
          final name = (asset['name'] as String? ?? '').toLowerCase();
          if (name.endsWith('.zip')) {
            downloadUrl = asset['browser_download_url'] as String?;
            assetName = asset['name'] as String?;
            break;
          }
        }
      }

      final release = ReleaseInfo(
        version: remoteVersion,
        tagName: tagName,
        body: body,
        downloadUrl: downloadUrl,
        assetName: assetName,
        publishedAt: publishedAt,
      );

      if (_isNewer(remoteVersion, AppConstants.version)) {
        state = state.copyWith(
          status: UpdateStatus.updateAvailable,
          release: release,
        );
      } else {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          release: release,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Download the release asset to a temp folder.
  Future<void> downloadUpdate() async {
    final url = state.release?.downloadUrl;
    if (url == null) return;

    state = state.copyWith(
      status: UpdateStatus.downloading,
      downloadProgress: 0,
    );

    try {
      final request = http.Request('GET', Uri.parse(url));
      final streamed = await http.Client().send(request);
      final contentLength = streamed.contentLength ?? 0;

      final tempDir = await getTemporaryDirectory();
      final zipPath =
          '${tempDir.path}/${state.release?.assetName ?? 'update.zip'}';
      final file = File(zipPath);
      final sink = file.openWrite();

      int received = 0;
      await for (final chunk in streamed.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0) {
          state = state.copyWith(
            downloadProgress: received / contentLength,
          );
        }
      }
      await sink.close();

      state = state.copyWith(
        status: UpdateStatus.readyToInstall,
        downloadedPath: zipPath,
        downloadProgress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Download failed: $e',
      );
    }
  }

  /// Launch the updater script and exit the app.
  Future<void> installUpdate() async {
    final zipPath = state.downloadedPath;
    if (zipPath == null) return;

    // Resolve paths
    final exePath = Platform.resolvedExecutable;
    final appDir = File(exePath).parent.path;

    // Write a small .bat updater script next to the zip
    final tempDir = File(zipPath).parent.path;
    final batPath = '$tempDir\\update_osrs_companion.bat';

    final batContent = '''
@echo off
echo Updating OSRS Companion...
echo Waiting for app to close...
timeout /t 2 /nobreak >nul

echo Extracting update...
powershell -Command "Expand-Archive -Path '$zipPath' -DestinationPath '$tempDir\\update_extract' -Force"

echo Copying files...
xcopy /s /y /q "$tempDir\\update_extract\\*" "$appDir\\"

echo Cleaning up...
rmdir /s /q "$tempDir\\update_extract"
del "$zipPath"

echo Starting OSRS Companion...
start "" "$exePath"

del "%~f0"
''';

    await File(batPath).writeAsString(batContent);

    // Launch the updater and exit
    await Process.start(
      'cmd.exe',
      ['/c', batPath],
      mode: ProcessStartMode.detached,
    );

    exit(0);
  }

  /// Compare semantic versions. Returns true if [remote] > [local].
  static bool _isNewer(String remote, String local) {
    final rParts = remote.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final lParts = local.split('.').map((s) => int.tryParse(s) ?? 0).toList();

    // Pad to same length
    while (rParts.length < 3) {
      rParts.add(0);
    }
    while (lParts.length < 3) {
      lParts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (rParts[i] > lParts[i]) return true;
      if (rParts[i] < lParts[i]) return false;
    }
    return false;
  }
}
