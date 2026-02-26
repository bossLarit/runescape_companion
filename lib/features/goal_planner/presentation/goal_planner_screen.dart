import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../characters/domain/character_model.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import '../../characters/presentation/providers/hiscores_provider.dart';
import '../data/goal_suggestion_engine.dart';
import '../data/micro_goals_engine.dart';
import '../data/osrs_goals_data.dart';
import '../data/training_methods_data.dart';
import 'providers/goal_planner_provider.dart';

class GoalPlannerScreen extends HookConsumerWidget {
  const GoalPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChar = ref.watch(activeCharacterProvider);
    final hiscoreState = ref.watch(hiscoresProvider);
    final plannerState = ref.watch(goalPlannerProvider);
    final selectedCategory = useState<GoalCategory?>(null);
    final readinessFilter = useState<GoalReadiness?>(null);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedGoal = useState<ScoredGoal?>(null);
    final statsLoaded = useState(false);
    final viewTab = useState(0); // 0=Milestones, 1=My Goals, 2=Training Plan
    final intensityPref = useState(Intensity.either); // AFK/Active/Either

    // Determine if active character is an ironman variant
    final isIronman = activeChar != null &&
        {
          CharacterType.iron,
          CharacterType.hcim,
          CharacterType.uim,
          CharacterType.gim
        }.contains(activeChar.characterType);

    // Auto-lookup hiscores for active character
    useEffect(() {
      if (activeChar != null && !statsLoaded.value) {
        ref.read(hiscoresProvider.notifier).lookup(activeChar.displayName,
            mode: _charTypeToMode(activeChar.characterType.name));
        statsLoaded.value = true;
      }
      return null;
    }, [activeChar?.id]);

    // Build player levels from hiscores
    final playerLevels = <String, int>{};
    hiscoreState.whenData((result) {
      if (result != null) {
        for (final entry in result.skills.entries) {
          if (entry.value.level > 0) {
            playerLevels[entry.key] = entry.value.level;
          }
        }
      }
    });

    // Get completed goal IDs from planner state
    final completedIds = plannerState.completedOsrsGoalIds;
    final savedIds = plannerState.savedGoalIds;

    // Get suggestions
    final suggestions = GoalSuggestionEngine.getSuggestions(
      playerLevels: playerLevels,
      completedGoalIds: completedIds,
      category: selectedCategory.value,
      readinessFilter: readinessFilter.value,
      limit: 100,
    );

    // Apply search filter
    final filtered = suggestions.where((s) {
      if (searchQuery.value.isEmpty) return true;
      return s.goal.title
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          s.goal.description
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());
    }).toList();

    // Count by readiness
    final allScored = GoalSuggestionEngine.analyzeGoals(
        playerLevels: playerLevels, completedGoalIds: completedIds);
    final readyCount =
        allScored.where((s) => s.readiness == GoalReadiness.ready).length;
    final almostCount =
        allScored.where((s) => s.readiness == GoalReadiness.almostReady).length;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Goal Planner',
                    style: Theme.of(context).textTheme.headlineMedium),
                if (activeChar != null)
                  Chip(
                    avatar: const Icon(Icons.person, size: 16),
                    label: Text(activeChar.displayName),
                  ),
                if (playerLevels.isNotEmpty) ...[
                  _StatBadge(
                      label: 'Ready',
                      count: readyCount,
                      color: const Color(0xFF43A047)),
                  _StatBadge(
                      label: 'Almost',
                      count: almostCount,
                      color: const Color(0xFFFF9800)),
                  _StatBadge(
                      label: 'Completed',
                      count: completedIds.length,
                      color: const Color(0xFFD4A017)),
                ],
                if (savedIds.isNotEmpty)
                  _StatBadge(
                      label: 'Saved',
                      count: savedIds.length,
                      color: const Color(0xFF42A5F5)),
                if (activeChar != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      statsLoaded.value = false;
                      ref.read(hiscoresProvider.notifier).lookup(
                          activeChar.displayName,
                          mode: _charTypeToMode(activeChar.characterType.name));
                      statsLoaded.value = true;
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh Stats'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Player not set up ──
            if (activeChar == null) ...[
              const Expanded(
                child: Center(
                  child: Text(
                    'Set a character as active in the Characters tab first.\n'
                    'The Goal Planner will analyze your stats and suggest goals.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ),
              ),
            ] else if (hiscoreState is AsyncLoading) ...[
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else ...[
              // ── View Tab Switcher ──
              Row(
                children: [
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                          value: 0,
                          label: Text('Milestones'),
                          icon: Icon(Icons.flag, size: 16)),
                      ButtonSegment(
                          value: 1,
                          label: Text('My Goals'),
                          icon: Icon(Icons.bookmark, size: 16)),
                      ButtonSegment(
                          value: 2,
                          label: Text('Training Plan'),
                          icon: Icon(Icons.trending_up, size: 16)),
                    ],
                    selected: {viewTab.value},
                    onSelectionChanged: (s) {
                      viewTab.value = s.first;
                      searchController.clear();
                      searchQuery.value = '';
                    },
                  ),
                  const SizedBox(width: 16),
                  if (viewTab.value == 0 || viewTab.value == 1) ...[
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search goals...',
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          suffixIcon: searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    searchController.clear();
                                    searchQuery.value = '';
                                  },
                                )
                              : null,
                        ),
                        onChanged: (v) => searchQuery.value = v,
                      ),
                    ),
                    if (viewTab.value == 0) ...[
                      const SizedBox(width: 12),
                      _ReadinessDropdown(
                        value: readinessFilter.value,
                        onChanged: (v) => readinessFilter.value = v,
                      ),
                    ],
                  ] else ...[
                    if (isIronman)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF9E9E9E).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield,
                                size: 12, color: Color(0xFF9E9E9E)),
                            SizedBox(width: 4),
                            Text('Ironman',
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF9E9E9E))),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    SegmentedButton<Intensity>(
                      segments: const [
                        ButtonSegment(
                            value: Intensity.either, label: Text('All')),
                        ButtonSegment(
                            value: Intensity.active,
                            label: Text('Active'),
                            icon: Icon(Icons.directions_run, size: 14)),
                        ButtonSegment(
                            value: Intensity.afk,
                            label: Text('AFK'),
                            icon: Icon(Icons.weekend, size: 14)),
                      ],
                      selected: {intensityPref.value},
                      onSelectionChanged: (s) => intensityPref.value = s.first,
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStatePropertyAll(
                            const TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (playerLevels.isNotEmpty)
                      Text(
                        'Est. ${MicroGoalsEngine.formatHours(MicroGoalsEngine.hoursToMax(playerLevels, isIronman: isIronman))} to max',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    const Spacer(),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // ── Content based on tab ──
              if (viewTab.value == 2)
                Expanded(
                  child: _TrainingPlanView(
                    playerLevels: playerLevels,
                    isIronman: isIronman,
                    intensityPref: intensityPref.value,
                  ),
                )
              else
                Expanded(
                  child: Builder(builder: (context) {
                    // For My Goals tab, filter to only saved goals
                    final isMyGoals = viewTab.value == 1;
                    final displayGoals = isMyGoals
                        ? allScored.where((s) {
                            if (!savedIds.contains(s.goal.id)) return false;
                            if (searchQuery.value.isNotEmpty) {
                              return s.goal.title.toLowerCase().contains(
                                      searchQuery.value.toLowerCase()) ||
                                  s.goal.description.toLowerCase().contains(
                                      searchQuery.value.toLowerCase());
                            }
                            return true;
                          }).toList()
                        : filtered;

                    // Generate saved training goals for My Goals tab
                    final savedTrainingGoals = <MicroGoal>[];
                    if (isMyGoals && playerLevels.isNotEmpty) {
                      final allMicro = MicroGoalsEngine.generateGoals(
                        playerLevels: playerLevels,
                        isIronman: isIronman,
                        maxGoalsPerSkill: 5,
                      );
                      for (final g in allMicro) {
                        final tid = _TrainingPlanView.trainingGoalId(
                            g.skill, g.targetLevel);
                        if (!savedIds.contains(tid)) continue;
                        if (searchQuery.value.isNotEmpty) {
                          final q = searchQuery.value.toLowerCase();
                          if (!g.skill.toLowerCase().contains(q) &&
                              !g.milestone.toLowerCase().contains(q)) {
                            continue;
                          }
                        }
                        savedTrainingGoals.add(g);
                      }
                    }

                    final hasAnySaved = displayGoals.isNotEmpty ||
                        savedTrainingGoals.isNotEmpty;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category sidebar
                        if (!isMyGoals)
                          SizedBox(
                            width: 160,
                            child: Card(
                              child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                children: [
                                  _CategoryTile(
                                    label: 'All Goals',
                                    icon: Icons.list,
                                    isSelected: selectedCategory.value == null,
                                    count: filtered.length,
                                    onTap: () => selectedCategory.value = null,
                                  ),
                                  const Divider(height: 8),
                                  for (final cat in GoalCategory.values)
                                    _CategoryTile(
                                      label: categoryLabel(cat),
                                      icon: IconData(categoryIconCode(cat),
                                          fontFamily: 'MaterialIcons'),
                                      isSelected: selectedCategory.value == cat,
                                      count: allScored.where((s) {
                                        if (s.goal.category != cat) {
                                          return false;
                                        }
                                        if (readinessFilter.value != null &&
                                            s.readiness !=
                                                readinessFilter.value) {
                                          return false;
                                        }
                                        return true;
                                      }).length,
                                      onTap: () => selectedCategory.value = cat,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        if (!isMyGoals) const SizedBox(width: 12),

                        // Goal list
                        Expanded(
                          flex: 3,
                          child: !hasAnySaved && isMyGoals
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.bookmark_border,
                                          size: 48, color: Colors.white24),
                                      SizedBox(height: 12),
                                      Text(
                                        'No saved goals yet.\nBrowse Milestones or Training Plan and tap the bookmark icon to save goals here.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white38),
                                      ),
                                    ],
                                  ),
                                )
                              : !isMyGoals && displayGoals.isEmpty
                                  ? const Center(
                                      child: Text('No goals match your filters',
                                          style:
                                              TextStyle(color: Colors.white38)),
                                    )
                                  : ListView(
                                      children: [
                                        // Saved training goals section
                                        if (isMyGoals &&
                                            savedTrainingGoals.isNotEmpty) ...[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6, top: 4),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.trending_up,
                                                    size: 14,
                                                    color: Color(0xFF42A5F5)),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Training Goals (${savedTrainingGoals.length})',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF42A5F5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          for (final g
                                              in savedTrainingGoals) ...[
                                            Builder(builder: (_) {
                                              final tid = _TrainingPlanView
                                                  .trainingGoalId(
                                                      g.skill, g.targetLevel);
                                              return _MicroGoalTile(
                                                goal: g,
                                                isSaved: true,
                                                isCompleted:
                                                    completedIds.contains(tid),
                                                onToggleSaved: () => ref
                                                    .read(goalPlannerProvider
                                                        .notifier)
                                                    .toggleSavedGoal(tid),
                                                onToggleComplete: () => ref
                                                    .read(goalPlannerProvider
                                                        .notifier)
                                                    .toggleOsrsGoal(tid),
                                              );
                                            }),
                                          ],
                                        ],
                                        // Milestone goals section header
                                        if (isMyGoals &&
                                            displayGoals.isNotEmpty &&
                                            savedTrainingGoals.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          const Divider(height: 1),
                                          const SizedBox(height: 8),
                                        ],
                                        if (isMyGoals &&
                                            displayGoals.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.flag,
                                                    size: 14,
                                                    color: Color(0xFFD4A017)),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Milestone Goals (${displayGoals.length})',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFFD4A017),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        // Milestone goal items
                                        for (final scored in displayGoals) ...[
                                          Builder(builder: (_) {
                                            final isSelected =
                                                selectedGoal.value?.goal.id ==
                                                    scored.goal.id;
                                            return _GoalListTile(
                                              scored: scored,
                                              isSelected: isSelected,
                                              isCompleted: completedIds
                                                  .contains(scored.goal.id),
                                              isSaved: savedIds
                                                  .contains(scored.goal.id),
                                              onTap: () =>
                                                  selectedGoal.value = scored,
                                              onToggleComplete: () {
                                                ref
                                                    .read(goalPlannerProvider
                                                        .notifier)
                                                    .toggleOsrsGoal(
                                                        scored.goal.id);
                                              },
                                              onToggleSaved: () {
                                                ref
                                                    .read(goalPlannerProvider
                                                        .notifier)
                                                    .toggleSavedGoal(
                                                        scored.goal.id);
                                              },
                                            );
                                          }),
                                        ],
                                      ],
                                    ),
                        ),
                        const SizedBox(width: 12),

                        // Detail panel
                        SizedBox(
                          width: 300,
                          child: selectedGoal.value != null
                              ? _GoalDetailPanel(
                                  scored: selectedGoal.value!,
                                  isCompleted: completedIds
                                      .contains(selectedGoal.value!.goal.id),
                                  isSaved: savedIds
                                      .contains(selectedGoal.value!.goal.id),
                                  onToggleComplete: () {
                                    ref
                                        .read(goalPlannerProvider.notifier)
                                        .toggleOsrsGoal(
                                            selectedGoal.value!.goal.id);
                                  },
                                  onToggleSaved: () {
                                    ref
                                        .read(goalPlannerProvider.notifier)
                                        .toggleSavedGoal(
                                            selectedGoal.value!.goal.id);
                                  },
                                )
                              : const Center(
                                  child: Text('Select a goal',
                                      style: TextStyle(color: Colors.white38)),
                                ),
                        ),
                      ],
                    );
                  }),
                ),
            ],
          ],
        ),
      ),
    );
  }

  static String _charTypeToMode(String typeName) {
    switch (typeName) {
      case 'iron':
        return 'ironman';
      case 'hcim':
        return 'hardcore_ironman';
      case 'uim':
        return 'ultimate';
      default:
        return 'normal';
    }
  }
}

// ─── Training Plan View ──────────────────────────────

class _TrainingPlanView extends ConsumerWidget {
  final Map<String, int> playerLevels;
  final bool isIronman;
  final Intensity intensityPref;
  const _TrainingPlanView({
    required this.playerLevels,
    this.isIronman = false,
    this.intensityPref = Intensity.either,
  });

  static String trainingGoalId(String skill, int targetLevel) =>
      'training:$skill:$targetLevel';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(goalPlannerProvider).savedGoalIds;
    final completedIds = ref.watch(goalPlannerProvider).completedOsrsGoalIds;
    if (playerLevels.isEmpty) {
      return const Center(
        child:
            Text('Loading stats...', style: TextStyle(color: Colors.white38)),
      );
    }

    final topGoals = MicroGoalsEngine.getTopRecommendations(
      playerLevels: playerLevels,
      isIronman: isIronman,
      intensityPref: intensityPref,
      limit: 20,
    );
    final quickWins = MicroGoalsEngine.getQuickWins(
      playerLevels: playerLevels,
      isIronman: isIronman,
      intensityPref: intensityPref,
      maxHours: 5,
    );
    final sessionGoals = MicroGoalsEngine.generateSessionGoals(
      playerLevels: playerLevels,
      isIronman: isIronman,
      intensityPref: intensityPref,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Recommended next goals
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: Color(0xFFD4A017)),
                  SizedBox(width: 6),
                  Text('Recommended Next Goals',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4A017),
                      )),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: topGoals.length,
                  itemBuilder: (_, i) {
                    final g = topGoals[i];
                    final tid = trainingGoalId(g.skill, g.targetLevel);
                    return _MicroGoalTile(
                      goal: g,
                      isSaved: savedIds.contains(tid),
                      isCompleted: completedIds.contains(tid),
                      onToggleSaved: () => ref
                          .read(goalPlannerProvider.notifier)
                          .toggleSavedGoal(tid),
                      onToggleComplete: () => ref
                          .read(goalPlannerProvider.notifier)
                          .toggleOsrsGoal(tid),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right: Session goals + Quick wins + skill overview
        SizedBox(
          width: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session goals section
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Color(0xFF7E57C2)),
                  const SizedBox(width: 6),
                  Text(
                    'Session Goals${intensityPref == Intensity.afk ? ' (AFK)' : intensityPref == Intensity.active ? ' (Active)' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7E57C2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 160,
                child: sessionGoals.isEmpty
                    ? const Center(
                        child: Text('No session goals for current filters',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12)))
                    : ListView.builder(
                        itemCount:
                            sessionGoals.length > 10 ? 10 : sessionGoals.length,
                        itemBuilder: (_, i) {
                          final s = sessionGoals[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7E57C2),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(s.description,
                                              style:
                                                  const TextStyle(fontSize: 11),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          Text(
                                            '${s.skill} Lv${s.currentLevel} — ${_fmtXp(s.xpGained)} XP',
                                            style: const TextStyle(
                                                fontSize: 9,
                                                color: Colors.white38),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      MicroGoalsEngine.formatHours(
                                          s.estimatedHours),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF7E57C2),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      s.method.intensity == Intensity.afk
                                          ? Icons.weekend
                                          : Icons.directions_run,
                                      size: 10,
                                      color: Colors.white24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(height: 12),
              // Quick wins section
              const Row(
                children: [
                  Icon(Icons.flash_on, size: 16, color: Color(0xFF43A047)),
                  SizedBox(width: 6),
                  Text('Quick Wins (< 5 hrs)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF43A047),
                      )),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 120,
                child: quickWins.isEmpty
                    ? const Center(
                        child: Text('No quick wins available',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12)))
                    : ListView.builder(
                        itemCount: quickWins.length > 6 ? 6 : quickWins.length,
                        itemBuilder: (_, i) {
                          final g = quickWins[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: _priorityToColor(g.priority),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${g.skill} ${g.currentLevel}\u2192${g.targetLevel}',
                                    style: const TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  MicroGoalsEngine.formatHours(
                                      g.estimatedHours),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF43A047),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const Divider(height: 12),
              // Skill overview
              const Row(
                children: [
                  Icon(Icons.bar_chart, size: 16, color: Colors.white54),
                  SizedBox(width: 6),
                  Text('Skills to 99',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white54,
                      )),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: _SkillOverviewList(
                  playerLevels: playerLevels,
                  isIronman: isIronman,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmtXp(int xp) {
    if (xp >= 1000000) return '${(xp / 1000000).toStringAsFixed(1)}M';
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(0)}k';
    return '$xp';
  }
}

Color _priorityToColor(int priority) {
  if (priority >= 5) return const Color(0xFFD4A017);
  if (priority >= 4) return const Color(0xFFFF9800);
  if (priority >= 3) return const Color(0xFF1E88E5);
  return Colors.white24;
}

class _MicroGoalTile extends StatelessWidget {
  final MicroGoal goal;
  final bool isSaved;
  final bool isCompleted;
  final VoidCallback? onToggleSaved;
  final VoidCallback? onToggleComplete;
  const _MicroGoalTile({
    required this.goal,
    this.isSaved = false,
    this.isCompleted = false,
    this.onToggleSaved,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final pColor = _priorityToColor(goal.priority);

    return Card(
      color: isCompleted ? Colors.green.withValues(alpha: 0.08) : null,
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Checkbox for completion
            if (onToggleComplete != null)
              SizedBox(
                width: 28,
                child: Checkbox(
                  value: isCompleted,
                  onChanged: (_) => onToggleComplete!(),
                  activeColor: const Color(0xFFD4A017),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            // Priority bar
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : pColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            // Skill + levels
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.skill,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isCompleted ? Colors.white38 : null,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      )),
                  Text('${goal.currentLevel} → ${goal.targetLevel}',
                      style: TextStyle(
                          fontSize: 11,
                          color: isCompleted ? Colors.white24 : pColor)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Milestone unlock
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.milestone,
                      style: TextStyle(
                        fontSize: 11,
                        color: isCompleted ? Colors.white38 : Colors.white70,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Row(
                    children: [
                      const Icon(Icons.speed, size: 10, color: Colors.white38),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${goal.bestMethod.method} — ${_formatXpHr(goal.bestMethod.xpPerHour)}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white38),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time estimate
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isCompleted
                      ? 'Done'
                      : MicroGoalsEngine.formatHours(goal.estimatedHours),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? Colors.green
                        : goal.estimatedHours < 3
                            ? const Color(0xFF43A047)
                            : goal.estimatedHours < 10
                                ? const Color(0xFFFF9800)
                                : Colors.white54,
                  ),
                ),
                if (!isCompleted)
                  Text(
                    '${_formatXp(goal.xpNeeded)} XP',
                    style: const TextStyle(fontSize: 9, color: Colors.white30),
                  ),
              ],
            ),
            // Bookmark icon
            if (onToggleSaved != null) ...[
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onToggleSaved,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: isSaved ? const Color(0xFF42A5F5) : Colors.white24,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatXpHr(int xphr) {
    if (xphr == 0) return 'Quest';
    if (xphr >= 1000000) return '${(xphr / 1000000).toStringAsFixed(1)}M/hr';
    if (xphr >= 1000) return '${(xphr / 1000).toStringAsFixed(0)}k/hr';
    return '$xphr/hr';
  }

  String _formatXp(int xp) {
    if (xp >= 1000000) return '${(xp / 1000000).toStringAsFixed(1)}M';
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(0)}k';
    return '$xp';
  }
}

class _SkillOverviewList extends StatelessWidget {
  final Map<String, int> playerLevels;
  final bool isIronman;
  const _SkillOverviewList(
      {required this.playerLevels, this.isIronman = false});

  @override
  Widget build(BuildContext context) {
    final skills = trainingData.keys.toList();
    skills.sort((a, b) {
      final la = playerLevels[a] ?? 1;
      final lb = playerLevels[b] ?? 1;
      return la.compareTo(lb);
    });

    return ListView.builder(
      itemCount: skills.length,
      itemBuilder: (_, i) {
        final skill = skills[i];
        final level = playerLevels[skill] ?? 1;
        final pct = level / 99;
        final info = trainingData[skill];
        final method = info?.bestMethodAt(level, isIronman: isIronman);

        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(skill,
                    style: TextStyle(
                      fontSize: 10,
                      color: level >= 99
                          ? const Color(0xFFD4A017)
                          : Colors.white60,
                    )),
              ),
              Text('$level',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: level >= 99
                        ? const Color(0xFFD4A017)
                        : level >= 80
                            ? const Color(0xFF43A047)
                            : level >= 50
                                ? Colors.white
                                : Colors.white54,
                  )),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(
                      level >= 99
                          ? const Color(0xFFD4A017)
                          : level >= 80
                              ? const Color(0xFF43A047)
                              : level >= 50
                                  ? const Color(0xFF1E88E5)
                                  : const Color(0xFF78909C),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (method != null && level < 99)
                Text(
                  _shortXpHr(method.xpPerHour),
                  style: const TextStyle(fontSize: 9, color: Colors.white30),
                ),
              if (level >= 99)
                const Text('✓',
                    style: TextStyle(fontSize: 10, color: Color(0xFFD4A017))),
            ],
          ),
        );
      },
    );
  }

  String _shortXpHr(int xp) {
    if (xp == 0) return '';
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(0)}k/h';
    return '$xp/h';
  }
}

// ─── Small Widgets ───────────────────────────────────

class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatBadge(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(width: 4),
          Text(label,
              style:
                  TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11)),
        ],
      ),
    );
  }
}

class _ReadinessDropdown extends StatelessWidget {
  final GoalReadiness? value;
  final ValueChanged<GoalReadiness?> onChanged;
  const _ReadinessDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<GoalReadiness?>(
      value: value,
      hint: const Text('Readiness'),
      items: const [
        DropdownMenuItem(value: null, child: Text('All')),
        DropdownMenuItem(
            value: GoalReadiness.ready, child: Text('\u2705 Ready Now')),
        DropdownMenuItem(
            value: GoalReadiness.almostReady,
            child: Text('\u26a0\ufe0f Almost Ready')),
        DropdownMenuItem(
            value: GoalReadiness.workTowards,
            child: Text('\ud83d\udcaa Work Towards')),
      ],
      onChanged: onChanged,
    );
  }
}

// ─── Category Tile ───────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Material(
        color: isSelected
            ? const Color(0xFFD4A017).withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(
              children: [
                Icon(icon,
                    size: 14,
                    color:
                        isSelected ? const Color(0xFFD4A017) : Colors.white38),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? Colors.white : Colors.white60,
                      ),
                      overflow: TextOverflow.ellipsis),
                ),
                Text('$count',
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isSelected ? const Color(0xFFD4A017) : Colors.white30,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Goal List Tile ──────────────────────────────────

Color _readinessColor(GoalReadiness r) {
  switch (r) {
    case GoalReadiness.ready:
      return const Color(0xFF43A047);
    case GoalReadiness.almostReady:
      return const Color(0xFFFF9800);
    case GoalReadiness.workTowards:
      return const Color(0xFF78909C);
  }
}

String _readinessLabel(GoalReadiness r) {
  switch (r) {
    case GoalReadiness.ready:
      return 'Ready';
    case GoalReadiness.almostReady:
      return 'Almost';
    case GoalReadiness.workTowards:
      return 'Train';
  }
}

class _GoalListTile extends StatelessWidget {
  final ScoredGoal scored;
  final bool isSelected;
  final bool isCompleted;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleSaved;

  const _GoalListTile({
    required this.scored,
    required this.isSelected,
    required this.isCompleted,
    this.isSaved = false,
    required this.onTap,
    required this.onToggleComplete,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    final goal = scored.goal;
    final rColor = _readinessColor(scored.readiness);
    final pct = scored.completionPercent;

    return Card(
      color: isSelected
          ? const Color(0xFFD4A017).withValues(alpha: 0.12)
          : isCompleted
              ? Colors.green.withValues(alpha: 0.08)
              : null,
      margin: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: 28,
                child: Checkbox(
                  value: isCompleted,
                  onChanged: (_) => onToggleComplete(),
                  activeColor: const Color(0xFFD4A017),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 6),
              // Priority indicator
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: _priorityColor(goal.priority),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              // Name + category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.white38 : Colors.white,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      categoryLabel(goal.category),
                      style:
                          const TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              // Progress bar
              if (!isCompleted) ...[
                SizedBox(
                  width: 50,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 4,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation(rColor),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('${pct.toInt()}%',
                          style: TextStyle(fontSize: 9, color: rColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Bookmark icon
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onToggleSaved,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: isSaved ? const Color(0xFF42A5F5) : Colors.white24,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Readiness badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.2)
                      : rColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isCompleted ? 'Done' : _readinessLabel(scored.readiness),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isCompleted ? Colors.green : rColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(int priority) {
    if (priority >= 5) return const Color(0xFFD4A017);
    if (priority >= 4) return const Color(0xFFFF9800);
    if (priority >= 3) return const Color(0xFF1E88E5);
    return Colors.white24;
  }
}

// ─── Detail Panel ────────────────────────────────────

class _GoalDetailPanel extends StatelessWidget {
  final ScoredGoal scored;
  final bool isCompleted;
  final bool isSaved;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleSaved;

  const _GoalDetailPanel({
    required this.scored,
    required this.isCompleted,
    this.isSaved = false,
    required this.onToggleComplete,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    final goal = scored.goal;
    final rColor = _readinessColor(scored.readiness);
    final missing = scored.missingSkills;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(goal.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFD4A017),
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: rColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isCompleted
                          ? 'Completed'
                          : _readinessLabel(scored.readiness),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isCompleted ? Colors.green : rColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(categoryLabel(goal.category),
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white54)),
                  const Spacer(),
                  Text('${'★' * goal.priority}${'☆' * (5 - goal.priority)}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFD4A017))),
                ],
              ),
              const Divider(height: 20),

              // Description
              Text(goal.description,
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 12),

              // Rewards
              if (goal.rewards.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(Icons.emoji_events,
                        size: 14, color: Color(0xFFD4A017)),
                    SizedBox(width: 6),
                    Text('Rewards',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD4A017),
                        )),
                  ],
                ),
                const SizedBox(height: 4),
                Text(goal.rewards,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white60)),
                const SizedBox(height: 12),
              ],

              // Requirements
              if (goal.skillRequirements.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(Icons.checklist, size: 14, color: Color(0xFF64B5F6)),
                    SizedBox(width: 6),
                    Text('Requirements',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64B5F6),
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                ...goal.skillRequirements.entries.map((entry) {
                  final gap = scored.skillGaps[entry.key];
                  final met = gap?.met ?? false;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      children: [
                        Icon(
                          met ? Icons.check_circle : Icons.circle_outlined,
                          size: 12,
                          color: met ? Colors.green : Colors.red[300],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(entry.key,
                              style: TextStyle(
                                fontSize: 11,
                                color: met ? Colors.white54 : Colors.white,
                              )),
                        ),
                        Text(
                          gap != null
                              ? '${gap.current}/${entry.value}'
                              : '?/${entry.value}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: met ? Colors.green : Colors.red[300],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],

              // Missing skills summary
              if (missing.isNotEmpty && !isCompleted) ...[
                const Row(
                  children: [
                    Icon(Icons.trending_up, size: 14, color: Color(0xFFFF9800)),
                    SizedBox(width: 6),
                    Text('Levels Needed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF9800),
                        )),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: missing.map((g) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${g.skill}: +${g.gap}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red[300],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Progress bar
              if (!isCompleted) ...[
                Row(
                  children: [
                    const Text('Progress: ',
                        style: TextStyle(fontSize: 11, color: Colors.white54)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: scored.completionPercent / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation(rColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${scored.completionPercent.toInt()}%',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: rColor)),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onToggleSaved,
                      icon: Icon(
                        isSaved ? Icons.bookmark_remove : Icons.bookmark_add,
                        size: 16,
                      ),
                      label: Text(
                        isSaved ? 'Remove from My Goals' : 'Add to My Goals',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSaved
                            ? Colors.grey[700]
                            : const Color(0xFF42A5F5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onToggleComplete,
                  icon: Icon(
                    isCompleted ? Icons.undo : Icons.check_circle,
                    size: 16,
                  ),
                  label:
                      Text(isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted
                        ? Colors.grey[700]
                        : const Color(0xFF43A047),
                  ),
                ),
              ),

              // Wiki link
              if (goal.wikiUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.open_in_new,
                        size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Expanded(
                      child: SelectableText(
                        goal.wikiUrl,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64B5F6),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
