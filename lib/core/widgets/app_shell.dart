import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../config/environment.dart';
import '../constants/app_constants.dart';

const _sidebarWidth = 230.0;
const _accentColor = Color(0xFFD4A017); // OSRS gold
const _sidebarBg = Color(0xFF1E1408); // Darkest brown
const _hoverColor = Color(0xFF3B2A14); // Brown hover
const _selectedBg = Color(0xFF2D5F27); // Dark green selected

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
          icon: Icons.timer_outlined,
          selectedIcon: Icons.timer,
          label: 'Daily Tasks',
          path: '/daily-tasks'),
      _NavItem(
          icon: Icons.travel_explore_outlined,
          selectedIcon: Icons.travel_explore,
          label: 'Wiki Search',
          path: '/wiki'),
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
            decoration: const BoxDecoration(
              color: _sidebarBg,
              border:
                  Border(right: BorderSide(color: Color(0xFF5C4529), width: 1)),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Divider(
                                color: const Color(0xFF5C4529)
                                    .withValues(alpha: 0.4),
                                height: 1,
                                thickness: 1),
                          ),
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFD4A017).withValues(alpha: 0.35),
          letterSpacing: 1.8,
        ),
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
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? _selectedBg
                  : _hovering
                      ? _hoverColor
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFF3B8132).withValues(alpha: 0.5),
                      width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? widget.item.selectedIcon : widget.item.icon,
                  size: 18,
                  color: isSelected
                      ? _accentColor
                      : _hovering
                          ? Colors.white70
                          : Colors.white38,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : _hovering
                              ? Colors.white70
                              : Colors.white54,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(2),
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
