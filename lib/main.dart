import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/sudoku_provider.dart';
import 'screens/loading_screen.dart'; // <-- Use landing screen as initial screen
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SudokuProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<SudokuProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudoku Trainer',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      // Start with LandingScreen
      // navigatorKey: navigatorKey,
      home: const LandingScreen(),
    );
  }
}

/*
so i am building a sukodu trainer flutter app where in i have multiple screen

I have implemented 2 strategies as of now which are a beginner friendly strategies that teaches the user how to start playing sukoku.

initially there is splash screen followed by the rules_screen that has the rules for playing sudoku. We then have difficulty screen that has 3 buttons of 'Easy', 'Medium' and 'Hard'.

Then we have to select strategy that we want to learn(right now its only _findHiddenSingle and _findNakedSingle .

once we select the strategy a board is generated that has the board where the selected strategy can be used the most.

The UI is great and responsive. It also has the popping ai msg box that gives u messages based on the move you play.

if it is wrong/right/neutral move accordingly those messages are popped. It also give alert if u violate the mentioned rules.
*/