import 'package:flutter/material.dart';
import 'package:sudoku_trainer/screens/StrategySelectionScreen.dart';
import 'sudoku_board_screen.dart';

class DifficultyScreen extends StatelessWidget {
  void _startGame(BuildContext context, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        ///builder: (context) => SudokuBoardScreen(difficulty: difficulty, strategyExplanation: () {  },),
        builder: (context) => StrategySelectionScreen(difficulty: difficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose Difficulty")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _startGame(context, "easy"),
            child: Text("Easy"),
          ),
          ElevatedButton(
            onPressed: () => _startGame(context, "medium"),
            child: Text("Medium"),
          ),
          ElevatedButton(
            onPressed: () => _startGame(context, "hard"),
            child: Text("Hard"),
          ),
        ],
      ),
    );
  }
}
