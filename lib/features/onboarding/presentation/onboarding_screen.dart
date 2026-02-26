import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../characters/domain/character_model.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import 'providers/onboarding_provider.dart';

const _gold = Color(0xFFD4A017);
const _darkBrown = Color(0xFF2B1D0E);
const _brown = Color(0xFF3B2A14);
const _medBrown = Color(0xFF4A3621);
const _lightBrown = Color(0xFF5C4529);
const _green = Color(0xFF3B8132);
const _darkGreen = Color(0xFF2D5F27);
const _cream = Color(0xFFF5E6C8);

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = useState(0);
    final rsnCtrl = useTextEditingController();
    final accountType = useState(CharacterType.main);
    final characterCreated = useState(false);
    final totalSteps = 4;

    return Scaffold(
      backgroundColor: _darkBrown,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: _buildStep(
            key: ValueKey(step.value),
            context: context,
            ref: ref,
            step: step,
            totalSteps: totalSteps,
            rsnCtrl: rsnCtrl,
            accountType: accountType,
            characterCreated: characterCreated,
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required Key key,
    required BuildContext context,
    required WidgetRef ref,
    required ValueNotifier<int> step,
    required int totalSteps,
    required TextEditingController rsnCtrl,
    required ValueNotifier<CharacterType> accountType,
    required ValueNotifier<bool> characterCreated,
  }) {
    switch (step.value) {
      case 0:
        return _WelcomeStep(key: key, onNext: () => step.value = 1);
      case 1:
        return _CharacterStep(
          key: key,
          rsnCtrl: rsnCtrl,
          accountType: accountType,
          characterCreated: characterCreated,
          onCreateCharacter: () async {
            final name = rsnCtrl.text.trim();
            if (name.isEmpty) return;
            final char = Character(
              displayName: name,
              characterType: accountType.value,
              isActive: true,
            );
            await ref.read(charactersProvider.notifier).add(char);
            characterCreated.value = true;
          },
          onNext: () => step.value = 2,
          onSkip: () => step.value = 2,
        );
      case 2:
        return _FeatureTourStep(key: key, onNext: () => step.value = 3);
      case 3:
        return _ReadyStep(
          key: key,
          onFinish: () async {
            await ref.read(onboardingCompleteProvider.notifier).complete();
            if (context.mounted) context.go('/dashboard');
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STEP 0: WELCOME
// ═══════════════════════════════════════════════════════════════════

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomeStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8C34A), _gold, Color(0xFF9E7A12)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFB8860B).withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.shield, color: Color(0xFF1E1408), size: 44),
                Icon(Icons.security, color: Color(0xFF1E1408), size: 38),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFD966), _gold, Color(0xFFFFD966)],
            ).createShader(bounds),
            child: const Text(
              'OSRS COMPANION',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your personal Old School RuneScape toolkit',
            style: TextStyle(
              fontSize: 14,
              color: _cream.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 36),

          // Features preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _darkBrown.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _lightBrown.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                _FeatureRow(
                  icon: Icons.trending_up,
                  text: 'Track your goals, sessions, and progress',
                ),
                const SizedBox(height: 10),
                _FeatureRow(
                  icon: Icons.auto_awesome,
                  text: 'Get personalized training recommendations',
                ),
                const SizedBox(height: 10),
                _FeatureRow(
                  icon: Icons.calculate,
                  text: 'Skill calculators, GE prices, and wiki search',
                ),
                const SizedBox(height: 10),
                _FeatureRow(
                  icon: Icons.lock_outline,
                  text: 'Encrypted vault for your account notes',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No automation. No botting. No game memory reading.\nJust a helpful companion on your desktop.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.3),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Let's Get Started",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _gold.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 13, color: _cream.withValues(alpha: 0.8))),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STEP 1: ADD CHARACTER
// ═══════════════════════════════════════════════════════════════════

class _CharacterStep extends StatelessWidget {
  final TextEditingController rsnCtrl;
  final ValueNotifier<CharacterType> accountType;
  final ValueNotifier<bool> characterCreated;
  final VoidCallback onCreateCharacter;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _CharacterStep({
    super.key,
    required this.rsnCtrl,
    required this.accountType,
    required this.characterCreated,
    required this.onCreateCharacter,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return _StepContainer(
      child: ListenableBuilder(
        listenable: Listenable.merge([rsnCtrl, accountType, characterCreated]),
        builder: (context, _) {
          final created = characterCreated.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                created ? Icons.check_circle : Icons.person_add,
                size: 48,
                color: created ? _green : _gold,
              ),
              const SizedBox(height: 16),
              Text(
                created ? 'Character Added!' : 'Add Your Character',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _gold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                created
                    ? 'Your RuneScape name has been saved. You can add more characters later.'
                    : 'Enter your RuneScape display name so the app can look up your stats and track your progress.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _cream.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              if (!created) ...[
                // RSN input
                TextField(
                  controller: rsnCtrl,
                  decoration: InputDecoration(
                    labelText: 'Display Name (RSN)',
                    hintText: 'e.g. Zezima',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    filled: true,
                    fillColor: _darkBrown.withValues(alpha: 0.8),
                  ),
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) {
                    if (rsnCtrl.text.trim().isNotEmpty) {
                      onCreateCharacter();
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Account type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Type',
                        style: TextStyle(
                          fontSize: 12,
                          color: _cream.withValues(alpha: 0.5),
                        )),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final type in [
                          CharacterType.main,
                          CharacterType.iron,
                          CharacterType.hcim,
                          CharacterType.uim,
                          CharacterType.gim,
                        ])
                          _AccountTypeChip(
                            type: type,
                            selected: accountType.value == type,
                            onTap: () => accountType.value = type,
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Create button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: rsnCtrl.text.trim().isEmpty
                        ? null
                        : onCreateCharacter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Add Character',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onSkip,
                  child: Text('Skip for now',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      )),
                ),
              ] else ...[
                // Success state
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: _green, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rsnCtrl.text.trim(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _cream,
                                )),
                            Text(accountType.value.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _cream.withValues(alpha: 0.5),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Continue',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AccountTypeChip extends StatelessWidget {
  final CharacterType type;
  final bool selected;
  final VoidCallback onTap;
  const _AccountTypeChip(
      {required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _darkGreen : _medBrown,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? _green : _lightBrown.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          type.displayName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? _cream : _cream.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STEP 2: FEATURE TOUR
// ═══════════════════════════════════════════════════════════════════

class _FeatureTourStep extends StatelessWidget {
  final VoidCallback onNext;
  const _FeatureTourStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepContainer(
      maxWidth: 600,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore, size: 44, color: _gold),
          const SizedBox(height: 16),
          const Text(
            'Quick Tour',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _gold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Here's what you'll find in the sidebar",
            style: TextStyle(
              fontSize: 13,
              color: _cream.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Feature cards in 2x2 grid
          Row(
            children: [
              Expanded(
                child: _TourCard(
                  icon: Icons.space_dashboard,
                  title: 'Dashboard & Account',
                  items: [
                    'Dashboard overview',
                    'Manage characters',
                    'Command Center for quick actions',
                  ],
                  color: _gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TourCard(
                  icon: Icons.flag,
                  title: 'Tracking',
                  items: [
                    'Set and track goals',
                    'Log play sessions',
                    'Keep notes and bingo cards',
                  ],
                  color: const Color(0xFF42A5F5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TourCard(
                  icon: Icons.account_tree,
                  title: 'Planning',
                  items: [
                    'AI-powered Goal Planner',
                    'Time Budget calculator',
                    'Ironman Cookbook guides',
                  ],
                  color: _green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TourCard(
                  icon: Icons.calculate,
                  title: 'Tools',
                  items: [
                    'Skill & Drop Rate calculators',
                    'GE Prices live lookup',
                    'Wiki Search & Daily Tasks',
                  ],
                  color: const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tip: Start with the Goal Planner — it recommends what to train next based on your stats!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: _gold.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Almost Done',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;
  final Color color;
  const _TourCard({
    required this.icon,
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _brown,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in items) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _cream.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item,
                        style: TextStyle(
                          fontSize: 11,
                          color: _cream.withValues(alpha: 0.6),
                          height: 1.4,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STEP 3: READY
// ═══════════════════════════════════════════════════════════════════

class _ReadyStep extends StatelessWidget {
  final VoidCallback onFinish;
  const _ReadyStep({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return _StepContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: _green.withValues(alpha: 0.4), width: 2),
            ),
            child: const Icon(Icons.check_rounded, size: 40, color: _green),
          ),
          const SizedBox(height: 24),
          const Text(
            "You're All Set!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _gold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Your companion is ready. Here's how to get the most out of it:",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _cream.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          _QuickTip(
            number: '1',
            text:
                'Go to Characters and click "Lookup Stats" to pull your live levels from the hiscores.',
          ),
          const SizedBox(height: 10),
          _QuickTip(
            number: '2',
            text:
                'Open the Goal Planner — it will generate a personalized training plan based on your stats.',
          ),
          const SizedBox(height: 10),
          _QuickTip(
            number: '3',
            text:
                'Set goals in the Goals tab and start a session timer when you play to track your progress.',
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch, size: 18),
                  SizedBox(width: 8),
                  Text('Go to Dashboard',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTip extends StatelessWidget {
  final String number;
  final String text;
  const _QuickTip({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _gold,
              )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: TextStyle(
                fontSize: 12,
                color: _cream.withValues(alpha: 0.7),
                height: 1.5,
              )),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SHARED STEP CONTAINER
// ═══════════════════════════════════════════════════════════════════

class _StepContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const _StepContainer({required this.child, this.maxWidth = 460});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: _brown,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _lightBrown.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
