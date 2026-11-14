import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/duel_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_button.dart';

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
      appBar: AppBar(
        title: const Text('Lingua Duels Arena'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Arena Banner
              AppCard(
                backgroundColor: AppColors.gold500.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.gold500, width: 2),
                child: Column(
                  children: [
                    const Icon(Icons.flash_on, color: AppColors.gold500, size: 64),
                    const SizedBox(height: 8),
                    Text(
                      'LINGUA DUELS ARENA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Compete in real-time rapid-fire Mansaka vocabulary and cultural trivia battles!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.subtitleColor(context)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              if (_isSearching) ...[
                const CircularProgressIndicator(color: AppColors.gold500),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Searching for a rival learner in Mindanao...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Synchronizing real-time battle session...',
                  style: TextStyle(fontSize: 12, color: AppColors.subtitleColor(context)),
                ),
              ] else ...[
                // Rewards Summary
                AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: AppColors.gold500, size: 36),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Victory Rewards',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '+150 XP • +25 Crystals • Streak Credit',
                              style: TextStyle(fontSize: 13, color: AppColors.forestGreen, fontWeight: FontWeight.bold),
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
                  type: BrandButtonType.primary,
                  icon: Icons.sports_kabaddi,
                  onPressed: _startMatchmaking,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
