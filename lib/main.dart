import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

/// Entry point of the application.
void main() {
  runApp(const MealExplorerApp());
}

/// Root widget of the Recipe Browser application.
/// 
/// Configures a premium Material 3 design system including:
/// - Vibrant, food-themed color scheme.
/// - Consistent corner radius strategy.
/// - Modern typography scaling.
class MealExplorerApp extends StatelessWidget {
  const MealExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Browser',
      debugShowCheckedModeBanner: false,

      // --- Premium Material 3 Theme ---
      theme: ThemeData(
        useMaterial3: true,
        
        // Deep Orange/Amber palette — warm and appetizing for food apps
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57C00), 
          brightness: Brightness.light,
          surface: const Color(0xFFFFF8F1), // Slight warm tint for background
        ),

        // Modern, readable typography scaling
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
          headlineSmall: TextStyle(fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
        ),

        // Globally consistent AppBar styling
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 3,
          backgroundColor: Color(0xFFFFF8F1),
          surfaceTintColor: Colors.transparent,
        ),

        // Globally consistent Card styling
        cardTheme: CardThemeData(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0x1A000000)), // Subtle border
          ),
        ),

        // Styling for chips (category/area tags)
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
      ),

      home: const HomeScreen(),
    );
  }
}
