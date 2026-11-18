import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/duel_provider.dart';
import '../../models/duel_model.dart';
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
  StreamSubscription<DuelSessionModel?>? _sessionSubscription;
  String? _currentWaitingSessionId;

  @override
  void dispose() {
    _searchTimer?.cancel();
    _sessionSubscription?.cancel();
    _cleanupWaitingSession();
    super.dispose();
  }

  Future<void> _cleanupWaitingSession() async {
    if (_currentWaitingSessionId != null) {
      final sessionId = _currentWaitingSessionId!;
      _currentWaitingSessionId = null;
      try {
        final service = ref.read(duelServiceProvider);
        await service.cancelWaitingSession(sessionId);
      } catch (_) {}
    }
  }

  void _cancelMatchmaking() {
    _searchTimer?.cancel();
    _sessionSubscription?.cancel();
    _cleanupWaitingSession();
    if (mounted) {
      setState(() {
        _isSearching = false;
        _searchTimeLeft = 20;
      });
    }
  }

  Future<void> _startMatchmaking() async {
    _cancelMatchmaking();

    setState(() {
      _isSearching = true;
      _searchTimeLeft = 20;
    });

    final user = ref.read(authStateProvider).value;
    final userName = user?.name ?? 'Lumad Learner';
    final service = ref.read(duelServiceProvider);

    try {
      // 1. First check if another human player is already waiting
      final existingSessionId = await service.findExistingHumanMatch(userName: userName);
      if (existingSessionId != null && mounted) {
        setState(() => _isSearching = false);
        context.push('/arena/battle', extra: {'sessionId': existingSessionId});
        return;
      }

      // 2. Create a waiting session for this user
      final sessionId = await service.createWaitingSession(userName: userName);
      _currentWaitingSessionId = sessionId;

      // 3. Listen to live updates on this waiting session
      _sessionSubscription = service.watchDuelSession(sessionId).listen((session) {
        if (session != null && session.status == 'active' && session.player2Id != null && session.player2Id != 'bot_ai') {
          _searchTimer?.cancel();
          _sessionSubscription?.cancel();
          _currentWaitingSessionId = null;
          if (mounted) {
            setState(() => _isSearching = false);
            context.push('/arena/battle', extra: {'sessionId': session.id});
          }
        }
      });

      // 4. Start 20-second countdown timer
      _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_searchTimeLeft > 1) {
          setState(() => _searchTimeLeft--);
        } else {
          timer.cancel();
          _onMatchmakingTimeout();
        }
      });
    } catch (e) {
      _cancelMatchmaking();
    }
  }

  Future<void> _onMatchmakingTimeout() async {
    _searchTimer?.cancel();
    _sessionSubscription?.cancel();
    await _cleanupWaitingSession();

    if (mounted) {
      setState(() => _isSearching = false);
      _showNoOpponentDialog();
    }
  }

  void _showNoOpponentDialog() {
    final user = ref.read(authStateProvider).value;
    final userName = user?.name ?? 'Lumad Learner';
    final service = ref.read(duelServiceProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.modal)),
        title: Row(
          children: [
            const Icon(Icons.group_off, color: AppColors.gold500, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No Opponent Found',
                style: AppTypography.h3.copyWith(color: AppColors.textColor(context)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No active human players connected within 20 seconds.',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textColor(context)),
            ),
            const SizedBox(height: 8),
            Text(
              'Would you like to battle against the AI Rival (Bot) or try searching again?',
              style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
            ),
          ],
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BrandButton(
                text: 'Play against AI Rival (Bot)',
                icon: Icons.smart_toy,
                type: BrandButtonType.gold,
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  try {
                    final botSessionId = await service.createBotMatch(userName: userName);
                    if (mounted) {
                      context.push('/arena/battle', extra: {'sessionId': botSessionId});
                    }
                  } catch (_) {}
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              BrandButton(
                text: 'Search Again (20s)',
                icon: Icons.refresh,
                type: BrandButtonType.secondary,
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _startMatchmaking();
                },
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context))),
              ),
            ],
          ),
        ],
      ),
    );
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gold500.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold500),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, color: AppColors.gold400, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Countdown: 00:${_searchTimeLeft.toString().padLeft(2, '0')}',
                          style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Searching live human opponents for 20 seconds...',
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
