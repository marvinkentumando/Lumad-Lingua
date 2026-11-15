import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/duel_provider.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/lumad_background.dart';

class DuelLobbyScreen extends ConsumerStatefulWidget {
  const DuelLobbyScreen({super.key});

  @override
  ConsumerState<DuelLobbyScreen> createState() => _DuelLobbyScreenState();
}

class _DuelLobbyScreenState extends ConsumerState<DuelLobbyScreen> {
  bool _isSearching = false;

  Future<void> _startMatchmaking() async {
    setState(() => _isSearching = true);
    final user = ref.read(authStateProvider).value;
    final userName = user?.name ?? 'Lumad Learner';

    try {
      final service = ref.read(duelServiceProvider);
      final sessionId = await service.findOrCreateMatch(userName: userName);

      if (mounted) {
        setState(() => _isSearching = false);
        context.push('/arena/battle', extra: {'sessionId': sessionId});
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Matchmaking error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const ScreenHeader(
                  title: 'Lingua Duels Arena',
                  subtitle: 'Compete in real-time rapid-fire Mansaka vocabulary battles',
                ),
                const SizedBox(height: AppSpacing.lg),

                // Hero Arena Banner (With Dual-Tone Gold Gradient & 3D Shadow Lip)
                BrandCard(
                  backgroundColor: AppColors.gold500,
                  child: Column(
                    children: [
                      const Icon(Icons.flash_on, color: AppColors.forest900, size: 64),
                      const SizedBox(height: 8),
                      Text(
                        'PLAYER VS PLAYER ARENA',
                        style: AppTypography.h2ExtraBold.copyWith(
                          color: AppColors.forest900,
                          fontSize: 22,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Test your speed and knowledge in live rapid-fire Mansaka vocabulary and cultural trivia showdowns!',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.forest800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                if (_isSearching) ...[
                  const CircularProgressIndicator(color: AppColors.gold500)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 800.ms),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Searching for a rival learner in Mindanao...',
                    style: AppTypography.h3.copyWith(color: AppColors.creamText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Synchronizing real-time battle session...',
                    style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                  ),
                ] else ...[
                  // Rewards Summary Banner
                  BrandCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.gold500,
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                          child: const Icon(Icons.emoji_events, color: AppColors.forest900, size: 28),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Victory Rewards',
                                style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '+150 XP • +25 Crystals • Streak Credit',
                                style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  BrandButton(
                    text: 'Find Opponent & Enter Battle',
                    type: BrandButtonType.gold,
                    icon: Icons.sports_kabaddi,
                    onPressed: _startMatchmaking,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
