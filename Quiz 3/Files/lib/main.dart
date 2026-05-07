import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Replace with your actual credentials
  await Supabase.initialize(
    url: 'https://imivfqvuajvnevsnoetc.supabase.co',
    anonKey: 'sb_publishable_GxcR-e0CQldp6bP1_XsFuQ_Chc0T8Lp',
  );

  runApp(const SubmissionProApp());
}

class SubmissionProApp extends StatelessWidget {
  const SubmissionProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Submission Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Surface
        primaryColor: const Color(0xFF3ECF8E), // Accent
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3ECF8E),
          secondary: Color(0xFF3ECF8E),
          surface: Color(0xFF1E293B),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            fontSize: 72,
            letterSpacing: -4,
            fontStyle: FontStyle.italic,
          ),
          headlineLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -1,
          ),
          bodyMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          labelSmall: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 2,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
