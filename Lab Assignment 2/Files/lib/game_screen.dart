import 'dart:math';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'game_result.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();

  int secretNumber = Random().nextInt(100) + 1;
  int attempts = 0;
  String message = "Guess a number between 1 and 100";

  void _checkGuess() async {
    final guess = int.tryParse(_controller.text);
    if (guess == null) return;

    attempts++;

    String status;

    if (guess == secretNumber) {
      status = 'correct';
      message = "🎉 Correct!";

      await DatabaseHelper().insertResult(
        GameResult(
          secretNumber: secretNumber,
          guess: guess,
          status: status,
          attempts: attempts,
          timestamp: DateTime.now().toString(),
        ),
      );

      _showWinDialog();
    } else if (guess > secretNumber) {
      status = 'too_high';
      message = "Too High!";
    } else {
      status = 'too_low';
      message = "Too Low!";
    }

    setState(() {});
    _controller.clear();
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("You Won!", style: TextStyle(color: Colors.white)),
        content: Text(
          "You guessed in $attempts attempts",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text("Play Again"),
          )
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      secretNumber = Random().nextInt(100) + 1;
      attempts = 0;
      message = "Guess a number between 1 and 100";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("Game"),
        backgroundColor: AppTheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your guess",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _checkGuess,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: const Text("Guess"),
            ),
          ],
        ),
      ),
    );
  }
}