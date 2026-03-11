# OSRS Companion — AI Coding Agent Instructions

## Overview

OSRS Companion is a **Flutter desktop application** (Windows) for tracking RuneScape progress. It's a feature-rich companion with 25+ screens, multi-account management, goal tracking with AI-powered planning, and real-time market data integration.

**Key facts:**
- Flutter + Dart (SDK ≥3.0.0)
- State management: Riverpod (hooks_riverpod, flutter_hooks)
- Routing: GoRouter with shell-based navigation
- Three environments: DEV, QA, PROD (separate data folders)
- No server — all data is local JSON storage

---

## Architecture & Patterns

### Feature-First Structure

Each feature is fully self-contained under `lib/features/{feature_name}/`:
```
feature_name/
  domain/           # Data models & enums (no dependencies)
  data/             # Repositories, local storage logic
  presentation/     # Screens & providers (presentation-specific state)
```

**Example:** `lib/features/goals/` contains `GoalModel`, `GoalRepository`, `GoalsNotifier`, and `GoalsScreen`.

### State Management: Riverpod Patterns

**Two state types are used:**

1. **StateNotifier** for mutable state that persists:
   ```dart
   final goalsProvider = StateNotifierProvider<GoalsNotifier, AsyncValue<List<Goal>>>((ref) {
     return GoalsNotifier(ref.watch(goalRepositoryProvider));
   });
   
   class GoalsNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
     GoalsNotifier(this._repo) : super(const AsyncValue.loading()) {
       load();
     }
     Future<void> load() async { ... }
     Future<void> add(Goal goal) async { ... }
   }
   ```
   - Use `AsyncValue.data()`, `.loading()`, `.error()` for async operations
   - Always call `load()` after mutations to refresh UI
   - Catch exceptions and set state to `AsyncValue.error(e, st)`

2. **StateNotifier** for simple state (non-async):
   ```dart
   final bankProvider = StateNotifierProvider<BankNotifier, BankState>((ref) { ... });
   
   class BankNotifier extends StateNotifier<BankState> {
     // Use state.copyWith() for immutable updates
     state = state.copyWith(items: updated);
   }
   ```

3. **Provider** for derived/computed state (read-only):
   ```dart
   final activeCharacterGoalsProvider = Provider<List<Goal>>((ref) {
     final goals = ref.watch(goalsProvider);
     final activeChar = ref.watch(activeCharacterProvider);
     return goals.whenOrNull(data: (list) => 
       list.where((g) => g.characterId == activeChar.id).toList()) ?? [];
   });
   ```

**Key pattern:** Use `ref.listen()` not `ref.watch()` when you want to observe state changes **without rebuilding**. See `lib/app/router.dart` for onboarding redirect logic.

### Data Storage

All data is saved locally via `LocalStorageService`:
```dart
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final env = ref.watch(envConfigProvider);
  return LocalStorageService(storageFolder: env.storageFolder);
});

// Usage:
await _storage.saveJson(AppConstants.goalsFile, goals.map((g) => g.toJson()).toList());
final data = await _storage.loadJson(AppConstants.goalsFile);
```

**Storage locations** (Windows):
- PROD: `%APPDATA%/osrs_companion/`
- QA: `%APPDATA%/osrs_companion_qa/`
- DEV: `%APPDATA%/osrs_companion_dev/`

### Navigation & Routing

GoRouter with `ShellRoute` for persistent navigation bar:
- **Onboarding redirect:** Custom `_OnboardingRedirectNotifier` uses `ref.listen()` to update router state without recreating it
- **Routes defined in:** `lib/app/router.dart`
- **All screens wrap in `HookConsumerWidget`** for Riverpod + Flutter Hooks integration

---

## Development Workflows

### Running the App

```powershell
# Default (PROD environment)
flutter run -d windows

# Dev environment (shows debug banner, enables DevTools)
flutter run -d windows -t lib/main_dev.dart

# QA environment
flutter run -d windows -t lib/main_qa.dart
```

### Building Releases

```powershell
# Production build
flutter build windows --release -t lib/main.dart

# Output: build/windows/x64/runner/Release/runescape_companion.exe
```

### Testing

```powershell
flutter test
```

Tests live in `test/` — currently minimal coverage. Add tests alongside new features.

### Environment Configuration

Edit `lib/core/config/environment.dart` to add new build variants:
```dart
static const dev = EnvConfig(
  env: Environment.dev,
  appName: 'OSRS Companion [DEV]',
  storageFolderSuffix: '_dev',
  showDebugBanner: true,
  enableDevTools: true,
  updateChannel: 'pre-release',
);
```

---

## Integration Points & External Dependencies

### OSRS API Service

Fetches live data from OSRS Hiscores, GE prices, and item mappings:
```dart
final osrsApiServiceProvider = Provider<OsrsApiService>((ref) {
  return OsrsApiService();
});

// Usage:
await ref.watch(osrsApiServiceProvider).fetchHiscores(playerName, mode: 'normal');
await ref.watch(osrsApiServiceProvider).fetchLatestPrices();
```

**API docs embedded in code:** `lib/core/services/osrs_api_service.dart` contains all endpoints and data structures (HiscoreResult, GeItemPrice, etc.).

### Update Service

Auto-checks GitHub Releases on startup:
```dart
final updateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  final env = ref.watch(envConfigProvider);
  return UpdateNotifier(env);
});
```

Configured via environment (owner/repo/channel in EnvConfig).

---

## Design System & UI Conventions

**Single import for all design tokens:**
```dart
import 'package:runescape_companion/core/design_system/design_system.dart';
```

Exports: colors, spacing (4-unit grid), radius, shadows, and reusable widgets.

**Theme:** Dark theme only (`AppTheme.darkTheme` in `lib/app/theme.dart`).

**Layout conventions:**
- Screens use `Scaffold` with `Padding(const EdgeInsets.all(24))`
- Reusable components: `ScreenHeader`, `ConfirmDialog`, `BankImportDialog` in `lib/core/widgets/` and `lib/shared/widgets/`

---

## Code Standards & Conventions

From `analysis_options.yaml`:
- ✓ Const constructors by default
- ✓ Final locals and declarations
- ✓ Single quotes for strings
- ✓ Always declare return types
- ✓ Avoid `print()` — use debugPrint or logging
- ✓ No `async void` — only `Future<void>`
- ✗ Unused imports are warnings; missing returns are errors

**Naming:**
- Model classes: `GoalModel`, `CharacterModel`, etc.
- Providers: `goalsProvider`, `charactersProvider`
- Notifiers: `GoalsNotifier`, `CharactersNotifier`
- Enums: `GoalStatus`, `GoalType`, `Environment`

---

## Common Patterns

### Adding a New Feature

1. Create `lib/features/my_feature/` with domain/, data/, presentation/
2. Define models in `domain/my_model.dart` (immutable with copyWith)
3. Create repository in `data/my_repository.dart` with Provider
4. Create notifier & provider in `presentation/providers/my_provider.dart`
5. Create screen in `presentation/my_screen.dart` as HookConsumerWidget
6. Add route to `lib/app/router.dart`
7. Add menu item to `lib/core/widgets/app_shell.dart`

### Handling Async Operations

Pattern used across all features:
```dart
Future<void> someAction(data) async {
  try {
    await _repo.save(data);
    await load(); // Refresh state
  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}
```

### Filtering Data by Active Character

Nearly every feature filters by `activeCharacterProvider`:
```dart
final activeCharacterGoalsProvider = Provider<List<Goal>>((ref) {
  final activeChar = ref.watch(activeCharacterProvider);
  final goals = ref.watch(goalsProvider);
  if (activeChar == null) return [];
  return goals.whenOrNull(
    data: (list) => list.where((g) => g.characterId == activeChar.id).toList(),
  ) ?? [];
});
```

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry point (PROD) |
| `lib/main_dev.dart`, `lib/main_qa.dart` | Environment variants |
| `lib/app/app.dart` | Root widget (MaterialApp.router) |
| `lib/app/router.dart` | Navigation setup & onboarding redirect |
| `lib/core/config/environment.dart` | Environment configuration |
| `lib/core/services/` | OsrsApiService, LocalStorageService, UpdateService |
| `lib/core/design_system/design_system.dart` | Design tokens & widgets |
| `lib/core/constants/app_constants.dart` | Storage file names, skill orders, activity names |
| `lib/core/widgets/app_shell.dart` | Navigation bar & layout |
| `lib/features/*/{domain,data,presentation}/` | Feature modules |

---

## Debugging Tips

- **State not updating?** Check that you're calling `.load()` after mutations
- **Provider not rebuilding?** Use `ref.watch()`, not `ref.listen()`
- **Onboarding stuck?** Router uses `ref.listen()` explicitly — rebuild happens via `refreshListenable`
- **Data not persisting?** Verify `LocalStorageService` is being used and file names match `AppConstants`
- **API calls failing?** Check `OsrsApiService` for endpoint details; use correct player names and modes

---

## Questions or Ambiguities?

When uncertain:
1. Check similar features (e.g., goals, sessions, notes follow identical patterns)
2. Review `lib/features/*/presentation/providers/*_provider.dart` for state management examples
3. Inspect `lib/core/services/` for integration patterns
4. Run with DEV environment to see debug output

