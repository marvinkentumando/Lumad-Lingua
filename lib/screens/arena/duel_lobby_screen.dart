import 'dart:async';
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
  int _searchTimeLeft = 20;
  Timer? _searchTimer;

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  void _cancelMatchmaking() {
    _searchTimer?.cancel();
    if (mounted) {
      setState(() {
        _isSearching = false;
        _searchTimeLeft = 20;
      });
    }
  }

  Future<void> _startMatchmaking() async {
    setState(() {
      _isSearching = true;
      _searchTimeLeft = 20;
    });

    final user = ref.read(authStateProvider).value;
    final userName = user?.name ?? 'Lumad Learner';
    final service = ref.read(duelServiceProvider);

    _searchTimer?.cancel();
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_searchTimeLeft > 1) {
        setState(() => _searchTimeLeft--);
      } else {
        timer.cancel();
        // 20-second timeout elapsed -> Fallback to instant AI Bot Match
        try {
          final botSessionId = await service.createBotMatch(userName: userName);
          if (mounted) {
            setState(() => _isSearching = false);
            context.push('/arena/battle', extra: {'sessionId': botSessionId});
          }
        } catch (e) {
          _cancelMatchmaking();
        }
      }
    });

    try {
      final sessionId = await service.findOrCreateMatch(userName: userName);

      if (mounted && _isSearching) {
        _searchTimer?.cancel();
        setState(() => _isSearching = false);
        context.push('/arena/battle', extra: {'sessionId': sessionId});
      }
    } catch (e) {
      // Don't interrupt countdown; let timer complete or fallback
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

                // Hero Arena Banner
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold500.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold500),
                    ),
                    child: Text(
                      'Matchmaking Countdown: 00:${_searchTimeLeft.toString().padLeft(2, '0')}',
                      style: AppTypography.labelBold.copyWith(color: AppColors.gold400),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Auto-matching AI Rival if no human opponent connects',
                    style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BrandButton(
                    text: 'Cancel Search',
                    type: BrandButtonType.secondary,
                    onPressed: _cancelMatchmaking,
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
