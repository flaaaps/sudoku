import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sudoku_board.dart';
import '../utils/constants.dart';

class SudokuCellWidget extends StatelessWidget {
  final int row;
  final int col;

  const SudokuCellWidget({
    super.key,
    required this.row,
    required this.col,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SudokuBoard>(
      builder: (context, board, _) {
        final cell = board.cells[row][col];
        final isSelected = board.selectedRow == row && board.selectedCol == col;
        final isInSelectedRowOrCol =
            board.selectedRow == row || board.selectedCol == col;
        final isInSelectedBox = board.selectedRow != null &&
            board.selectedCol != null &&
            (row ~/ 3 == board.selectedRow! ~/ 3) &&
            (col ~/ 3 == board.selectedCol! ~/ 3);
        final hasConflict = cell.value != null && board.hasConflict(row, col);

        // Highlight cells with the same value as selected cell
        final selectedValue = (board.selectedRow != null &&
                board.selectedCol != null)
            ? board.cells[board.selectedRow!][board.selectedCol!].value
            : null;
        final isSameValue =
            selectedValue != null && cell.value == selectedValue && !isSelected;

        Color bgColor;
        if (isSelected) {
          bgColor = AppColors.cellSelected;
        } else if (isSameValue) {
          bgColor = AppColors.cellSelected.withAlpha(150);
        } else if (isInSelectedRowOrCol || isInSelectedBox) {
          bgColor = AppColors.cellHighlight;
        } else {
          bgColor = AppColors.cellDefault;
        }

        if (hasConflict && !cell.isGiven) {
          bgColor = AppColors.cellError;
        }

        Color textColor;
        if (hasConflict && !cell.isGiven) {
          textColor = AppColors.textError;
        } else if (cell.isGiven) {
          textColor = AppColors.textGiven;
        } else if (cell.isRevealed) {
          textColor = AppColors.textRevealed;
        } else {
          textColor = AppColors.textPlayer;
        }

        return GestureDetector(
          onTap: () => board.selectCell(row, col),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: _buildCellBorder(),
            ),
            child: Center(
              child: cell.value != null
                  ? Text(
                      '${cell.value}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            cell.isGiven ? FontWeight.bold : FontWeight.w500,
                        color: textColor,
                      ),
                    )
                  : cell.notes.isNotEmpty
                      ? _buildNotes(cell.notes)
                      : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotes(Set<int> notes) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(1),
      children: List.generate(9, (i) {
        final num = i + 1;
        return Center(
          child: Text(
            notes.contains(num) ? '$num' : '',
            style: const TextStyle(
              fontSize: 8,
              color: Colors.grey,
            ),
          ),
        );
      }),
    );
  }

  Border _buildCellBorder() {
    return Border(
      top: BorderSide(
        color: row % 3 == 0 ? AppColors.gridLine : AppColors.gridLineLight,
        width: row % 3 == 0 ? 2.0 : 0.5,
      ),
      left: BorderSide(
        color: col % 3 == 0 ? AppColors.gridLine : AppColors.gridLineLight,
        width: col % 3 == 0 ? 2.0 : 0.5,
      ),
      right: BorderSide(
        color: col == 8 ? AppColors.gridLine : Colors.transparent,
        width: col == 8 ? 2.0 : 0,
      ),
      bottom: BorderSide(
        color: row == 8 ? AppColors.gridLine : Colors.transparent,
        width: row == 8 ? 2.0 : 0,
      ),
    );
  }
}
