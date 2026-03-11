import 'package:package_info_plus/package_info_plus.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'OSRS Companion';
  static String version = '1.0.0'; // overwritten at startup

  /// Call once in main() before runApp()
  static Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
  }

  // Storage file names
  static const String charactersFile = 'characters.json';
  static const String goalsFile = 'goals.json';
  static const String sessionsFile = 'sessions.json';
  static const String notesFile = 'notes.json';
  static const String vaultFile = 'vault.enc';
  static const String goalNodesFile = 'goal_nodes.json';
  static const String dependenciesFile = 'dependencies.json';
  static const String timeBudgetFile = 'time_budget.json';
  static const String cookbookFile = 'cookbooks.json';
  static const String cookbookProgressFile = 'cookbook_progress.json';
  static const String settingsFile = 'settings.json';
  static const String wikiSearchHistoryFile = 'wiki_search_history.json';
  static const String bankItemsFile = 'bank_items.json';
  static const String bingoCardsFile = 'bingo_cards.json';
  static const String gearLoadoutsFile = 'gear_loadouts.json';

  // Clipboard auto-clear duration
  static const Duration clipboardClearDuration = Duration(seconds: 30);

  // Vault auto-lock timeout
  static const Duration vaultLockTimeout = Duration(minutes: 5);
}
