// main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      home: const CounterApp(),
    );
  }
}

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int counter = 0;

  void increment() => setState(() => counter++);
  void decrement() => setState(() => counter--);
  void reset() => setState(() => counter = 0);

  @override
  Widget build(BuildContext context) {
    // Dynamic color logic: Blue for positive, Red for negative, Grey for zero
    Color displayColor;
    if (counter > 0) {
      displayColor = Colors.indigo;
    } else if (counter < 0) {
      displayColor = Colors.redAccent;
    } else {
      displayColor = Colors.grey;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey-blue background
      appBar: AppBar(
        title: const Text(
          'Counter App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Current Count',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  Text(
                    '$counter',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      color: displayColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement Button
                _buildActionButton(
                  icon: Icons.remove,
                  color: Colors.red.shade400,
                  onPressed: decrement,
                ),
                const SizedBox(width: 20),
                // Reset Button
                _buildActionButton(
                  icon: Icons.refresh,
                  color: Colors.orange.shade400,
                  onPressed: reset,
                ),
                const SizedBox(width: 20),
                // Increment Button
                _buildActionButton(
                  icon: Icons.add,
                  color: Colors.green.shade400,
                  onPressed: increment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to keep the UI code clean
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        elevation: 4,
      ),
      child: Icon(icon, size: 30),
    );
  }
}
