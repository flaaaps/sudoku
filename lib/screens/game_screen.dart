import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/difficulty.dart';
import '../models/sudoku_board.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../widgets/clue_button.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SudokuBoard _board;
  bool _notesMode = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _board = SudokuBoard(difficulty: widget.difficulty);
    _board.addListener(_onBoardChanged);
  }

  @override
  void dispose() {
    _board.removeListener(_onBoardChanged);
    _board.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onBoardChanged() {
    if (_board.isComplete) {
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('You solved the puzzle!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to home
            },
            child: const Text('Home'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              setState(() {
                _board.removeListener(_onBoardChanged);
                _board.dispose();
                _board = SudokuBoard(difficulty: widget.difficulty);
                _board.addListener(_onBoardChanged);
              });
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    // Arrow keys for navigation
    if (key == LogicalKeyboardKey.arrowUp && _board.selectedRow != null) {
      _board.selectCell(
        (_board.selectedRow! - 1).clamp(0, 8),
        _board.selectedCol!,
      );
    } else if (key == LogicalKeyboardKey.arrowDown &&
        _board.selectedRow != null) {
      _board.selectCell(
        (_board.selectedRow! + 1).clamp(0, 8),
        _board.selectedCol!,
      );
    } else if (key == LogicalKeyboardKey.arrowLeft &&
        _board.selectedCol != null) {
      _board.selectCell(
        _board.selectedRow!,
        (_board.selectedCol! - 1).clamp(0, 8),
      );
    } else if (key == LogicalKeyboardKey.arrowRight &&
        _board.selectedCol != null) {
      _board.selectCell(
        _board.selectedRow!,
        (_board.selectedCol! + 1).clamp(0, 8),
      );
    }

    // Number keys 1-9
    final numberKeys = {
      LogicalKeyboardKey.digit1: 1,
      LogicalKeyboardKey.digit2: 2,
      LogicalKeyboardKey.digit3: 3,
      LogicalKeyboardKey.digit4: 4,
      LogicalKeyboardKey.digit5: 5,
      LogicalKeyboardKey.digit6: 6,
      LogicalKeyboardKey.digit7: 7,
      LogicalKeyboardKey.digit8: 8,
      LogicalKeyboardKey.digit9: 9,
      LogicalKeyboardKey.numpad1: 1,
      LogicalKeyboardKey.numpad2: 2,
      LogicalKeyboardKey.numpad3: 3,
      LogicalKeyboardKey.numpad4: 4,
      LogicalKeyboardKey.numpad5: 5,
      LogicalKeyboardKey.numpad6: 6,
      LogicalKeyboardKey.numpad7: 7,
      LogicalKeyboardKey.numpad8: 8,
      LogicalKeyboardKey.numpad9: 9,
    };

    if (numberKeys.containsKey(key)) {
      if (_notesMode) {
        _board.toggleNote(numberKeys[key]!);
      } else {
        _board.placeNumber(numberKeys[key]!);
      }
    }

    // Delete / Backspace to erase
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      _board.eraseNumber();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _board,
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.difficulty.label),
            centerTitle: true,
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxGridSize =
                    constraints.maxWidth < constraints.maxHeight * 0.65
                        ? constraints.maxWidth
                        : constraints.maxHeight * 0.65;

                return Center(
                  child: SizedBox(
                    width: maxGridSize.clamp(0, 500).toDouble(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SudokuGrid(),
                        const SizedBox(height: 16),
                        _buildActionBar(),
                        const SizedBox(height: 12),
                        NumberPad(notesMode: _notesMode),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Erase button
          IconButton(
            onPressed: () => _board.eraseNumber(),
            icon: const Icon(Icons.backspace_outlined),
            tooltip: 'Erase',
          ),
          // Notes toggle
          IconButton(
            onPressed: () => setState(() => _notesMode = !_notesMode),
            icon: Icon(
              Icons.edit_note,
              color: _notesMode ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: 'Notes',
            style: _notesMode
                ? IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withAlpha(30),
                  )
                : null,
          ),
          // Clue button
          const ClueButton(),
        ],
      ),
    );
  }
}
