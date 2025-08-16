# 🧩 Sudoku Trainer AI

An intelligent Flutter-based Sudoku game designed to help players learn and master Sudoku-solving strategies through AI-powered hints and personalized training.


![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue?style=for-the-badge)


## ✨ Features

### 🎯 Core Gameplay
- **Multiple Difficulty Levels**: Easy, Medium, Hard, and Expert puzzles
- **Smart Hint System**: AI-powered hints that teach solving strategies
- **Real-time Validation**: Instant feedback on moves with mistake tracking
- **Undo/Redo**: Complete move history with undo functionality

### 🧠 AI-Powered Learning
- **Strategy Training**: Learn human-like solving techniques
  - Naked Singles & Hidden Singles
- **Progressive Hints**: Multi-level hint system from basic to advanced
- **Strategy Tracking**: Monitor which techniques you use most
- **Personalized Learning**: Adaptive difficulty based on performance

### 🎨 User Experience
- **Beautiful UI**: Modern, responsive design with smooth animations
- **Animated Particles**: Dynamic background effects
- **Dark/Light Mode**: Comfortable playing in any lighting
- **Accessibility**: Screen reader support and keyboard navigation
- **Offline Play**: Works without internet connection

## 🚀 Installation

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0)
- Android Studio / VS Code
- Git

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/HarshadaGhanwat06/Sudoku_Trainer.git
   cd Sudoku_Trainer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── sudoku_api.dart               # API service for puzzles
│   └── sudoku_solver.dart            # AI solver algorithms
├── providers/
│   └── sudoku_provider.dart          # State management
├── screens/
│   ├── background_particles.dart     # Animated background
│   ├── difficulty_screen.dart        # Difficulty selection
│   ├── floating_progress_notifier.dart # Achievement notifications
│   ├── loading_screen.dart           # Game loading
│   ├── result_screen.dart            # Game completion
│   ├── rules_screen.dart             # Tutorial & rules
│   ├── StrategySelectionScreen.dart  # Strategy learning
│   └── sudoku_board_screen.dart      # Main game screen
└── widgets/
    ├── hint_widget.dart              # Hint display
    └── sudoku_grid.dart              # Interactive game board
```

## 🎮 How to Play

1. **Choose Difficulty**: Select from Easy to Expert levels
2. **Select Strategy**: Pick specific solving techniques to practice
3. **Play**: Tap cells to enter numbers (1-9)
4. **Use Hints**: Get AI-powered hints when stuck
5. **Learn**: Follow hint explanations to improve your skills

## 🤖 AI Solver Features

### Solving Algorithms
- **Backtracking Algorithm**: Brute force solver for validation
- **Human-like Strategies**: Mimics how humans solve puzzles
- **Difficulty Assessment**: Estimates puzzle difficulty based on required techniques
- **Hint Generation**: Provides contextual hints based on current board state

### Supported Strategies
- Basic elimination techniques
- Intersection removal
- Advanced logical techniques

## 🛠️ Technical Details

### Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.0.0
  shared_preferences: ^2.0.0
  http: ^0.13.0
  # ... other dependencies
```

### Architecture
- **MVVM Pattern**: Clean separation of concerns
- **Provider Pattern**: State management
- **Repository Pattern**: Data layer abstraction
- **Clean Architecture**: Maintainable and testable code

### Performance Optimizations
- Efficient board rendering
- Smart state updates
- Optimized hint calculations
- Memory management for long gameplay sessions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Harshada Ghanwat** - *Initial work* - [@HarshadaGhanwat06](https://github.com/HarshadaGhanwat06)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Sudoku community for strategy insights
- Open source contributors
- Beta testers and feedback providers

## 📞 Support

If you encounter any issues or have suggestions:

- 🐛 [Report a bug](https://github.com/HarshadaGhanwat06/Sudoku_Trainer/issues)
- 💡 [Request a feature](https://github.com/HarshadaGhanwat06/Sudoku_Trainer/issues)


**⭐ Star this repository if you found it helpful!**
