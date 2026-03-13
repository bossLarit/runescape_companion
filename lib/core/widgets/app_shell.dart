import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../config/environment.dart';
import '../constants/app_constants.dart';
import '../design_system/design_system.dart';

const _sidebarWidth = 240.0;
const _accentColor = kGold;
const _sidebarBg = Color(0xFF17100A);
const _hoverColor = Color(0xFF2E2010);
const _selectedBg = Color(0xFF1A2E14);

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _sections = <_NavSection>[
    _NavSection(header: null, items: [
      _NavItem(
          icon: Icons.space_dashboard_outlined,
          selectedIcon: Icons.space_dashboard,
          label: 'Dashboard',
          path: '/dashboard'),
    ]),
    _NavSection(header: 'ACCOUNT', items: [
      _NavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Characters',
          path: '/characters'),
      _NavItem(
          icon: Icons.grid_view_outlined,
          selectedIcon: Icons.grid_view,
          label: 'Command Center',
          path: '/command-center'),
      _NavItem(
          icon: Icons.lock_outline,
          selectedIcon: Icons.lock,
          label: 'Vault',
          path: '/vault'),
    ]),
    _NavSection(header: 'TRACKING', items: [
      _NavItem(
          icon: Icons.flag_outlined,
          selectedIcon: Icons.flag,
          label: 'Goals',
          path: '/goals'),
      _NavItem(
          icon: Icons.play_circle_outline,
          selectedIcon: Icons.play_circle,
          label: 'Sessions',
          path: '/sessions'),
      _NavItem(
          icon: Icons.sticky_note_2_outlined,
          selectedIcon: Icons.sticky_note_2,
          label: 'Notes',
          path: '/notes'),
      _NavItem(
          icon: Icons.grid_view_outlined,
          selectedIcon: Icons.grid_view_rounded,
          label: 'Bingo',
          path: '/bingo'),
    ]),
    _NavSection(header: 'PLANNING', items: [
      _NavItem(
          icon: Icons.account_tree_outlined,
          selectedIcon: Icons.account_tree,
          label: 'Goal Planner',
          path: '/planner'),
      _NavItem(
          icon: Icons.local_fire_department_outlined,
          selectedIcon: Icons.local_fire_department,
          label: 'Boss Progression',
          path: '/boss-progression'),
      _NavItem(
          icon: Icons.schedule_outlined,
          selectedIcon: Icons.schedule,
          label: 'Time Budget',
          path: '/time-budget'),
      _NavItem(
          icon: Icons.auto_stories_outlined,
          selectedIcon: Icons.auto_stories,
          label: 'Cookbook',
          path: '/cookbook'),
    ]),
    _NavSection(header: 'TOOLS', items: [
      _NavItem(
          icon: Icons.shield_outlined,
          selectedIcon: Icons.shield,
          label: 'Best Setup',
          path: '/best-setup'),
      _NavItem(
          icon: Icons.person_search_outlined,
          selectedIcon: Icons.person_search,
          label: 'Player Tracker',
          path: '/player-tracker'),
      _NavItem(
          icon: Icons.paid_outlined,
          selectedIcon: Icons.paid,
          label: 'GE Prices',
          path: '/ge-prices'),
      _NavItem(
          icon: Icons.calculate_outlined,
          selectedIcon: Icons.calculate,
          label: 'Skill Calculator',
          path: '/skill-calc'),
      _NavItem(
          icon: Icons.casino_outlined,
          selectedIcon: Icons.casino,
          label: 'Dry Calculator',
          path: '/dry-calc'),
      _NavItem(
          icon: Icons.trending_down_outlined,
          selectedIcon: Icons.trending_down,
          label: 'Dry Streak Tracker',
          path: '/dry-streak'),
      _NavItem(
          icon: Icons.pets_outlined,
          selectedIcon: Icons.pets,
          label: 'Pet Hunter',
          path: '/pet-hunter'),
      _NavItem(
          icon: Icons.handyman_outlined,
          selectedIcon: Icons.handyman,
          label: 'Item Lookup',
          path: '/item-lookup'),
      _NavItem(
          icon: Icons.timer_outlined,
          selectedIcon: Icons.timer,
          label: 'Daily Tasks',
          path: '/daily-tasks'),
      _NavItem(
          icon: Icons.travel_explore_outlined,
          selectedIcon: Icons.travel_explore,
          label: 'Wiki Search',
          path: '/wiki'),
      _NavItem(
          icon: Icons.sports_kabaddi_outlined,
          selectedIcon: Icons.sports_kabaddi,
          label: 'Idle Adventurer',
          path: '/idle-adventure'),
      _NavItem(
          icon: Icons.cell_tower_outlined,
          selectedIcon: Icons.cell_tower,
          label: 'Tower Defense',
          path: '/tower-defense'),
    ]),
    _NavSection(header: 'IRONMAN', items: [
      _NavItem(
          icon: Icons.account_tree_outlined,
          selectedIcon: Icons.account_tree,
          label: 'Supply Chain',
          path: '/ironman-supply'),
    ]),
    _NavSection(header: null, items: [
      _NavItem(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          label: 'Settings',
          path: '/settings'),
    ]),
  ];

  String _currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = _currentPath(context);
    final env = ref.watch(envConfigProvider);

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: _sidebarWidth,
            decoration: BoxDecoration(
              color: _sidebarBg,
              border: Border(
                right: BorderSide(
                    color: const Color(0xFF3B2A14).withValues(alpha: 0.6)),
              ),
            ),
            child: Column(
              children: [
                _buildLogo(context),
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    children: [
                      for (final section in _sections) ...[
                        if (section.header != null)
                          _SectionHeader(label: section.header!),
                        for (final item in section.items)
                          _NavTile(
                            item: item,
                            isSelected: currentPath.startsWith(item.path),
                            onTap: () => context.go(item.path),
                          ),
                        if (section != _sections.last)
                          const SizedBox(height: 4),
                      ],
                    ],
                  ),
                ),
                _buildFooter(env),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1A08), Color(0xFF1A0E04)],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF5C4529).withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // OSRS-style icon: crossed swords over shield
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8C34A),
                    Color(0xFFD4A017),
                    Color(0xFF9E7A12),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFB8860B).withValues(alpha: 0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.shield,
                      color: const Color(0xFF1E1408).withValues(alpha: 0.6),
                      size: 24),
                  const Icon(Icons.security,
                      color: Color(0xFF1E1408), size: 22),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFFD966),
                        Color(0xFFD4A017),
                        Color(0xFFFFD966),
                      ],
                    ).createShader(bounds),
                    child: const Text('OSRS',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3.0,
                            height: 1)),
                  ),
                  const SizedBox(height: 2),
                  Text('C O M P A N I O N',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.45),
                          letterSpacing: 2.5,
                          height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(EnvConfig env) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                    blurRadius: 4)
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('v${AppConstants.version}',
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.3),
                  letterSpacing: 0.5)),
          if (!env.isProd) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: env.isDev
                    ? const Color(0xFFFF9800).withValues(alpha: 0.2)
                    : const Color(0xFF2196F3).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: env.isDev
                      ? const Color(0xFFFF9800).withValues(alpha: 0.4)
                      : const Color(0xFF2196F3).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                env.label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: env.isDev
                      ? const Color(0xFFFF9800)
                      : const Color(0xFF2196F3),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
          const Spacer(),
          Text('Desktop',
              style: TextStyle(
                  fontSize: 10, color: Colors.white.withValues(alpha: 0.2))),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 10,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: _accentColor.withValues(alpha: 0.4),
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavTile(
      {required this.item, required this.isSelected, required this.onTap});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? _selectedBg
                  : _hovering
                      ? _hoverColor
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Gold accent bar for selected
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 3,
                  height: isSelected ? 18 : 0,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? _accentColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _accentColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                            )
                          ]
                        : null,
                  ),
                ),
                Icon(
                  isSelected ? widget.item.selectedIcon : widget.item.icon,
                  size: 17,
                  color: isSelected
                      ? _accentColor
                      : _hovering
                          ? const Color(0xFFD2C3A3)
                          : const Color(0xFF8A7560),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFFF5E6C8)
                          : _hovering
                              ? const Color(0xFFD2C3A3)
                              : const Color(0xFF8A7560),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSection {
  final String? header;
  final List<_NavItem> items;
  const _NavSection({this.header, required this.items});
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;
  const _NavItem(
      {required this.icon,
      required this.selectedIcon,
      required this.label,
      required this.path});
}
