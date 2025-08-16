// ignore_for_file: no_leading_underscores_for_local_identifiers, avoid_print
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
// import 'dart:math';
import '../models/sudoku_api.dart';
import 'package:collection/collection.dart';

class SudokuProvider extends ChangeNotifier {
  //DECLARE VARIABLES TO BE USED

  String? Function()? activeStrategy;

  /// The currently selected strategy function

  List<List<int>> sudokuBoard = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> solutionBoard = List.generate(9, (_) => List.filled(9, 0));
  List<List<bool>> fixedCells = List.generate(9, (_) => List.filled(9, false));
  List<Map<String, dynamic>> aiSolvePreviewSteps = [];
  List<Map<String, dynamic>> moveHistory = [];
  List<Map<String, dynamic>> unsolvableMoves = [];
  List<Map<String, dynamic>> wrongMoves2 = [];
  bool isLoading = true;
  int deviationCount = 0;

  // final listEquality = const ListEquality<int>();
  final ListEquality<int> listEquality = const ListEquality<int>();
  String? pendingPatternHint;
  bool showPatternHintButton = false;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  String? mistakeExplanation;
  String? aiMessage;

  int? selectedRow;
  int? selectedCol;

  /// Shown when the user makes a correct move under the Naked Single strategy
  final List<String> nakedSingleNeutralMessages = [
    "✅ Nice work! That was a textbook Naked Single.",
    "🎯 You found the only candidate—perfect Naked Single!",
    "🔓 Locked it in! Every other possibility was eliminated.",
    "🚀 Lightning fast Naked Single—keep that momentum.",
    "💪 Spot on! Only one number fit, and you placed it.",
  ];

  /// Shown when the user makes a wrong move, with placeholders to inject the hint
  final List<String> nakedSingleErrorHints = [
    "🚫 Not quite—this isn’t a Naked Single. Look for a cell with only one candidate and place {value} at Row {row}, Col {col}.",
    "🔍 Remember: a Naked Single has exactly one possible number. Try placing {value} in the only open spot.",
    "❗ That move breaks the rule. A true Naked Single would go at Row {row}, Col {col}.",
    "⚠️ Oops! Only one number fits in that cell. Swap to {value} at Row {row}, Col {col}.",
    "🚨 Heads up: you missed the single candidate. The Naked Single is {value} at Row {row}, Col {col}.",
  ];

  /// Shown when the user makes a correct move under the Hidden Single strategy
  final List<String> hiddenSingleNeutralMessages = [
    "✅ Sharp eye! That was a perfect Hidden Single.",
    "🎯 You found the hidden placement—well done!",
    "🔍 Hidden Single mastered. You’re scanning the units well.",
    "🚀 That cell was the only spot—exactly a Hidden Single.",
    "💡 Nice deduction! That number belonged only there.",
  ];

  /// Shown when the user makes a wrong move, with placeholders to inject the hint
  final List<String> hiddenSingleErrorHints = [
    "🚫 Not a Hidden Single. That number can go elsewhere. Try placing {value} at Row {row}, Col {col}.",
    "🔍 A Hidden Single is when a digit appears only once in a unit. Look for {value} in Row {row}, Col {col}.",
    "❗ That move misses the hidden spot. The Hidden Single is {value} at Row {row}, Col {col}.",
    "⚠️ Remember to scan the entire row/col/box—only one cell fits {value}.",
    "🚨 Hint: {value} only fits at Row {row}, Col {col}. That’s a Hidden Single!",
  ];

  List<String> neutralMessages = [
    "🎯 You're on fire! Keep that logic sharp.",
    "🧠 Brain cells activated. Sudoku approves!",
    "🔍 Every move matters — and you're making great ones.",
    "✅ Perfect strategy so far. Keep it up!",
    "😎 Calculated... and correct!",
    "🚀 Solving like a pro. No signs of deviation.",
    "🧘 Smooth and steady — your focus is impressive.",
    "🎮 Precision unlocked. You’re cruising through.",
    "📈 So far, so perfect. Want a tiny challenge?",
    "🌟 A golden path is unfolding. Keep walking it.",
    "🤖 No flags raised — AI is just observing quietly.",
    "🧩 Every piece is falling in place — love to see it!",
    "🥇 Flawless logic so far. You're in the zone.",
    "👣 Footsteps aligned with the truth!",
    "🔐 You’ve unlocked the clean path — let’s maintain it!",
    "📊 AI Report: No issues detected. Carry on!",
    "💡 Tip: Try solving by box for a fresh perspective!",
    "🎵 It’s like music — your logic flows in harmony.",
    "🌌 Solving with style. Let’s keep it beautiful.",
    "🔥 Smooth like butter. Your strategy is top-tier!",
  ];

  List<String> tier1 = [
    "🔍 Hmm, that’s not quite what I expected… double check!",
    "👀 Are you trying a new path? Interesting...",
    "🧩 Not wrong… just not right either! 😉",
    "🤔 Looks like you’re going a different way.",
    "🧐 You’re off the golden path — tread carefully!",
    "🔍 Hmm, that’s not quite what I expected… double check!",
    "👀 Are you trying a new path? Interesting...",
    "🧠 Maybe a gentle rethink? Still recoverable.",
    "🎭 This move feels... unusual. What's your play?",
    "💫 A slight wobble. Nothing major yet!",
    "📌 Might want to peek at those boxes again.",
    "🌪 A twist in logic? Don’t let it spiral!",
    "🚦 A tiny detour. Still within bounds — for now.",
    "👓 That move raised an eyebrow. Keep a close eye!",
    "⏳ Off-course alert — but you’ve got time to fix it.",
  ];
  List<String> tier2 = [
    "📉 A few of these moves don’t match the goal. Want to track them?",
    "⛔️ Careful! Your progress is drifting from the target.",
    "🧠 AI Hint: You're going off-track. Want to revisit recent moves?",
    "🚩 Several deviations detected. Might be time to recheck.",
    "🔎 Looks like a pattern of incorrect steps is forming…",
    "🌀 Your logic may be circling. Let’s re-center?",
    "🧯 Small fire detected in your logic. Let’s cool it off.",
    "🔧 Something’s not clicking. Revisit last few cells?",
    "🚧 Redirection needed. Try backtracking a step or two.",
    "🌘 You're walking in the shadow path — light it up again!",
    "📵 AI senses mismatch. Want help locating the issue?",
  ];
  List<String> tier3 = [
    "🛑 You're heading far from the solution. Tap to track wrong steps.",
    "❗️Multiple missteps detected. Consider undoing a few!",
    "📛 This path may lead to an unsolvable board. Proceed cautiously.",
    "🤖 AI Alert: You're diverging from the goal. Let’s fix it together?",
    "⚠️ High deviation! Suggest reviewing last few moves.",
    "☠️ Danger zone! That logic might break the board.",
    "📉 System integrity dropping. Undo suggested.",
    "🧠 AI Strategy Breakdown: This path has critical faults.",
    "🚨 Critical logic failure possible. Want auto-fix?",
    "🔄 Suggest hitting the ‘Track Wrong Moves’ button ASAP!",
    "🧨 You're steps away from chaos. Pull back!",
    "⚰️ This might be a dead end. Want to go back?",
    "🧭 The compass of logic is spinning wildly. Let AI help recalibrate.",
  ];

  SudokuProvider() {
    // generateSudoku();
    _fetchAndSetBoard();

    //CALL FUNCTIONS AUTOMATICALLY IN PROPER SEQUENCE AS FLOW OF APP
    //first screen is rules screen
  }
  //create backend functions here - HARSHADA

  void provideLearningHint() {
    aiMessage = null;
    pendingPatternHint = null;
    showPatternHintButton = false;

    // If there's an active strategy, prioritize that -- newly added
    if (activeStrategy != null) {
      final hint = activeStrategy!();
      if (hint != null) {
        pendingPatternHint = hint;
        showPatternHintButton = true;
        notifyListeners();
        return;
      }
    }
    final List<Function()> strategies = [
      _findXYZWing,
      _findPointingPair,
      _findXWing,
      _findYWing,
      _findLockedCandidate,
      _findSwordfish,
      _findNakedSingle,
      _findHiddenSingle,
    ];

    for (final strategy in strategies) {
      final hint = strategy();
      if (hint != null) {
        pendingPatternHint = hint;
        showPatternHintButton = true;
        notifyListeners();
        return;
      }
    }

    // No pattern found
    aiMessage = "🧠 No patterns matched. Keep scanning or try advanced logic!";
    showPatternHintButton = false;
    notifyListeners();
  }

  void revealPatternHint() {
    if (pendingPatternHint != null) {
      aiMessage = pendingPatternHint;
      pendingPatternHint = null;
      showPatternHintButton = false;
      notifyListeners();
    }
  }

  String? _findHiddenSingle() {
    for (int num = 1; num <= 9; num++) {
      for (int row = 0; row < 9; row++) {
        final cols = <int>[];
        for (int col = 0; col < 9; col++) {
          if (sudokuBoard[row][col] == 0 && _isSafe(row, col, num)) {
            cols.add(col);
          }
        }
        if (cols.length == 1) {
          return '''🔍 Hidden Single: Place $num at Row ${row + 1}, Col ${cols.first + 1}

🧠 AI Insight: A Hidden Single appears when a number can only go in one cell within a row, column, or box — even if that cell has multiple candidates. The 'hidden' part comes from how this placement isn’t obvious unless you scan the entire unit carefully.
        ''';
        }
      }

      for (int col = 0; col < 9; col++) {
        final rows = <int>[];
        for (int row = 0; row < 9; row++) {
          if (sudokuBoard[row][col] == 0 && _isSafe(row, col, num)) {
            rows.add(row);
          }
        }
        if (rows.length == 1) {
          return '''🔍 Hidden Single: Place $num at Row ${rows.first + 1}, Col ${col + 1}
        
🧠 AI Insight: A Hidden Single appears when a number can only go in one cell within a row, column, or box — even if that cell has multiple candidates. The 'hidden' part comes from how this placement isn’t obvious unless you scan the entire unit carefully.
        ''';
        }
      }
    }
    return null;
  }

  String? _findNakedSingle() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (sudokuBoard[row][col] == 0) {
          final candidates = _getCandidates(row, col);
          if (candidates.length == 1) {
            return '''🔓 Naked Single: Only ${candidates.first} fits in Row ${row + 1}, Col ${col + 1}";
          
🧠 AI Insight: A Naked Single occurs when only one number can logically fit in a cell without breaking Sudoku rules. This means all other numbers are eliminated by existing numbers in the row, column, and box — making this placement a guaranteed move.
          ''';
          }
        }
      }
    }
    return null;
  }

  String? _findLockedCandidate() {
    for (int num = 1; num <= 9; num++) {
      for (int boxRow = 0; boxRow < 3; boxRow++) {
        for (int boxCol = 0; boxCol < 3; boxCol++) {
          Set<int> possibleRows = {};
          Set<int> possibleCols = {};
          for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
              int row = boxRow * 3 + i;
              int col = boxCol * 3 + j;
              if (sudokuBoard[row][col] == 0 && _isSafe(row, col, num)) {
                possibleRows.add(row);
                possibleCols.add(col);
              }
            }
          }
          if (possibleRows.length == 1) {
            return '''🔐 Locked Candidate: $num must be in Row ${possibleRows.first + 1} within Box ${3 * boxRow + boxCol + 1}
          
🧠 AI Insight: This technique finds when a candidate is restricted to a single row or column within a box — meaning we can eliminate it from the same row or column outside the box. It's like finding local exclusivity.
          ''';
          } else if (possibleCols.length == 1) {
            return '''🔐 Locked Candidate: $num must be in Col ${possibleCols.first + 1} within Box ${3 * boxRow + boxCol + 1}
          
🧠 AI Insight: This technique finds when a candidate is restricted to a single row or column within a box — meaning we can eliminate it from the same row or column outside the box. It's like finding local exclusivity.
          ''';
          }
        }
      }
    }
    return null;
  }

  String? _findPointingPair() {
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        for (int num = 1; num <= 9; num++) {
          List<(int, int)> positions = [];
          for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
              int row = boxRow * 3 + i;
              int col = boxCol * 3 + j;
              if (sudokuBoard[row][col] == 0 && _isSafe(row, col, num)) {
                positions.add((row, col));
              }
            }
          }

          if (positions.isEmpty) continue;

          bool sameRow = positions.every((pos) => pos.$1 == positions[0].$1);
          bool sameCol = positions.every((pos) => pos.$2 == positions[0].$2);

          if (sameRow) {
            return '''📌 Pointing Pair: $num in Row ${positions[0].$1 + 1} limits possibilities outside Box ${3 * boxRow + boxCol + 1}

🧠 AI Insight: When a candidate appears only in one row or column within a 3×3 box, it must be placed there — and thus it can be removed from other cells in that row or column outside the box. It's a powerful elimination technique that relies on overlap.
          ''';
          } else if (sameCol) {
            return '''📌 Pointing Pair: $num in Col ${positions[0].$2 + 1} limits possibilities outside Box ${3 * boxRow + boxCol + 1}

🧠 AI Insight: When a candidate appears only in one row or column within a 3×3 box, it must be placed there — and thus it can be removed from other cells in that row or column outside the box. It's a powerful elimination technique that relies on overlap.
          ''';
          }
        }
      }
    }
    return null;
  }

  String? _findXWing() {
    for (int num = 1; num <= 9; num++) {
      final Map<int, List<int>> rowCandidates = {};

      for (int row = 0; row < 9; row++) {
        final cols = <int>[];
        for (int col = 0; col < 9; col++) {
          if (sudokuBoard[row][col] == 0 && _isSafe(row, col, num)) {
            cols.add(col);
          }
        }
        if (cols.length == 2) {
          rowCandidates[row] = cols;
        }
      }

      final rows = rowCandidates.keys.toList();
      for (int i = 0; i < rows.length; i++) {
        for (int j = i + 1; j < rows.length; j++) {
          final r1 = rows[i], r2 = rows[j];
          if (listEquality.equals(rowCandidates[r1], rowCandidates[r2])) {
            final sharedCols = rowCandidates[r1]!;
            return '''✖️ X-Wing on $num: Cols ${sharedCols[0] + 1} & ${sharedCols[1] + 1} between Rows ${r1 + 1} & ${r2 + 1}. Eliminate $num from these columns in other rows.

🧠 AI Insight: The X-Wing technique finds a repeating pattern across rows and columns for a specific digit. If two rows (or columns) have the same two possible columns (or rows) for a digit, we can eliminate that digit from those columns (or rows) in all other rows (or columns). Think of it like locking two swords into a gridlock — everything else is cut off.
          ''';
          }
        }
      }
    }
    return null;
  }

  String? _findYWing() {
    for (int pivotRow = 0; pivotRow < 9; pivotRow++) {
      for (int pivotCol = 0; pivotCol < 9; pivotCol++) {
        final pivotCandidates = _getCandidates(pivotRow, pivotCol);
        if (pivotCandidates.length != 2) continue;

        for (int wing1Row = 0; wing1Row < 9; wing1Row++) {
          for (int wing1Col = 0; wing1Col < 9; wing1Col++) {
            if (wing1Row == pivotRow && wing1Col == pivotCol) continue;
            if (!_sharesUnit(pivotRow, pivotCol, wing1Row, wing1Col)) continue;

            final wing1Candidates = _getCandidates(wing1Row, wing1Col);
            if (!SetEquality().equals(
              pivotCandidates.toSet().intersection(wing1Candidates.toSet()),
              {pivotCandidates[0]},
            )) {
              continue;
            }

            for (int wing2Row = 0; wing2Row < 9; wing2Row++) {
              for (int wing2Col = 0; wing2Col < 9; wing2Col++) {
                if ((wing2Row == pivotRow && wing2Col == pivotCol) ||
                    (wing2Row == wing1Row && wing2Col == wing1Col)) {
                  continue;
                }
                if (!_sharesUnit(pivotRow, pivotCol, wing2Row, wing2Col)) {
                  continue;
                }

                final wing2Candidates = _getCandidates(wing2Row, wing2Col);
                if (!SetEquality().equals(
                  pivotCandidates.toSet().intersection(wing2Candidates.toSet()),
                  {pivotCandidates[1]},
                )) {
                  continue;
                }

                if (_sharesUnit(wing1Row, wing1Col, wing2Row, wing2Col)) {
                  final elim = pivotCandidates.firstWhere(
                    (c) =>
                        !wing1Candidates.contains(c) &&
                        !wing2Candidates.contains(c),
                  );
                  return '''🔗 Y-Wing: Pivot (${pivotRow + 1},${pivotCol + 1}) with wings (${wing1Row + 1},${wing1Col + 1}) and (${wing2Row + 1},${wing2Col + 1}) allows eliminating $elim from common peers.
                
🧠 AI Insight: Y-Wing uses three interrelated cells (a pivot and two wings) with overlapping candidates to eliminate a value from cells that see both wings. It's a pattern of conditional logic — if this, then not that — used by humans and AI alike to dig deeper than simple elimination.
                ''';
                }
              }
            }
          }
        }
      }
    }
    return null;
  }

  String? _findSwordfish() {
    for (int num = 1; num <= 9; num++) {
      Map<int, List<int>> rowMap = {};

      for (int row = 0; row < 9; row++) {
        final cols = <int>[];
        for (int col = 0; col < 9; col++) {
          if (sudokuBoard[row][col] == 0 && _isSafe(row, col, num)) {
            cols.add(col);
          }
        }
        if (cols.length >= 2 && cols.length <= 3) {
          rowMap[row] = cols;
        }
      }

      final rows = rowMap.keys.toList();
      for (int i = 0; i < rows.length; i++) {
        for (int j = i + 1; j < rows.length; j++) {
          for (int k = j + 1; k < rows.length; k++) {
            final allCols = <int>{
              ...rowMap[rows[i]]!,
              ...rowMap[rows[j]]!,
              ...rowMap[rows[k]]!,
            };
            if (allCols.length == 3) {
              return '''🐟 Swordfish on $num: Rows ${rows[i] + 1}, ${rows[j] + 1}, ${rows[k] + 1} across Cols ${allCols.map((c) => c + 1).join(', ')}. Eliminate $num from these columns in other rows.
            
🧠 AI Insight: A more advanced cousin of X-Wing, Swordfish looks for three rows (or columns) where a digit is limited to the same three columns (or rows). This restricts that digit's placement to just those intersections — eliminating it elsewhere. Imagine three fishing lines catching the same number.
            ''';
            }
          }
        }
      }
    }
    return null;
  }

  bool get showTrackWrongMovesButton => deviationCount >= 3;
  String? _findXYZWing() {
    for (int pRow = 0; pRow < 9; pRow++) {
      for (int pCol = 0; pCol < 9; pCol++) {
        final pivot = _getCandidates(pRow, pCol);
        if (pivot.length != 3) continue;

        final peers = <(int, int)>[];
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if ((r == pRow && c == pCol) || !_sharesUnit(pRow, pCol, r, c)) {
              continue;
            }
            if (_getCandidates(r, c).length == 2 &&
                pivot.toSet().containsAll(_getCandidates(r, c))) {
              peers.add((r, c));
            }
          }
        }

        for (int i = 0; i < peers.length; i++) {
          for (int j = i + 1; j < peers.length; j++) {
            final wing1 = _getCandidates(peers[i].$1, peers[i].$2);
            final wing2 = _getCandidates(peers[j].$1, peers[j].$2);
            final combined = {...wing1, ...wing2};
            if (combined.length == 3 && pivot.toSet().containsAll(combined)) {
              final common = wing1.toSet().intersection(wing2.toSet());
              if (common.length == 1) {
                final elim = common.first;
                return '''🧠 XYZ-Wing: Pivot (${pRow + 1},${pCol + 1}) with wings (${peers[i].$1 + 1},${peers[i].$2 + 1}) and (${peers[j].$1 + 1},${peers[j].$2 + 1}) lets you eliminate $elim from common peers.
              
🧠 AI Insight: XYZ-Wing builds on conditional logic — using a cell with three candidates (pivot) and two related cells with two of those candidates. If both wings connect to the pivot and share one candidate, that value can be safely eliminated from any common peers. It's complex, but super satisfying.''';
              }
            }
          }
        }
      }
    }
    return null;
  }

  bool _sharesUnit(int r1, int c1, int r2, int c2) {
    return r1 == r2 || c1 == c2 || (r1 ~/ 3 == r2 ~/ 3 && c1 ~/ 3 == c2 ~/ 3);
  }

  List<int> _getCandidates(int row, int col) {
    return [
      for (int n = 1; n <= 9; n++)
        if (_isSafe(row, col, n)) n,
    ];
  }

  Future<void> _fetchAndSetBoard() async {
    isLoading = true;
    final data = await SudokuAPI.fetchSudoku('easy');

    sudokuBoard = data['puzzle']!;
    solutionBoard = data['solution']!;
    // print(solutionBoard);
    fixedCells = List.generate(
      9,
      (i) => List.generate(9, (j) => sudokuBoard[i][j] != 0),
    );

    _solveSudokuInternal(solutionBoard); // Optional - if needed for validation
    isLoading = false;
    notifyListeners();
  }

  //my new function
  Future<void> fetchAndSetBoardStrategy(
    String strategy,
    String difficulty,
  ) async {
    isLoading = true;
    notifyListeners();

    final data = await SudokuAPI.fetchSudoku(difficulty);

    sudokuBoard = data['puzzle']!;
    solutionBoard = data['solution']!;
    fixedCells = List.generate(
      9,
      (i) => List.generate(9, (j) => sudokuBoard[i][j] != 0),
    );

    // Set the active strategy here
    activeStrategy =
        strategyMap[strategy]; // strategyMap should map keys to functions

    isLoading = false;
    notifyListeners();
  }

  /// Map of strategy name to function
  Map<String, String? Function()> get strategyMap => {
    'nakedSingle': _findNakedSingle,
    'hiddenSingle': _findHiddenSingle,
  };

  //newly added
  // Create a method to set the active strategy when a strategy button is clicked
  void setActiveStrategy(String strategyName) {
    activeStrategy = strategyMap[strategyName];
    // Clear previous messages
    aiMessage = null;
    pendingPatternHint = null;
    showPatternHintButton = false;
    notifyListeners();

    // Optionally provide an initial hint about this strategy
    String initialHint;
    switch (strategyName) {
      case 'nakedSingle':
        initialHint =
            "🔍 Naked Single strategy active! Look for cells with only one possible value.";
        break;
      case 'hiddenSingle':
        initialHint =
            "🧩 Hidden Single strategy active! Find where a number can only go in one place within a unit.";
        break;
      case 'lockedCandidate':
        initialHint =
            "🔒 Locked Candidate strategy active! Look for candidates restricted to a single row/column within a box.";
        break;
      // Add others as needed
      default:
        initialHint =
            "📝 Strategy activated! Apply what you've learned to solve the puzzle.";
    }

    _showHint(initialHint);
  }

  void analyzeMoveAI() {
    // Don't clear existing aiMessage if it's already set by a strategy handler
    if (aiMessage == null) {
      List<List<int>> boardCopy =
          sudokuBoard.map((row) => List<int>.from(row)).toList();
      bool solvable = _solveSudokuInternal(boardCopy);

      if (!solvable) {
        _checkAutoUndoSuggestion(); // highest priority
        return;
      }
      _updateWrongMoves2();
      // Track deviations from solution
      // int newDeviations = 0;
      // for (var move in moveHistory) {
      //   int row = move['row'];
      //   int col = move['col'];
      //   int val = move['number'];
      //   if (solutionBoard[row][col] != val) newDeviations++;
      // }
      deviationCount = wrongMoves2.length;

      // Show deviation-based message
      _showDeviationHint(deviationCount);

      notifyListeners();
    }
  }

  void showWrongMovesComparedToSolution() {
    if (wrongMoves2.isEmpty) {
      aiMessage = "✅ You're on the correct path!";
      return;
    }

    StringBuffer message = StringBuffer();
    message.writeln("🚫 Deviations from the solution:\n");

    for (var move in wrongMoves2) {
      int row = move['row'] + 1;
      int col = move['col'] + 1;
      int num = move['number'];
      message.writeln(" - $num at Row $row, Col $col");
    }

    aiMessage = message.toString();
    notifyListeners();
  }

  int _randomIndex(int length) => DateTime.now().millisecond % length;

  // Show a hint to the user
  void _showHint(String message) {
    aiMessage = message;
    notifyListeners();
    // print("Hint: $message");
  }

  // Provide a hint by suggesting a possible number
  void provideHint() {
    if (selectedRow != null && selectedCol != null) {
      int correctNumber = solutionBoard[selectedRow!][selectedCol!];
      int currentNumber = sudokuBoard[selectedRow!][selectedCol!];

      if (currentNumber == 0) {
        // If empty, suggest the correct number
        _showHint("Try placing $correctNumber in this cell.");
      } else if (currentNumber != correctNumber) {
        // If incorrect, suggest correction
        _showHint("This is incorrect. Try another number.");
      } else {
        _showHint("Good job! This number is correct.");
      }
    }
  }

  String _getStrategyNameFromFunction(String? Function()? function) {
    //if (function == null) return 'neutral';
    if (function == _findNakedSingle) return 'nakedSingle';
    if (function == _findHiddenSingle) return 'hiddenSingle';
    return 'unknown';
  }

  void clearSelectedCell() {
    if (selectedCell != null &&
        !fixedCells[selectedCell!.$1][selectedCell!.$2]) {
      int row = selectedCell!.$1;
      int col = selectedCell!.$2;

      // Remove from moveHistory if it exists
      moveHistory.removeWhere(
        (move) => move['row'] == row && move['col'] == col,
      );

      // Clear the cell
      sudokuBoard[row][col] = 0;

      // Clear feedback
      mistakeExplanation = null;
      aiMessage = null;

      // Re-analyze the board
      _updateWrongMoves2();
      analyzeMoveAI();

      notifyListeners();
    }
  }

  String explainMistake(int row, int col, int num) {
    // Check row
    if (sudokuBoard[row].contains(num)) {
      return "Number already exists in this row.";
    }

    // Check column
    for (int i = 0; i < 9; i++) {
      if (sudokuBoard[i][col] == num) {
        return "Number already exists in this column.";
      }
    }

    // Check box
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (sudokuBoard[startRow + i][startCol + j] == num) {
          return "Number already exists in this 3x3 box.";
        }
      }
    }

    return "This move is valid.";
  }

  /// Handle feedback specific to Naked Single strategy
  bool _handleNakedSingleFeedback(int row, int col, int value) {
    // Create a temporary board with the move undone to check if it was a Naked Single
    List<List<int>> tempBoard = List.generate(
      9,
      (i) => List.from(sudokuBoard[i]),
    );
    tempBoard[row][col] = 0; // Undo the move temporarily

    // Check if this was a Naked Single (only one possible value for this cell)
    List<int> candidates = [];
    for (int num = 1; num <= 9; num++) {
      if (_isSafeInternal(tempBoard, row, col, num)) {
        candidates.add(num);
      }
    }

    if (candidates.length == 1 && candidates.first == value) {
      // This was a correct Naked Single move - show positive feedback
      aiMessage =
          nakedSingleNeutralMessages[Random().nextInt(
            nakedSingleNeutralMessages.length,
          )];
      return true;
    }

    // This wasn't a Naked Single - look for an actual Naked Single on the board
    String? hint = _findNakedSingle();
    if (hint != null) {
      // Extract coordinates from the hint using RegExp
      RegExp regExp = RegExp(r'Only (\d+) fits in Row (\d+), Col (\d+)');
      Match? match = regExp.firstMatch(hint);

      if (match != null && match.groupCount >= 3) {
        int correctVal = int.parse(match.group(1)!);
        int correctRow = int.parse(match.group(2)!) - 1; // Convert to 0-based
        int correctCol = int.parse(match.group(3)!) - 1; // Convert to 0-based

        _showDeviationHint(
          ++deviationCount,
          strategy: 'nakedSingle',
          row: correctRow,
          col: correctCol,
          value: correctVal,
        );
        return true;
      }
    }

    // Fallback if regex fails or no Naked Single found
    aiMessage =
        "That wasn't a Naked Single. Look for cells with only one possible value.";
    return true;
  }

  /// Handle feedback specific to Hidden Single strategy
  bool _handleHiddenSingleFeedback(int row, int col, int value) {
    print(
      "Checking if move at R$row C$col with value $value is a Hidden Single",
    ); //for debugging

    // Create a temporary board to analyze
    List<List<int>> tempBoard = List.generate(
      9,
      (i) => List.from(sudokuBoard[i]),
    );
    tempBoard[row][col] = 0; // Undo the move temporarily

    // Check if this was a Hidden Single in row
    bool isHiddenSingleInRow = true;
    for (int c = 0; c < 9; c++) {
      if (c != col &&
          tempBoard[row][c] == 0 &&
          _isSafeInternal(tempBoard, row, c, value)) {
        isHiddenSingleInRow = false;
        break;
      }
    }

    // Check if this was a Hidden Single in column
    bool isHiddenSingleInCol = true;
    for (int r = 0; r < 9; r++) {
      if (r != row &&
          tempBoard[r][col] == 0 &&
          _isSafeInternal(tempBoard, r, col, value)) {
        isHiddenSingleInCol = false;
        break;
      }
    }

    // Check if this was a Hidden Single in box
    bool isHiddenSingleInBox = true;
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        int checkRow = startRow + r;
        int checkCol = startCol + c;
        if ((checkRow != row || checkCol != col) &&
            tempBoard[checkRow][checkCol] == 0 &&
            _isSafeInternal(tempBoard, checkRow, checkCol, value)) {
          isHiddenSingleInBox = false;
          break;
        }
      }
      if (!isHiddenSingleInBox) break;
    }

    // If this was a Hidden Single in any unit, give positive feedback
    if (isHiddenSingleInRow || isHiddenSingleInCol || isHiddenSingleInBox) {
      aiMessage =
          hiddenSingleNeutralMessages[Random().nextInt(
            hiddenSingleNeutralMessages.length,
          )];
      return true;
    }

    // This wasn't a Hidden Single - look for an actual Hidden Single on the board
    String? hint = _findHiddenSingle();
    if (hint != null) {
      // Extract coordinates from the hint using RegExp
      RegExp regExp = RegExp(r'Place (\d+) at Row (\d+), Col (\d+)');
      Match? match = regExp.firstMatch(hint);

      if (match != null && match.groupCount >= 3) {
        int correctVal = int.parse(match.group(1)!);
        int correctRow = int.parse(match.group(2)!) - 1; // Convert to 0-based
        int correctCol = int.parse(match.group(3)!) - 1; // Convert to 0-based

        _showDeviationHint(
          ++deviationCount,
          strategy: 'hiddenSingle',
          row: correctRow,
          col: correctCol,
          value: correctVal,
        );
        return true;
      }
    }

    // Fallback if regex fails or no Hidden Single found
    aiMessage =
        "That wasn't a Hidden Single. Look for cells where a number can only go in one place within a row, column, or box.";
    return true;
  }

  // New method to check if the move aligns with active strategy
  void _checkStrategyBasedFeedback() {
    print(
      "Checking strategy feedback. Active strategy: ${activeStrategy != null ? 'set' : 'null'}",
    );

    // Only proceed if there's an active strategy
    if (activeStrategy == null) {
      print("No active strategy, using general AI feedback");
      analyzeMoveAI();
      return;
    }
    // Guard against empty move history
    if (moveHistory.isEmpty) {
      return;
    }
    // Get the strategy name
    String strategyName = _getStrategyNameFromFunction(activeStrategy);
    print("Strategy name detected: $strategyName");

    // Get the latest move
    Map<String, dynamic> latestMove = moveHistory.last;
    int row = latestMove['row'];
    int col = latestMove['col'];
    int value = latestMove['number'];

    // Flag to track if feedback was already provided
    bool feedbackProvided = false;

    // First, set aiMessage to null (but only here, not in analyzeMoveAI)
    aiMessage = null;

    // Evaluate the move based on the active strategy
    switch (strategyName) {
      case 'nakedSingle':
        print("Handling as Naked Single");
        feedbackProvided = _handleNakedSingleFeedback(row, col, value);
        break;

      case 'hiddenSingle':
        print("Handling as Hidden Single");
        feedbackProvided = _handleHiddenSingleFeedback(row, col, value);
        break;

      default:
        // For any other strategy or if strategy detection fails
        print("Unknown strategy, using general AI feedback");
        analyzeMoveAI();
        feedbackProvided = true;
        break;
    }
    // Only call additional feedback if none was provided
    if (!feedbackProvided) {
      analyzeMoveAI();
    } else {
      notifyListeners();
    }
  }

  // Enter a number into the selected cell
  void enterNumber(int number) {
    if (selectedRow == null || selectedCol == null) return;

    // If cell is fixed, bail out
    if (fixedCells[selectedRow!][selectedCol!]) {
      mistakeExplanation = "This cell is unchangeable.";
      notifyListeners();
      return;
    }

    // If move is valid
    if (_isSafe(selectedRow!, selectedCol!, number)) {
      sudokuBoard[selectedRow!][selectedCol!] = number;
      moveHistory.removeWhere(
        (m) => m['row'] == selectedRow! && m['col'] == selectedCol!,
      );
      moveHistory.add({
        'row': selectedRow!,
        'col': selectedCol!,
        'number': number,
      });

      deviationCount = 0;
      mistakeExplanation = null;
      _updateWrongMoves2();

      // Only now trigger AI feedback -- newly added
      if (activeStrategy != null) {
        _checkStrategyBasedFeedback();
      } else {
        updateProgressFeedback();
      }

      // updateProgressFeedback();
      // provideLearningHint();
      // analyzeMoveAI();
      _checkCompletion();
      notifyListeners();
      return;
    }

    // ← CHANGED: this else now correctly pairs with the above if
    // Move was invalid—explain and show a strategy-based hint
    mistakeExplanation = explainMistake(selectedRow!, selectedCol!, number);

    // ← CHANGED: determine strategy key via helper (no new vars)
    final strategyKey =
        activeStrategy == null
            ? 'neutral'
            : _getStrategyNameFromFunction(activeStrategy);

    _showDeviationHint(
      ++deviationCount,
      strategy: strategyKey, // uses our helper’s output
      row: selectedRow!,
      col: selectedCol!,
      value: solutionBoard[selectedRow!][selectedCol!],
    );

    notifyListeners();

    /*if (selectedRow != null && selectedCol != null) {
      if (!fixedCells[selectedRow!][selectedCol!]) {
        if (_isSafe(selectedRow!, selectedCol!, number)) {
          sudokuBoard[selectedRow!][selectedCol!] = number;
          moveHistory.removeWhere(
            (move) =>
                move['row'] == selectedRow! && move['col'] == selectedCol!,
          );
          moveHistory.add({
            'row': selectedRow!,
            'col': selectedCol!,
            'number': number,
          });
          deviationCount = 0;
          mistakeExplanation = null;
          _updateWrongMoves2();
          updateProgressFeedback();
          provideLearningHint();
          analyzeMoveAI();
          _checkCompletion();
          notifyListeners();
        } 
        else {
          mistakeExplanation = explainMistake(selectedRow!, selectedCol!,number);
          notifyListeners();
        }

          
          // SHOW STRATEGY-BASED ERROR HINT
          _showDeviationHint(
            ++deviationCount,
            strategy: activeStrategy != null ? activeStrategy!() != null ? 
            _getStrategyNameFromFunction(activeStrategy!) : 'neutral' : 'neutral',
            row: selectedRow!,
            col: selectedCol!,
            value: solutionBoard[selectedRow!][selectedCol!],
          );
          
          // Add this helper method to determine strategy name from function
          
      } 
      else {
        mistakeExplanation = "This cell is unchangeable.";
        notifyListeners();
      }
    }
  }*/
  }

  void _checkAutoUndoSuggestion() {
    List<List<int>> boardCopy = List.generate(
      9,
      (i) => List.from(sudokuBoard[i]),
    );
    if (_solveSudokuInternal(boardCopy)) {
      unsolvableMoves.clear(); // Everything is fine
      return;
    }

    List<List<int>> originalBoard = List.generate(
      9,
      (i) => List.from(sudokuBoard[i]),
    );

    for (int i = moveHistory.length - 1; i >= 0; i--) {
      List<List<int>> testBoard = List.generate(
        9,
        (i) => List.from(originalBoard[i]),
      );

      // Remove moves one-by-one and test
      for (int j = i; j < moveHistory.length; j++) {
        var move = moveHistory[j];
        testBoard[move['row']][move['col']] = 0;
      }

      if (_solveSudokuInternal(testBoard)) {
        // Found the earliest bad move
        unsolvableMoves = moveHistory.sublist(i);
        _buildAutoUndoMessage();
        return;
      }
    }

    // If none of them solve it, suggest all moves
    unsolvableMoves = List.from(moveHistory);
    _buildAutoUndoMessage();
  }

  void _buildAutoUndoMessage() {
    if (unsolvableMoves.isEmpty) {
      aiMessage = null;
      return;
    }

    StringBuffer message = StringBuffer();
    message.writeln("❌ AI Alert: Unsolvable board detected.");
    message.writeln("🔄 Suggestion: Undo these moves:");

    for (var move in unsolvableMoves) {
      int row = move['row'] + 1;
      int col = move['col'] + 1;
      int number = move['number'];
      message.writeln(" - $number at Row $row, Col $col");
    }

    aiMessage = message.toString();
    notifyListeners();
  }

  bool _isSafe(int row, int col, int num) {
    // Check row
    if (sudokuBoard[row].contains(num)) return false;

    // Check column
    for (int i = 0; i < 9; i++) {
      if (sudokuBoard[i][col] == num) return false;
    }

    // Check 3x3 box
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (sudokuBoard[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  bool _solveSudokuInternal(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (_isSafeInternal(board, row, col, num)) {
              board[row][col] = num;
              if (_solveSudokuInternal(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isSafeInternal(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }

    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  // Check if the Sudoku board is completed
  void _checkCompletion() {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (sudokuBoard[row][col] == 0 ||
            sudokuBoard[row][col] != solutionBoard[row][col]) {
          return;
        }
      }
    }
    _showCompletionDialog(true);
  }

  // Show completion message - UI
  void _showCompletionDialog(bool isSuccess) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text(isSuccess ? "Success!" : "Not Complete"),
                content: Text(
                  isSuccess ? "You've solved the Sudoku!" : "Try again.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text("OK"),
                  ),
                ],
              ),
        );
      }
    });
  }

  Set<(int, int)> blinkingWrongMoves = {};

  void blinkWrongMove(int row, int col) {
    blinkingWrongMoves.add((row, col));
    notifyListeners();
    Future.delayed(const Duration(seconds: 1), () {
      blinkingWrongMoves.remove((row, col));
      notifyListeners();
    });
  }

  void updateProgressFeedback() {
    final board = sudokuBoard;
    final correctBoard =
        solutionBoard; // assuming you have the correct solution
    //if (board == null || correctBoard == null) return;

    int filledCells = 0;
    int correctCells = 0;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != 0) {
          filledCells++;
          if (board[r][c] == correctBoard[r][c]) {
            correctCells++;
          }
        }
      }
    }
    // Only update AI message if we need to
    String message;

    // ✅ Completion percentage
    final percent = ((correctCells / 81) * 100).toStringAsFixed(1);
    if (correctCells == 81) {
      message = "✅ Puzzle solved! Great job!";
    } else if (filledCells == 81 && correctCells < 81) {
      message = "❌ All cells filled, but some are incorrect. Keep checking!";
    } else {
      // Only occasionally show progress updates to avoid message spam
      if (Random().nextInt(3) == 0) {
        // Only 1/3 chance to show this message
        message = "💡 You're ${percent}% correct so far!";
      } else {
        return; // Don't show a message at all
      }
    }

    // 🎯 Additional tips like "only 3 cells left in box 5"
    for (int box = 0; box < 9; box++) {
      int emptyCount = 0;
      final startRow = (box ~/ 3) * 3;
      final startCol = (box % 3) * 3;

      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          if (board[startRow + r][startCol + c] == 0) emptyCount++;
        }
      }

      if (emptyCount > 0 && emptyCount <= 3) {
        aiMessage =
            "💡 Only $emptyCount empty cell${emptyCount > 1 ? 's' : ''} left in box ${box + 1}!";
        break;
      }
    }
    aiMessage = message;
    notifyListeners();
  }

  void _updateWrongMoves2() {
    // print("Updating wrongMoves2...");
    wrongMoves2.clear();
    deviationCount = 0;
    for (var move in moveHistory) {
      int r = move['row'];
      int c = move['col'];
      int v = move['number'];
      if (solutionBoard[r][c] != v) {
        // print("Wrong move found: $v at ($r,$c), expected ${solutionBoard[r][c]}");
        wrongMoves2.add({'row': r, 'col': c, 'number': v});
      }
    }

    // print("wrongMoves2 now has ${wrongMoves2.length} items.");
  }

  //function position changed
  void _showDeviationHint(
    int count, {
    String strategy = 'neutral',
    int? row,
    int? col,
    int? value,
  }) {
    List<String> messages;

    switch (strategy) {
      case 'nakedSingle':
        messages = nakedSingleErrorHints;
        break;
      case 'hiddenSingle':
        messages = hiddenSingleErrorHints;
        break;
      default:
        messages = neutralMessages;
    }

    String message = messages[Random().nextInt(messages.length)];

    if (value != null) {
      message = message.replaceAll('{value}', value.toString());
    }
    if (row != null) {
      message = message.replaceAll('{row}', (row + 1).toString());
    }
    if (col != null) {
      message = message.replaceAll('{col}', (col + 1).toString());
    }

    _showHint(message);

    if (count >= 5) {
      aiMessage = tier3[_randomIndex(tier3.length)];
    } else if (count >= 3) {
      aiMessage = tier2[_randomIndex(tier2.length)];
    } else if (count >= 1) {
      aiMessage = tier1[_randomIndex(tier1.length)];
    } else {
      aiMessage = neutralMessages[_randomIndex(neutralMessages.length)];
    }
  }

  // Select a cell on the board
  (int, int)? selectCell(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    mistakeExplanation = null;
    notifyListeners();
    return (row, col);
  }

  // Separate getter for selected cell
  (int, int)? get selectedCell {
    if (selectedRow != null && selectedCol != null) {
      return (selectedRow!, selectedCol!);
    }
    return null;
  }

bool isBoardComplete() {
  // Check if all cells have values (no empty cells)
  for (int row = 0; row < 9; row++) {
    for (int col = 0; col < 9; col++) {
      if (sudokuBoard[row][col] == 0) {  // Assuming 0 represents empty cells
        return false;
      }
    }
  }
  return true;
}

bool isBoardValid() {
  // Check rows, columns, and 3x3 boxes for validity

  // Check rows
  for (int row = 0; row < 9; row++) {
    Set<int> values = {};
    for (int col = 0; col < 9; col++) {
      int value = sudokuBoard[row][col];
      if (value != 0 && !values.add(value)) {
        return false; // Duplicate found
      }
    }
  }
  
  // Check columns
  for (int col = 0; col < 9; col++) {
    Set<int> values = {};
    for (int row = 0; row < 9; row++) {
      int value = sudokuBoard[row][col];
      if (value != 0 && !values.add(value)) {
        return false; // Duplicate found
      }
    }
  }
  
  // Check 3x3 boxes
  for (int boxRow = 0; boxRow < 3; boxRow++) {
    for (int boxCol = 0; boxCol < 3; boxCol++) {
      Set<int> values = {};
      for (int row = boxRow * 3; row < boxRow * 3 + 3; row++) {
        for (int col = boxCol * 3; col < boxCol * 3 + 3; col++) {
          int value = sudokuBoard[row][col];
          if (value != 0 && !values.add(value)) {
            return false; // Duplicate found
          }
        }
      }
    }
  }
  
  return true;
}
}

