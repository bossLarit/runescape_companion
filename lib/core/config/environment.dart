import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Environment definition ──────────────────────────────────────

enum Environment { dev, qa, prod }

class EnvConfig {
  final Environment env;
  final String appName;
  final String storageFolderSuffix; // keeps data isolated per env
  final bool showDebugBanner;
  final bool enableDevTools;
  final String updateChannel; // 'latest' or 'pre-release'
  final String githubOwner;
  final String githubRepo;

  const EnvConfig({
    required this.env,
    required this.appName,
    this.storageFolderSuffix = '',
    this.showDebugBanner = false,
    this.enableDevTools = false,
    this.updateChannel = 'latest',
    this.githubOwner = 'bossLarit',
    this.githubRepo = 'runescape_companion',
  });

  String get label => env.name.toUpperCase();
  bool get isDev => env == Environment.dev;
  bool get isQa => env == Environment.qa;
  bool get isProd => env == Environment.prod;

  /// Storage subfolder name, e.g. "osrs_companion_dev"
  String get storageFolder => 'osrs_companion$storageFolderSuffix';
}

// ─── Predefined configs ──────────────────────────────────────────

class EnvConfigs {
  EnvConfigs._();

  static const dev = EnvConfig(
    env: Environment.dev,
    appName: 'OSRS Companion [DEV]',
    storageFolderSuffix: '_dev',
    showDebugBanner: true,
    enableDevTools: true,
    updateChannel: 'pre-release',
  );

  static const qa = EnvConfig(
    env: Environment.qa,
    appName: 'OSRS Companion [QA]',
    storageFolderSuffix: '_qa',
    showDebugBanner: true,
    enableDevTools: true,
    updateChannel: 'pre-release',
  );

  static const prod = EnvConfig(
    env: Environment.prod,
    appName: 'OSRS Companion',
    storageFolderSuffix: '',
    showDebugBanner: false,
    enableDevTools: false,
    updateChannel: 'latest',
  );
}

// ─── Global provider ─────────────────────────────────────────────

/// Set once at startup from the entry point. Defaults to prod.
final envConfigProvider = StateProvider<EnvConfig>((ref) => EnvConfigs.prod);
