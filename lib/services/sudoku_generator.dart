import 'dart:math';

class SudokuGenerator {
  final _random = Random();

  /// Generate a complete, valid 9x9 Sudoku solution.
  List<List<int>> generateSolution() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fill(grid);
    return grid;
  }

  bool _fill(List<List<int>> grid) {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          final candidates = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(_random);
          for (final num in candidates) {
            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (_fill(grid)) return true;
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Generate a puzzle by removing [cellsToRemove] cells from a solution,
  /// ensuring the puzzle still has a unique solution.
  List<List<int>> generatePuzzle(List<List<int>> solution, int cellsToRemove) {
    final puzzle = List.generate(
      9,
      (r) => List.generate(9, (c) => solution[r][c]),
    );

    final positions = <List<int>>[];
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        positions.add([r, c]);
      }
    }
    positions.shuffle(_random);

    var removed = 0;
    for (final pos in positions) {
      if (removed >= cellsToRemove) break;

      final row = pos[0];
      final col = pos[1];
      final backup = puzzle[row][col];
      puzzle[row][col] = 0;

      if (_countSolutions(puzzle, 2) == 1) {
        removed++;
      } else {
        puzzle[row][col] = backup;
      }
    }

    return puzzle;
  }

  /// Count solutions up to [limit]. Returns the count (capped at limit).
  int _countSolutions(List<List<int>> grid, int limit) {
    final copy = List.generate(9, (r) => List.generate(9, (c) => grid[r][c]));
    var count = 0;
    _solve(copy, limit, (n) => count = n);
    return count;
  }

  bool _solve(List<List<int>> grid, int limit, void Function(int) onCount,
      [int count = 0]) {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          for (var num = 1; num <= 9; num++) {
            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (_solve(grid, limit, onCount, count)) return true;
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    count++;
    onCount(count);
    return count >= limit;
  }

  bool _isValid(List<List<int>> grid, int row, int col, int num) {
    for (var i = 0; i < 9; i++) {
      if (grid[row][i] == num) return false;
      if (grid[i][col] == num) return false;
    }

    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (var r = boxRow; r < boxRow + 3; r++) {
      for (var c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == num) return false;
      }
    }

    return true;
  }
}
