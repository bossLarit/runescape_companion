import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/update_service.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),

            // ── Update section ──
            _UpdateCard(
              updateState: updateState,
              onCheck: () => ref.read(updateProvider.notifier).checkForUpdate(),
              onDownload: () =>
                  ref.read(updateProvider.notifier).downloadUpdate(),
              onInstall: () =>
                  ref.read(updateProvider.notifier).installUpdate(),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text('OSRS Companion v${AppConstants.version}'),
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
                    Text('Data',
                        style: Theme.of(context).textTheme.titleMedium),
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
                    Text('Features',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const _FeatureItem(
                        icon: Icons.people,
                        title: 'Character Management',
                        desc: 'Manage multiple accounts'),
                    const _FeatureItem(
                        icon: Icons.flag,
                        title: 'Goal Tracker',
                        desc: 'Track XP, GP, KC, quest goals'),
                    const _FeatureItem(
                        icon: Icons.timer,
                        title: 'Session Tracker',
                        desc: 'Log play sessions and results'),
                    const _FeatureItem(
                        icon: Icons.note,
                        title: 'Notes',
                        desc: 'Personal knowledge base'),
                    const _FeatureItem(
                        icon: Icons.lock,
                        title: 'Password Vault',
                        desc: 'Encrypted local vault'),
                    const _FeatureItem(
                        icon: Icons.account_tree,
                        title: 'Goal Planner',
                        desc: 'Dependency-based goal planning'),
                    const _FeatureItem(
                        icon: Icons.schedule,
                        title: 'Time Budget',
                        desc: 'Activity suggestions based on time'),
                    const _FeatureItem(
                        icon: Icons.grid_view,
                        title: 'Command Center',
                        desc: 'Multi-account overview'),
                    const _FeatureItem(
                        icon: Icons.search,
                        title: 'Wiki Search',
                        desc: 'Quick OSRS Wiki lookup'),
                    const _FeatureItem(
                        icon: Icons.menu_book,
                        title: 'Build Cookbook',
                        desc: 'Progression templates & guides'),
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
  const _FeatureItem(
      {required this.icon, required this.title, required this.desc});

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
          Text(desc,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Update Card ─────────────────────────────────────────────────

class _UpdateCard extends StatelessWidget {
  final UpdateState updateState;
  final VoidCallback onCheck;
  final VoidCallback onDownload;
  final VoidCallback onInstall;

  const _UpdateCard({
    required this.updateState,
    required this.onCheck,
    required this.onDownload,
    required this.onInstall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: updateState.status == UpdateStatus.updateAvailable ||
              updateState.status == UpdateStatus.readyToInstall
          ? const Color(0xFF43A047).withValues(alpha: 0.08)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _statusIcon,
                  size: 20,
                  color: _statusColor,
                ),
                const SizedBox(width: 8),
                Text('Updates', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                const Text(
                  'v${AppConstants.version}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status message
            _buildStatusContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusContent(BuildContext context) {
    switch (updateState.status) {
      case UpdateStatus.idle:
        return Row(
          children: [
            const Text(
              'Check for new versions from GitHub.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: onCheck,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Check for Updates'),
            ),
          ],
        );

      case UpdateStatus.checking:
        return const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Checking for updates...',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        );

      case UpdateStatus.upToDate:
        return Row(
          children: [
            const Icon(Icons.check_circle, size: 16, color: Color(0xFF43A047)),
            const SizedBox(width: 8),
            const Text(
              'You\'re on the latest version!',
              style: TextStyle(color: Color(0xFF43A047), fontSize: 13),
            ),
            const Spacer(),
            TextButton(
              onPressed: onCheck,
              child: const Text('Check again', style: TextStyle(fontSize: 12)),
            ),
          ],
        );

      case UpdateStatus.updateAvailable:
        final release = updateState.release!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: const Color(0xFF43A047).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.new_releases,
                      size: 16, color: Color(0xFF43A047)),
                  const SizedBox(width: 8),
                  Text(
                    'Version ${release.version} is available!',
                    style: const TextStyle(
                      color: Color(0xFF43A047),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  if (release.hasDownload)
                    ElevatedButton.icon(
                      onPressed: onDownload,
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047),
                      ),
                    )
                  else
                    const Text(
                      'No Windows build attached',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                ],
              ),
            ),
            if (release.body.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Release Notes:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white70)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  release.body,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.white54, height: 1.5),
                ),
              ),
            ],
          ],
        );

      case UpdateStatus.downloading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  'Downloading... ${(updateState.downloadProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: updateState.downloadProgress,
                minHeight: 6,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF43A047)),
              ),
            ),
          ],
        );

      case UpdateStatus.readyToInstall:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF43A047).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: const Color(0xFF43A047).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle,
                  size: 20, color: Color(0xFF43A047)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Download complete!',
                      style: TextStyle(
                          color: Color(0xFF43A047),
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'The app will close, update, and restart automatically.',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: onInstall,
                icon: const Icon(Icons.system_update, size: 16),
                label: const Text('Install & Restart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                ),
              ),
            ],
          ),
        );

      case UpdateStatus.error:
        return Row(
          children: [
            const Icon(Icons.error_outline, size: 16, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                updateState.errorMessage ?? 'Unknown error',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: onCheck,
              child: const Text('Retry', style: TextStyle(fontSize: 12)),
            ),
          ],
        );
    }
  }

  IconData get _statusIcon {
    switch (updateState.status) {
      case UpdateStatus.idle:
        return Icons.update;
      case UpdateStatus.checking:
      case UpdateStatus.downloading:
        return Icons.sync;
      case UpdateStatus.upToDate:
        return Icons.check_circle_outline;
      case UpdateStatus.updateAvailable:
        return Icons.new_releases_outlined;
      case UpdateStatus.readyToInstall:
        return Icons.download_done;
      case UpdateStatus.error:
        return Icons.error_outline;
    }
  }

  Color get _statusColor {
    switch (updateState.status) {
      case UpdateStatus.idle:
      case UpdateStatus.checking:
      case UpdateStatus.downloading:
        return Colors.white54;
      case UpdateStatus.upToDate:
        return const Color(0xFF43A047);
      case UpdateStatus.updateAvailable:
      case UpdateStatus.readyToInstall:
        return const Color(0xFF43A047);
      case UpdateStatus.error:
        return Colors.red;
    }
  }
}
