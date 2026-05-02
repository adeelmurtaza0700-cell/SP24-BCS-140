import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import 'database_helper.dart';
import 'game_result.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnim;
  late Animation<double> _shakeAnim;

  int _secretNumber = 0;
  int _attempts = 0;
  int _maxRange = 100;
  int _maxAttempts = 10;
  List<int> _guessHistory = [];
  String _gameStartTime = '';
  bool _gameOver = false;

  final List<Map<String, dynamic>> _difficulties = [
    {'label': 'Easy', 'range': 50, 'attempts': 10, 'color': AppTheme.accent},
    {'label': 'Medium', 'range': 100, 'attempts': 10, 'color': AppTheme.primary},
    {'label': 'Hard', 'range': 200, 'attempts': 8, 'color': AppTheme.secondary},
  ];
  int _selectedDifficulty = 1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeController);
    _startNewGame();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      _maxRange = _difficulties[_selectedDifficulty]['range'];
      _maxAttempts = _difficulties[_selectedDifficulty]['attempts'];
      _secretNumber = Random().nextInt(_maxRange) + 1;
      _attempts = 0;
      _guessHistory = [];
      _gameOver = false;
      _gameStartTime = DateTime.now().toIso8601String();
      _controller.clear();
    });
  }

  Future<void> _submitGuess() async {
    if (_gameOver) return;
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward(from: 0);
      return;
    }

    final guess = int.parse(_controller.text.trim());
    _attempts++;
    _guessHistory.add(guess);

    String status;
    if (guess == _secretNumber) {
      status = 'correct';
    } else if (guess > _secretNumber) {
      status = 'too_high';
    } else {
      status = 'too_low';
    }

    // Save to SQLite
    await DatabaseHelper().insertResult(GameResult(
      secretNumber: _secretNumber,
      guess: guess,
      status: status,
      attempts: _attempts,
      timestamp: _gameStartTime,
    ));

    _controller.clear();

    if (status == 'correct' || _attempts >= _maxAttempts) {
      setState(() => _gameOver = true);
    }

    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, b) => ResultScreen(
            guess: guess,
            status: status,
            secretNumber: _secretNumber,
            attempts: _attempts,
            maxAttempts: _maxAttempts,
            guessHistory: List.from(_guessHistory),
            onPlayAgain: () {
              Navigator.pop(context);
              _startNewGame();
            },
            onContinue: status != 'correct' && _attempts < _maxAttempts
                ? () => Navigator.pop(context)
                : null,
          ),
          transitionsBuilder: (_, a, b, child) => FadeTransition(opacity: a, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final attemptsLeft = _maxAttempts - _attempts;
    final progress = _attempts / _maxAttempts;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Number Guesser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            tooltip: 'History',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildDifficultyRow(),
                const SizedBox(height: 24),
                _buildSecretNumberCard(),
                const SizedBox(height: 24),
                _buildStatsRow(attemptsLeft, progress),
                const SizedBox(height: 24),
                _buildGuessInput(),
                const SizedBox(height: 20),
                _buildGuessHistory(),
                const SizedBox(height: 20),
                _buildNewGameButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyRow() {
    return Row(
      children: _difficulties.asMap().entries.map((e) {
        final i = e.key;
        final d = e.value;
        final isSelected = i == _selectedDifficulty;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedDifficulty = i);
              _startNewGame();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(
                left: i == 0 ? 0 : 4,
                right: i == 2 ? 0 : 4,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [d['color'], d['color'].withOpacity(0.6)])
                    : null,
                color: isSelected ? null : AppTheme.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? d['color'] : Colors.white12,
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Text(d['label'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      )),
                  Text('1–${d['range']}',
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : AppTheme.textSecondary,
                        fontSize: 11,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSecretNumberCard() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3A3580)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              'Guess the Number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Between 1 and $_maxRange',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(int attemptsLeft, double progress) {
    return Row(
      children: [
        _statCard('Attempts Left', '$attemptsLeft', Icons.timer_outlined,
            attemptsLeft <= 3 ? AppTheme.secondary : AppTheme.accent),
        const SizedBox(width: 12),
        _statCard('Total Guesses', '$_attempts', Icons.touch_app_outlined, AppTheme.primary),
        const SizedBox(width: 12),
        _statCard('Range', '1–$_maxRange', Icons.tune_outlined, const Color(0xFF4FACFE)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildGuessInput() {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) {
        final shake = sin(_shakeAnim.value * pi * 6) * 10;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !_gameOver,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '?',
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 28),
                filled: true,
                fillColor: AppTheme.bgCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.4), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.secondary, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter a number';
                final n = int.tryParse(v);
                if (n == null) return 'Invalid number';
                if (n < 1 || n > _maxRange) return 'Enter between 1 and $_maxRange';
                if (_guessHistory.contains(n)) return 'Already guessed $n!';
                return null;
              },
              onFieldSubmitted: (_) => _submitGuess(),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _gameOver
                      ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                      : AppTheme.buttonGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _gameOver
                      ? []
                      : [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: ElevatedButton(
                  onPressed: _gameOver ? null : _submitGuess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        _gameOver ? 'Game Over' : 'Submit Guess',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuessHistory() {
    if (_guessHistory.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Guesses',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _guessHistory.reversed.map((g) {
            Color chipColor;
            IconData chipIcon;
            if (g == _secretNumber) {
              chipColor = AppTheme.accent;
              chipIcon = Icons.check_circle_outline;
            } else if (g > _secretNumber) {
              chipColor = AppTheme.secondary;
              chipIcon = Icons.arrow_downward_rounded;
            } else {
              chipColor = const Color(0xFF4FACFE);
              chipIcon = Icons.arrow_upward_rounded;
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: chipColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: chipColor.withOpacity(0.4), width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(chipIcon, color: chipColor, size: 14),
                  const SizedBox(width: 4),
                  Text('$g', style: TextStyle(color: chipColor, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNewGameButton() {
    return TextButton.icon(
      onPressed: _startNewGame,
      icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary, size: 18),
      label: const Text('New Game', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    );
  }
}