import 'dart:math';
import 'package:flutter/foundation.dart';
import 'cell.dart';
import 'difficulty.dart';
import '../services/sudoku_generator.dart';

class SudokuBoard extends ChangeNotifier {
  late List<List<int>> _solution;
  late List<List<Cell>> cells;
  late Difficulty difficulty;
  int cluesRemaining = 3;
  int? selectedRow;
  int? selectedCol;
  bool isComplete = false;

  final _generator = SudokuGenerator();

  SudokuBoard({required this.difficulty}) {
    _initBoard();
  }

  void _initBoard() {
    _solution = _generator.generateSolution();
    final puzzle = _generator.generatePuzzle(
      _solution,
      difficulty.cellsToRemove,
    );

    cells = List.generate(9, (row) {
      return List.generate(9, (col) {
        final value = puzzle[row][col];
        return Cell(
          value: value == 0 ? null : value,
          isGiven: value != 0,
        );
      });
    });
  }

  void selectCell(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  void placeNumber(int number) {
    if (selectedRow == null || selectedCol == null) return;
    final cell = cells[selectedRow!][selectedCol!];
    if (!cell.isEditable) return;

    cell.value = number;
    cell.notes.clear();
    _checkCompletion();
    notifyListeners();
  }

  void eraseNumber() {
    if (selectedRow == null || selectedCol == null) return;
    final cell = cells[selectedRow!][selectedCol!];
    if (!cell.isEditable) return;

    cell.value = null;
    notifyListeners();
  }

  void toggleNote(int number) {
    if (selectedRow == null || selectedCol == null) return;
    final cell = cells[selectedRow!][selectedCol!];
    if (!cell.isEditable) return;

    if (cell.notes.contains(number)) {
      cell.notes.remove(number);
    } else {
      cell.value = null;
      cell.notes.add(number);
    }
    notifyListeners();
  }

  bool useClue() {
    if (cluesRemaining <= 0) return false;

    final emptyCells = <List<int>>[];
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (cells[r][c].value == null ||
            cells[r][c].value != _solution[r][c]) {
          if (cells[r][c].isEditable) {
            emptyCells.add([r, c]);
          }
        }
      }
    }

    if (emptyCells.isEmpty) return false;

    final random = Random();
    final target = emptyCells[random.nextInt(emptyCells.length)];
    final row = target[0];
    final col = target[1];

    cells[row][col].value = _solution[row][col];
    cells[row][col].isRevealed = true;
    cells[row][col].notes.clear();
    cluesRemaining--;

    selectedRow = row;
    selectedCol = col;

    _checkCompletion();
    notifyListeners();
    return true;
  }

  bool hasConflict(int row, int col) {
    final value = cells[row][col].value;
    if (value == null) return false;

    // Check row
    for (var c = 0; c < 9; c++) {
      if (c != col && cells[row][c].value == value) return true;
    }

    // Check column
    for (var r = 0; r < 9; r++) {
      if (r != row && cells[r][col].value == value) return true;
    }

    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (var r = boxRow; r < boxRow + 3; r++) {
      for (var c = boxCol; c < boxCol + 3; c++) {
        if (r != row && c != col && cells[r][c].value == value) return true;
      }
    }

    return false;
  }

  void _checkCompletion() {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (cells[r][c].value != _solution[r][c]) return;
      }
    }
    isComplete = true;
  }
}
