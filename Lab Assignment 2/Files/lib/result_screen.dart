import 'dart:math';
import 'package:flutter/material.dart';
import 'app_theme.dart';

class ResultScreen extends StatefulWidget {
  final int guess;
  final String status;
  final int secretNumber;
  final int attempts;
  final int maxAttempts;
  final List<int> guessHistory;
  final VoidCallback onPlayAgain;
  final VoidCallback? onContinue;

  const ResultScreen({
    super.key,
    required this.guess,
    required this.status,
    required this.secretNumber,
    required this.attempts,
    required this.maxAttempts,
    required this.guessHistory,
    required this.onPlayAgain,
    this.onContinue,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _bounceAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnim = CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _bounceController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.status == 'correct';
    final isTooHigh = widget.status == 'too_high';
    final isGameOver = widget.attempts >= widget.maxAttempts && !isCorrect;

    final gradient = isCorrect
        ? AppTheme.correctGradient
        : isTooHigh
            ? AppTheme.highGradient
            : AppTheme.lowGradient;

    final emoji = isGameOver
        ? '😞'
        : isCorrect
            ? '🎉'
            : isTooHigh
                ? '🔥'
                : '❄️';

    final title = isGameOver
        ? 'Game Over!'
        : isCorrect
            ? 'Nailed It!'
            : isTooHigh
                ? 'Too High!'
                : 'Too Low!';

    final subtitle = isGameOver
        ? 'The number was ${widget.secretNumber}'
        : isCorrect
            ? 'You got it in ${widget.attempts} ${widget.attempts == 1 ? "try" : "tries"}!'
            : isTooHigh
                ? 'Try a smaller number'
                : 'Try a larger number';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Result'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _bounceAnim,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: (isCorrect ? AppTheme.accent : isTooHigh ? AppTheme.secondary : const Color(0xFF4FACFE))
                              .withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 64)),
                        const SizedBox(height: 12),
                        Text(title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            )),
                        const SizedBox(height: 8),
                        Text(subtitle,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center),
                        if (isCorrect || isGameOver) ...[
                          const SizedBox(height: 20),
                          _buildScoreBoard(),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildGuessCompass(),
                ),
                const Spacer(),
                _buildButtons(isCorrect, isGameOver),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _scoreItem('Your Guess', '${widget.guess}'),
          _scoreItem('Secret', '${widget.secretNumber}'),
          _scoreItem('Tries', '${widget.attempts}/${widget.maxAttempts}'),
        ],
      ),
    );
  }

  Widget _scoreItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildGuessCompass() {
    if (widget.status == 'correct' || widget.attempts >= widget.maxAttempts) {
      return const SizedBox.shrink();
    }
    final isTooHigh = widget.status == 'too_high';
    final remaining = widget.maxAttempts - widget.attempts;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            isTooHigh ? '⬇  Go Lower' : '⬆  Go Higher',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.repeat_rounded, color: AppTheme.textSecondary, size: 16),
              const SizedBox(width: 6),
              Text('$remaining ${remaining == 1 ? "attempt" : "attempts"} remaining',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: widget.attempts / widget.maxAttempts,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
                remaining <= 3 ? AppTheme.secondary : AppTheme.primary),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(bool isCorrect, bool isGameOver) {
    return Column(
      children: [
        if (widget.onContinue != null && !isCorrect && !isGameOver)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Continue Guessing',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        if (widget.onContinue != null && !isCorrect && !isGameOver) const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: widget.onPlayAgain,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24, width: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh_rounded, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  isCorrect || isGameOver ? 'Play Again' : 'New Game',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}