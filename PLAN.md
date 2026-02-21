# Flutter Sudoku App — Implementation Plan

## Overview

A cross-platform Flutter Sudoku app with a home screen for difficulty selection, a playable 9x9 Sudoku board, and a clue/hint system (3 per game).

---

## Architecture

```
lib/
├── main.dart                    # App entry point, theme, routing
├── models/
│   ├── sudoku_board.dart        # Board state: solution grid, puzzle grid, player grid
│   ├── cell.dart                # Cell model (value, isGiven, isRevealed, notes)
│   └── difficulty.dart          # Difficulty enum (easy/medium/hard/expert)
├── services/
│   └── sudoku_generator.dart    # Puzzle generation & solving logic
├── screens/
│   ├── home_screen.dart         # Title, "New Game" button, difficulty picker
│   └── game_screen.dart         # Board + number pad + clue button + timer
├── widgets/
│   ├── sudoku_grid.dart         # 9x9 grid widget with 3x3 box borders
│   ├── sudoku_cell.dart         # Individual cell (tap to select, display value)
│   ├── number_pad.dart          # 1-9 buttons + erase button
│   └── clue_button.dart         # Hint/clue button with remaining count badge
└── utils/
    └── constants.dart           # Colors, text styles, sizing constants
```

---

## Step-by-Step Implementation

### Step 1 — Project Scaffolding

- Run `flutter create` to initialize the project in the repo
- Clean up boilerplate (remove counter app code)
- Set up `pubspec.yaml` with the single dependency: `provider` (for state management)
- Configure theme (Material 3, light theme with Sudoku-friendly colors)

### Step 2 — Data Models

**`difficulty.dart`**
- Enum: `easy`, `medium`, `hard`, `expert`
- Each maps to a number of cells to remove: easy ~36, medium ~45, hard ~50, expert ~55

**`cell.dart`**
- Fields: `value` (int?), `isGiven` (bool), `isRevealed` (bool — set when clue used), `notes` (Set<int>)
- Given cells and revealed cells are non-editable

**`sudoku_board.dart`**
- Fields: `solution` (List<List<int>>), `cells` (List<List<Cell>>), `difficulty`, `cluesRemaining` (starts at 3), `selectedRow`, `selectedCol`
- Extends `ChangeNotifier` for Provider-based reactivity
- Methods:
  - `selectCell(row, col)` — update selection
  - `placeNumber(int n)` — set value on selected cell (if not given/revealed)
  - `eraseNumber()` — clear selected cell
  - `useClue()` — pick a random empty cell, reveal its solution value, decrement cluesRemaining
  - `isComplete()` — check if board matches solution
  - `hasConflict(row, col)` — check row/col/box for duplicates (for error highlighting)

### Step 3 — Sudoku Generator Service

**`sudoku_generator.dart`**
- `generateSolution()` — build a valid complete 9x9 grid using backtracking with randomized candidates
- `generatePuzzle(difficulty)` — take a complete solution and remove N cells (based on difficulty) to create the puzzle, ensuring a unique solution exists
- `solve(grid)` — backtracking solver (used to verify uniqueness during generation)

Algorithm:
1. Fill the board using recursive backtracking with shuffled 1-9 candidates
2. Remove cells one at a time in random order
3. After each removal, verify the puzzle still has exactly one solution
4. Stop when the target number of blanks is reached

### Step 4 — Home Screen

**`home_screen.dart`**
- App title / logo at top
- "New Game" prominent button
- On tap: show a bottom sheet or dialog with difficulty options (Easy, Medium, Hard, Expert)
- On difficulty selection: navigate to GameScreen with chosen difficulty

### Step 5 — Game Screen & Widgets

**`game_screen.dart`**
- `ChangeNotifierProvider<SudokuBoard>` wrapping the screen
- Layout (column):
  1. App bar with back button and timer display
  2. Sudoku grid (centered, square aspect ratio)
  3. Clue button with badge showing remaining clues
  4. Number pad row

**`sudoku_grid.dart`**
- 9x9 `GridView` or `Table` with thick borders every 3 cells
- Each cell listens to board state via `Consumer`/`context.watch`
- Selected cell gets a highlight color
- Conflict cells get red text
- Given numbers are bold/dark; player-entered numbers are lighter/blue

**`sudoku_cell.dart`**
- `GestureDetector` wrapping a styled `Container`
- Displays number or blank
- Visual states: default, selected, same-number highlight, error, given, revealed

**`number_pad.dart`**
- Row of buttons 1-9 plus an erase/backspace button
- Tapping a number calls `board.placeNumber(n)`
- Tapping erase calls `board.eraseNumber()`

**`clue_button.dart`**
- Icon button (lightbulb) with a badge showing `cluesRemaining`
- Disabled when 0 clues remain
- On tap: calls `board.useClue()`, animates the revealed cell briefly

### Step 6 — Game Logic & Validation

- Real-time conflict detection: when a number is placed, highlight conflicting cells in the same row, column, or 3x3 box
- Completion check: after each placement, check if the board is fully and correctly filled
- Win dialog: show a congratulations dialog with option to return home or start new game

### Step 7 — Polish & Cross-Platform

- Responsive layout: board scales to available width, max size capped for large screens
- Keyboard support (desktop): arrow keys to move selection, number keys to input
- Touch support (mobile): tap cell to select, tap number pad to input
- Consistent look on iOS, Android, Web, macOS, Windows, Linux

---

## State Management

Using **Provider** with a single `ChangeNotifier` (`SudokuBoard`):
- Simple, minimal boilerplate
- Board model holds all game state
- Widgets rebuild via `Consumer<SudokuBoard>` or `context.watch<SudokuBoard>()`

---

## Clue/Hint System

- 3 clues per game (non-configurable, as specified)
- `useClue()` implementation:
  1. Collect all cells where `cell.value == null` (empty cells)
  2. Pick one at random
  3. Set `cell.value = solution[row][col]`
  4. Mark `cell.isRevealed = true` (non-editable, visually distinct)
  5. Decrement `cluesRemaining`
  6. Call `notifyListeners()`

---

## Key Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| State management | Provider | Minimal dependency, sufficient for single-screen game state |
| Puzzle generation | Backtracking + cell removal | Guarantees valid, unique-solution puzzles |
| Grid rendering | Custom Table widget | Better control over 3x3 box borders than GridView |
| Clue target | Random empty cell | Simple, fair, no strategic optimization needed |
| No external puzzle DB | Generate on-device | Works offline, no server dependency |

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
```

No other external packages needed. The generator, solver, and all UI are built from scratch.
