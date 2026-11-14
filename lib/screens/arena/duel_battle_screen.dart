import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../models/duel_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/duel_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_button.dart';

class DuelBattleScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const DuelBattleScreen({super.key, required this.sessionId});

  @override
  ConsumerState<DuelBattleScreen> createState() => _DuelBattleScreenState();
}

class _DuelBattleScreenState extends ConsumerState<DuelBattleScreen> {
  Timer? _timer;
  int _timeLeft = 10;
  int _startTimeMs = 0;
  bool _hasAnswered = false;
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    _startRoundTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRoundTimer() {
    _timer?.cancel();
    _timeLeft = 10;
    _hasAnswered = false;
    _selectedOption = null;
    _startTimeMs = DateTime.now().millisecondsSinceEpoch;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft > 1) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        if (!_hasAnswered) {
          _submitAnswer(-1, false); // Time out
        }
      }
    });
  }

  Future<void> _submitAnswer(int optionIndex, bool isCorrect) async {
    if (_hasAnswered) return;

    _timer?.cancel();
    HapticFeedback.mediumImpact();

    final responseTimeMs = DateTime.now().millisecondsSinceEpoch - _startTimeMs;

    setState(() {
      _hasAnswered = true;
      _selectedOption = optionIndex;
    });

    final service = ref.read(duelServiceProvider);
    final user = ref.read(authStateProvider).value;
    final session = ref.read(duelSessionStreamProvider(widget.sessionId)).value;

    final isPlayer1 = session?.player1Id == user?.id;
    final currentRound = session?.currentRound ?? 0;

    await service.submitRoundAnswer(
      sessionId: widget.sessionId,
      isPlayer1: isPlayer1,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
      currentRound: currentRound,
    );

    // Pause 1.5s then advance or conclude
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (currentRound + 1 >= (session?.questions.length ?? 5)) {
      _finishMatch(session, isPlayer1);
    } else {
      _startRoundTimer();
    }
  }

  Future<void> _finishMatch(DuelSessionModel? session, bool isPlayer1) async {
    final user = ref.read(authStateProvider).value;
    final myScore = isPlayer1 ? (session?.player1Score ?? 0) : (session?.player2Score ?? 0);
    final rivalScore = isPlayer1 ? (session?.player2Score ?? 0) : (session?.player1Score ?? 0);

    final isWinner = myScore >= rivalScore;
    final winnerId = isWinner ? (user?.id ?? 'me') : (session?.player2Id ?? 'rival');

    final service = ref.read(duelServiceProvider);
    await service.completeMatch(sessionId: widget.sessionId, winnerId: winnerId);

    if (isWinner && user != null) {
      final authNotifier = ref.read(authStateProvider.notifier);
      authNotifier.addXp(150);
      authNotifier.updateCrystals(user.crystals + 25);
    }

    if (mounted) {
      HapticFeedback.heavyImpact();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  color: isWinner ? AppColors.gold500 : Colors.grey, size: 32),
              const SizedBox(width: 8),
              Text(isWinner ? 'VICTORY!' : 'DEFEAT'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isWinner
                    ? 'Congratulations! You dominated the Arena and preserved the Mansaka heritage!'
                    : 'Good effort! Review vocabulary and challenge your rival again.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gold500.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold500),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Your Score:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$myScore pts', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestGreen)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rival Score:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$rivalScore pts', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                    if (isWinner) ...[
                      const Divider(),
                      const Text(
                        'Rewards: +150 XP • +25 Crystals 💎',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold500, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            BrandButton(
              text: 'Return to Home',
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(duelSessionStreamProvider(widget.sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle Arena'),
        automaticallyImplyLeading: false,
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session == null) {
            return const Center(child: Text('Session not found.'));
          }

          final user = ref.watch(authStateProvider).value;
          final isPlayer1 = session.player1Id == user?.id;

          final myName = isPlayer1 ? session.player1Name : (session.player2Name ?? 'You');
          final myHp = isPlayer1 ? session.player1Hp : session.player2Hp;
          final myScore = isPlayer1 ? session.player1Score : session.player2Score;

          final rivalName = isPlayer1 ? (session.player2Name ?? 'Rival Learner') : session.player1Name;
          final rivalHp = isPlayer1 ? session.player2Hp : session.player1Hp;
          final rivalScore = isPlayer1 ? session.player2Score : session.player1Score;

          final currentRound = session.currentRound.clamp(0, session.questions.isEmpty ? 0 : session.questions.length - 1);
          final question = session.questions.isNotEmpty ? session.questions[currentRound] : null;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Health & Score Header
                  Row(
                    children: [
                      // Player 1 (You)
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(myName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: myHp / 100,
                                backgroundColor: AppColors.progressTrack,
                                color: AppColors.semanticGreen,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 4),
                              Text('$myScore pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gold500)),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.coralRed)),
                      ),
                      // Player 2 (Rival)
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(rivalName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: rivalHp / 100,
                                backgroundColor: AppColors.progressTrack,
                                color: AppColors.coralRed,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 4),
                              Text('$rivalScore pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gold500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Round Timer & Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Round ${currentRound + 1} of ${session.questions.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _timeLeft <= 3 ? AppColors.semanticRed : AppColors.gold500,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          '00:${_timeLeft.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Trivia Question Card
                  if (question != null) ...[
                    AppCard(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                              question.questionText,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColor(context)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Options Grid/List
                    Expanded(
                      child: ListView.separated(
                        itemCount: question.options.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final option = question.options[index];
                          final isCorrect = index == question.correctOptionIndex;
                          final isSelected = _selectedOption == index;

                          Color optionColor = AppColors.cardColor(context);
                          if (_hasAnswered) {
                            if (isSelected) {
                              optionColor = isCorrect ? AppColors.semanticGreen : AppColors.semanticRed;
                            } else if (isCorrect) {
                              optionColor = AppColors.semanticGreen.withValues(alpha: 0.3);
                            }
                          }

                          return InkWell(
                            onTap: _hasAnswered ? null : () => _submitAnswer(index, isCorrect),
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: optionColor,
                                borderRadius: BorderRadius.circular(AppRadius.card),
                                border: Border.all(
                                  color: isSelected ? AppColors.gold500 : AppColors.border,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _hasAnswered && isSelected ? Colors.white : AppColors.textColor(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Battle stream error: $e')),
      ),
    );
  }
}
