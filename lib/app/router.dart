import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/widgets/app_shell.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/characters/presentation/characters_screen.dart';
import '../features/goals/presentation/goals_screen.dart';
import '../features/sessions/presentation/sessions_screen.dart';
import '../features/notes/presentation/notes_screen.dart';
import '../features/password_vault/presentation/vault_screen.dart';
import '../features/goal_planner/presentation/goal_planner_screen.dart';
import '../features/time_budget/presentation/time_budget_screen.dart';
import '../features/command_center/presentation/command_center_screen.dart';
import '../features/wiki_search/presentation/wiki_search_screen.dart';
import '../features/cookbook/presentation/cookbook_home_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/ge_prices/presentation/ge_prices_screen.dart';
import '../features/player_tracker/presentation/player_tracker_screen.dart';
import '../features/best_setup/presentation/best_setup_screen.dart';
import '../features/dry_calc/presentation/dry_calc_screen.dart';
import '../features/daily_tasks/presentation/daily_tasks_screen.dart';
import '../features/skill_calc/presentation/skill_calc_screen.dart';
import '../features/bingo/presentation/bingo_screen.dart';
import '../features/boss_progression/presentation/boss_progression_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/providers/onboarding_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Notifier that triggers GoRouter redirect re-evaluation when onboarding
/// state changes, without recreating the entire router.
class _OnboardingRedirectNotifier extends ChangeNotifier {
  bool? _isComplete;
  bool? get isComplete => _isComplete;

  void update(bool? value) {
    if (_isComplete != value) {
      _isComplete = value;
      notifyListeners();
    }
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final redirectNotifier = _OnboardingRedirectNotifier();

  // Listen (not watch) to onboarding state so the router is NOT recreated
  ref.listen<AsyncValue<bool>>(onboardingCompleteProvider, (_, next) {
    redirectNotifier.update(next.whenOrNull(data: (v) => v));
  }, fireImmediately: true);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: redirectNotifier,
    redirect: (context, state) {
      final path = state.uri.path;

      final isComplete = redirectNotifier.isComplete;
      if (isComplete == null) return null; // still loading

      final onOnboarding = path == '/onboarding';

      if (!isComplete && !onOnboarding) return '/onboarding';
      if (isComplete && onOnboarding) return '/dashboard';
      if (path == '/') return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/characters',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CharactersScreen(),
            ),
          ),
          GoRoute(
            path: '/goals',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GoalsScreen(),
            ),
          ),
          GoRoute(
            path: '/sessions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SessionsScreen(),
            ),
          ),
          GoRoute(
            path: '/notes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotesScreen(),
            ),
          ),
          GoRoute(
            path: '/vault',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VaultScreen(),
            ),
          ),
          GoRoute(
            path: '/planner',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GoalPlannerScreen(),
            ),
          ),
          GoRoute(
            path: '/time-budget',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TimeBudgetScreen(),
            ),
          ),
          GoRoute(
            path: '/command-center',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CommandCenterScreen(),
            ),
          ),
          GoRoute(
            path: '/ge-prices',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GePricesScreen(),
            ),
          ),
          GoRoute(
            path: '/wiki',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WikiSearchScreen(),
            ),
          ),
          GoRoute(
            path: '/cookbook',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CookbookHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/player-tracker',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlayerTrackerScreen(),
            ),
          ),
          GoRoute(
            path: '/best-setup',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BestSetupScreen(),
            ),
          ),
          GoRoute(
            path: '/skill-calc',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SkillCalcScreen(),
            ),
          ),
          GoRoute(
            path: '/dry-calc',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DryCalcScreen(),
            ),
          ),
          GoRoute(
            path: '/bingo',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BingoScreen(),
            ),
          ),
          GoRoute(
            path: '/boss-progression',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BossProgressionScreen(),
            ),
          ),
          GoRoute(
            path: '/daily-tasks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DailyTasksScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
