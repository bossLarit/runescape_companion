import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text('OSRS Companion v1.0.0'),
                    const SizedBox(height: 4),
                    const Text(
                      'A standalone desktop companion app for Old School RuneScape.\n'
                      'This app does NOT automate gameplay, send inputs to the game, '
                      'or read memory/process data from the game client.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text(
                      'All data is stored locally on your machine. No cloud sync.\n'
                      'Data files are stored in your Documents/osrs_companion folder.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Features', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const _FeatureItem(icon: Icons.people, title: 'Character Management', desc: 'Manage multiple accounts'),
                    const _FeatureItem(icon: Icons.flag, title: 'Goal Tracker', desc: 'Track XP, GP, KC, quest goals'),
                    const _FeatureItem(icon: Icons.timer, title: 'Session Tracker', desc: 'Log play sessions and results'),
                    const _FeatureItem(icon: Icons.note, title: 'Notes', desc: 'Personal knowledge base'),
                    const _FeatureItem(icon: Icons.lock, title: 'Password Vault', desc: 'Encrypted local vault'),
                    const _FeatureItem(icon: Icons.account_tree, title: 'Goal Planner', desc: 'Dependency-based goal planning'),
                    const _FeatureItem(icon: Icons.schedule, title: 'Time Budget', desc: 'Activity suggestions based on time'),
                    const _FeatureItem(icon: Icons.grid_view, title: 'Command Center', desc: 'Multi-account overview'),
                    const _FeatureItem(icon: Icons.search, title: 'Wiki Search', desc: 'Quick OSRS Wiki lookup'),
                    const _FeatureItem(icon: Icons.menu_book, title: 'Build Cookbook', desc: 'Progression templates & guides'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white54),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
