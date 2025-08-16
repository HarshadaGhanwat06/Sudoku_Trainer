import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sudoku_provider.dart';
import 'sudoku_board_screen.dart';

class StrategySelectionScreen extends StatelessWidget {
  final String difficulty;

  const StrategySelectionScreen({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("Choose Strategy to Learn"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildFrostedDialog(context),
        ),
      ),
    );
  }

  Widget _buildFrostedDialog(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select a Strategy",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildStrategyButton(
                context,
                label: "🧠 Find Naked Single",
                strategyKey: "nakedSingle",
                explanation:
                    "A cell has only one possible candidate — fill it!",
              ),
              const SizedBox(height: 24),
              _buildStrategyButton(
                context,
                label: "👀 Find Hidden Single",
                strategyKey: "hiddenSingle",
                explanation:
                    "A candidate appears only once in a row/column/block.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyButton(
    BuildContext context, {
    required String label,
    required String strategyKey,
    required String explanation,
  }) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 5,
          ),
          onPressed: () async {
            final provider = context.read<SudokuProvider>();

            // Set the strategy key
            await provider.fetchAndSetBoardStrategy(strategyKey, difficulty);

            // Go to board screen with the strategy
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => SudokuBoardScreen(
                      difficulty: difficulty,
                      //activeStrategy: provider.activeStrategy!,
                      strategyExplanation: provider.activeStrategy!,  // matches String? Function()
                      
                    ),
              ),
            );
          },
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 8),
        Text(
          explanation,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
//