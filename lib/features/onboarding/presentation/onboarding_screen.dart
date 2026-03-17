import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../characters/domain/character_model.dart';
import '../../characters/presentation/providers/characters_provider.dart';
import 'providers/onboarding_provider.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  static const _totalSteps = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = useState(0);
    final rsnCtrl = useTextEditingController();
    final accountType = useState(CharacterType.main);
    final characterCreated = useState(false);

    Future<void> finishOnboarding() async {
      await ref.read(onboardingCompleteProvider.notifier).complete();
      if (context.mounted) context.go('/dashboard');
    }

    return Scaffold(
      backgroundColor: kDarkBrown,
      body: Column(
        children: [
          // ── Progress bar + Skip ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
              child: Row(
                children: [
                  // Step dots
                  for (int i = 0; i < _totalSteps; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: i <= step.value
                              ? kGold
                              : kLightBrown.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 16),
                  // Step label
                  Text(
                    '${step.value + 1} / $_totalSteps',
                    style: TextStyle(
                      fontSize: 11,
                      color: kCream.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Skip to Dashboard
                  if (step.value < _totalSteps - 1)
                    TextButton(
                      onPressed: finishOnboarding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Skip to Dashboard',
                        style: TextStyle(
                          fontSize: 11,
                          color: kCream.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // ── Step content ──
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _buildStep(
                  key: ValueKey(step.value),
                  ref: ref,
                  step: step,
                  rsnCtrl: rsnCtrl,
                  accountType: accountType,
                  characterCreated: characterCreated,
                  onFinish: finishOnboarding,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required Key key,
    required WidgetRef ref,
    required ValueNotifier<int> step,
    required TextEditingController rsnCtrl,
    required ValueNotifier<CharacterType> accountType,
    required ValueNotifier<bool> characterCreated,
    required Future<void> Function() onFinish,
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
          onBack: () => step.value = 0,
        );
      case 2:
        return _ReadyStep(
          key: key,
          onFinish: onFinish,
          onBack: () => step.value = 1,
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8C34A), kGold, Color(0xFF9E7A12)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFB8860B).withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: kGold.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.shield, color: Color(0xFF1E1408), size: 40),
                Icon(Icons.security, color: Color(0xFF1E1408), size: 34),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFD966), kGold, Color(0xFFFFD966)],
            ).createShader(bounds),
            child: const Text(
              'OSRS COMPANION',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your personal Old School RuneScape toolkit',
            style: TextStyle(
              fontSize: 13,
              color: kCream.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 28),

          // Compact feature list
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: kDarkBrown.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kLightBrown.withValues(alpha: 0.2)),
            ),
            child: const Column(
              children: [
                _FeatureRow(
                    icon: Icons.trending_up,
                    text: 'Track goals, sessions & progress'),
                SizedBox(height: 8),
                _FeatureRow(
                    icon: Icons.auto_awesome,
                    text: 'Personalized training recommendations'),
                SizedBox(height: 8),
                _FeatureRow(
                    icon: Icons.calculate,
                    text: 'Skill calcs, GE prices & wiki search'),
                SizedBox(height: 8),
                _FeatureRow(
                    icon: Icons.lock_outline,
                    text: 'Encrypted vault for account notes'),
              ],
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkGreen,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Get Started',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
        Icon(icon, size: 16, color: kGold.withValues(alpha: 0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 12, color: kCream.withValues(alpha: 0.7))),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STEP 1: ADD CHARACTER (streamlined)
// ═══════════════════════════════════════════════════════════════════

class _CharacterStep extends StatelessWidget {
  final TextEditingController rsnCtrl;
  final ValueNotifier<CharacterType> accountType;
  final ValueNotifier<bool> characterCreated;
  final VoidCallback onCreateCharacter;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _CharacterStep({
    super.key,
    required this.rsnCtrl,
    required this.accountType,
    required this.characterCreated,
    required this.onCreateCharacter,
    required this.onNext,
    required this.onBack,
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
                size: 40,
                color: created ? kGreen : kGold,
              ),
              const SizedBox(height: 12),
              Text(
                created ? 'Character Added!' : 'Add Your Character',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kGold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                created
                    ? 'You can add more characters later from the Characters page.'
                    : 'Enter your display name to look up stats and track progress.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: kCream.withValues(alpha: 0.55),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              if (!created) ...[
                // RSN input
                TextField(
                  controller: rsnCtrl,
                  decoration: InputDecoration(
                    labelText: 'Display Name (RSN)',
                    hintText: 'e.g. Zezima',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    filled: true,
                    fillColor: kDarkBrown.withValues(alpha: 0.8),
                  ),
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) {
                    if (rsnCtrl.text.trim().isNotEmpty) {
                      onCreateCharacter();
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Account type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Type',
                        style: TextStyle(
                          fontSize: 11,
                          color: kCream.withValues(alpha: 0.45),
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
                          CharacterType.hcgim,
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
                const SizedBox(height: 22),

                // Create button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        rsnCtrl.text.trim().isEmpty ? null : onCreateCharacter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Add Character',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 10),
                // Back + Skip row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: onBack,
                      child: Text('Back',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.35),
                          )),
                    ),
                    const SizedBox(width: 8),
                    Text('|',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.15))),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: onNext,
                      child: Text('Skip for now',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.35),
                          )),
                    ),
                  ],
                ),
              ] else ...[
                // Success state
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: kGreen, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rsnCtrl.text.trim(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: kCream,
                                )),
                            Text(accountType.value.displayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: kCream.withValues(alpha: 0.45),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkGreen,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? kDarkGreen : kMedBrown,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? kGreen : kLightBrown.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          type.displayName,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? kCream : kCream.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STEP 2: READY — quick tips + go
// ═══════════════════════════════════════════════════════════════════

class _ReadyStep extends StatelessWidget {
  final Future<void> Function() onFinish;
  final VoidCallback onBack;
  const _ReadyStep({super.key, required this.onFinish, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return _StepContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border:
                  Border.all(color: kGreen.withValues(alpha: 0.4), width: 2),
            ),
            child: const Icon(Icons.check_rounded, size: 36, color: kGreen),
          ),
          const SizedBox(height: 20),
          const Text(
            "You're All Set!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quick tips to get the most out of the app:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: kCream.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 20),

          // Compact tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kDarkBrown.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kLightBrown.withValues(alpha: 0.2)),
            ),
            child: const Column(
              children: [
                _QuickTip(
                  icon: Icons.person_search,
                  text: 'Characters → "Lookup Stats" to pull your live levels.',
                ),
                SizedBox(height: 10),
                _QuickTip(
                  icon: Icons.route,
                  text: 'Goal Planner generates a personalized training plan.',
                ),
                SizedBox(height: 10),
                _QuickTip(
                  icon: Icons.inventory_2,
                  text:
                      'Import your bank in BiS Gear → Bank for smarter recommendations.',
                ),
                SizedBox(height: 10),
                _QuickTip(
                  icon: Icons.timer,
                  text:
                      'Start a session timer when you play to track XP gains.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkGreen,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch, size: 18),
                  SizedBox(width: 8),
                  Text('Go to Dashboard',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onBack,
            child: Text('Back',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.3),
                )),
          ),
        ],
      ),
    );
  }
}

class _QuickTip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _QuickTip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: kGold.withValues(alpha: 0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(
                fontSize: 12,
                color: kCream.withValues(alpha: 0.65),
                height: 1.4,
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
  const _StepContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: kBrown,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kLightBrown.withValues(alpha: 0.5)),
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
