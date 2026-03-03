import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DiceApp());
}

class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dice Roller',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
      ),
      home: const DiceHomePage(),
    );
  }
}

class DiceHomePage extends StatefulWidget {
  const DiceHomePage({super.key});

  @override
  State<DiceHomePage> createState() => _DiceHomePageState();
}

class _DiceHomePageState extends State<DiceHomePage>
    with TickerProviderStateMixin {
  static const Color _bg = Color(0xFF0F0C1D);
  static const Color _surface = Color(0xFF1A1630);
  static const Color _card = Color(0xFF231F3D);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFF9D6EFF);
  static const Color _pink = Color(0xFFEC4899);
  static const Color _gold = Color(0xFFFFD700);
  static const Color _green = Color(0xFF10B981);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF9CA3AF);

  int _diceNumber = 1;
  bool _isRolling = false;
  int _totalScore = 0;
  int _rollCount = 0;
  int _bonusCount = 0;
  List<Map<String, dynamic>> _rollHistory = [];

  late AnimationController _diceController;
  late AnimationController _glowController;
  late AnimationController _bonusController;
  late Animation<double> _rotateAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _bonusScaleAnim;

  bool _showBonus = false;

  @override
  void initState() {
    super.initState();

    _diceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _bonusController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotateAnim = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.easeInOut),
    );
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 0.9), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _diceController, curve: Curves.easeInOut));
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(_glowController);
    _bonusScaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bonusController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _diceController.dispose();
    _glowController.dispose();
    _bonusController.dispose();
    super.dispose();
  }

  Future<void> _onRollPressed() async {
    if (_isRolling) return;
    final guess = await _showGuessDialog();
    if (guess == null) return;
    await _rollDice(guess);
  }

  Future<int?> _showGuessDialog() async {
    int? selectedGuess;
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1A3A), Color(0xFF2D2850)],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _purple.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_purple, _pink],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.psychology_rounded,
                        color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Make Your Guess!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick a number before the dice rolls.\nGuess right and earn a bonus!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (i) {
                      final num = i + 1;
                      final isSelected = selectedGuess == num;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setDialogState(() => selectedGuess = num);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [_purple, _pink],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : _surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? _purpleLight
                                  : _textSecondary.withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _purple.withOpacity(0.5),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              '$num',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : _textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(null),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: _surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _textSecondary.withOpacity(0.2),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: selectedGuess == null
                              ? null
                              : () => Navigator.of(ctx).pop(selectedGuess),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: selectedGuess != null
                                  ? const LinearGradient(
                                      colors: [_purple, _pink],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    )
                                  : null,
                              color: selectedGuess == null
                                  ? _textSecondary.withOpacity(0.2)
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: selectedGuess != null
                                  ? [
                                      BoxShadow(
                                        color: _purple.withOpacity(0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.casino_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Roll the Dice!',
                                    style: TextStyle(
                                      color: selectedGuess != null
                                          ? Colors.white
                                          : _textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _rollDice(int guess) async {
    setState(() {
      _isRolling = true;
      _showBonus = false;
    });

    HapticFeedback.mediumImpact();

    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          _diceNumber = Random().nextInt(6) + 1;
        });
      });
    }

    await _diceController.forward(from: 0);

    final result = Random().nextInt(6) + 1;
    setState(() {
      _diceNumber = result;
      _rollCount++;
      _totalScore += result;
    });

    await _diceController.reverse();

    setState(() => _isRolling = false);

    final isBonus = guess == result;

    _rollHistory.insert(0, {
      'number': result,
      'guess': guess,
      'bonus': isBonus,
    });
    if (_rollHistory.length > 5) _rollHistory = _rollHistory.sublist(0, 5);

    if (isBonus) {
      _bonusCount++;
      setState(() => _showBonus = true);
      HapticFeedback.heavyImpact();
      _bonusController.forward(from: 0);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _showBonus = false);
    }

    _showResultDialog(result, guess, isBonus);
  }

  void _showResultDialog(int result, int guess, bool isBonus) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isBonus
                    ? [const Color(0xFF1A2A1A), const Color(0xFF2A3A2A)]
                    : [const Color(0xFF1E1A3A), const Color(0xFF2D2850)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isBonus
                    ? _gold.withOpacity(0.5)
                    : _purple.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isBonus
                      ? _gold.withOpacity(0.3)
                      : _purple.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBonus)
                  Column(
                    children: [
                      const Text(
                        '🎉 BONUS!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: _gold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _gold.withOpacity(0.4)),
                        ),
                        child: const Text(
                          '+50 Bonus Points!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _gold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isBonus
                          ? [_gold, const Color(0xFFFF8C00)]
                          : [_purple, _pink],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: (isBonus ? _gold : _purple).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$result',
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isBonus ? 'Amazing! You guessed it!' : 'Dice Result',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isBonus ? _gold : _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (!isBonus)
                  Text(
                    'You guessed $guess, but rolled $result.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                if (isBonus)
                  Text(
                    'You guessed $guess and rolled $guess. Perfect!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: _green,
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isBonus
                            ? [_gold, const Color(0xFFFF8C00)]
                            : [_purple, _pink],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isBonus ? _gold : _purple).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Got it!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _diceNumber = 1;
      _totalScore = 0;
      _rollCount = 0;
      _bonusCount = 0;
      _rollHistory.clear();
      _showBonus = false;
    });
    HapticFeedback.mediumImpact();
  }

  Widget _buildDiceFace(int number) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D2850), Color(0xFF1A1630)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _purple.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: _pink.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: _buildDots(number),
      ),
    );
  }

  Widget _buildDots(int number) {
    const dotColor = Colors.white;
    const dotSize = 20.0;

    Widget dot({bool visible = true}) => Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: visible ? dotColor : Colors.transparent,
            boxShadow: visible
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
        );

    Widget row(List<bool> visible) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: visible.map((v) => dot(visible: v)).toList(),
        );

    switch (number) {
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [dot()])
          ],
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [dot()]),
            Row(mainAxisAlignment: MainAxisAlignment.start,
                children: [dot()]),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [dot()]),
            Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [dot()]),
            Row(mainAxisAlignment: MainAxisAlignment.start,
                children: [dot()]),
          ],
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            row([true, true]),
            row([true, true]),
          ],
        );
      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            row([true, true]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [dot()]),
            row([true, true]),
          ],
        );
      case 6:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            row([true, true]),
            row([true, true]),
            row([true, true]),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, __) => Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _purple.withOpacity(0.06 * _glowAnim.value),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pink.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTopBar(),
                  const SizedBox(height: 28),
                  _buildStatsRow(),
                  const SizedBox(height: 36),
                  _buildDiceSection(),
                  const SizedBox(height: 36),
                  _buildRollButton(),
                  const SizedBox(height: 28),
                  if (_rollHistory.isNotEmpty) _buildHistory(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          if (_showBonus) _buildBonusOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dice Roller',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: _textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [_purple, _pink],
              ).createShader(bounds),
              child: const Text(
                'Roll & Guess to Win!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _resetGame,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _purple.withOpacity(0.3)),
            ),
            child: const Icon(Icons.refresh_rounded,
                color: _purpleLight, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('Rolls', '$_rollCount', Icons.casino_rounded, _purple),
        const SizedBox(width: 12),
        _buildStatCard(
            'Total', '$_totalScore', Icons.bar_chart_rounded, _pink),
        const SizedBox(width: 12),
        _buildStatCard(
            'Bonus', '$_bonusCount', Icons.star_rounded, _gold),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: _textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiceSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_diceController, _glowController]),
          builder: (_, __) {
            return Transform.rotate(
              angle: _isRolling ? _rotateAnim.value * 0.3 : 0,
              child: Transform.scale(
                scale: _isRolling ? _scaleAnim.value : 1.0,
                child: _buildDiceFace(_diceNumber),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            color: _purple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _purple.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.casino_rounded, color: _purpleLight, size: 18),
              const SizedBox(width: 8),
              Text(
                _isRolling ? 'Rolling...' : 'You rolled: $_diceNumber',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _purpleLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRollButton() {
    return GestureDetector(
      onTap: _isRolling ? null : _onRollPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          gradient: _isRolling
              ? LinearGradient(
                  colors: [
                    _purple.withOpacity(0.4),
                    _pink.withOpacity(0.4)
                  ],
                )
              : const LinearGradient(
                  colors: [_purple, _pink],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isRolling
              ? []
              : [
                  BoxShadow(
                    color: _purple.withOpacity(0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.casino_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              _isRolling ? 'Rolling...' : 'Roll the Dice',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Rolls',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._rollHistory.asMap().entries.map((entry) {
          final i = entry.key;
          final roll = entry.value;
          final isBonus = roll['bonus'] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isBonus
                    ? _gold.withOpacity(0.4)
                    : _purple.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isBonus ? _gold : _purple).withOpacity(0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isBonus
                          ? [_gold, const Color(0xFFFF8C00)]
                          : [_purple, _pink],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${roll['number']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i == 0 ? 'Latest Roll' : 'Roll #${_rollHistory.length - i}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                      Text(
                        'Guessed: ${roll['guess']}  •  Rolled: ${roll['number']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isBonus)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _gold.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'BONUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _gold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBonusOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: ScaleTransition(
            scale: _bonusScaleAnim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2A1A), Color(0xFF2A3A2A)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _gold.withOpacity(0.6), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  const Text(
                    'BONUS EARNED!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _gold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '+50 Points!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
