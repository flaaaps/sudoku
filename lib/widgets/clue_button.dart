import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sudoku_board.dart';
import '../utils/constants.dart';

class ClueButton extends StatelessWidget {
  const ClueButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SudokuBoard>(
      builder: (context, board, _) {
        final remaining = board.cluesRemaining;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton.filled(
              onPressed: remaining > 0
                  ? () {
                      board.useClue();
                    }
                  : null,
              icon: const Icon(Icons.lightbulb_outline),
              style: IconButton.styleFrom(
                backgroundColor:
                    remaining > 0 ? AppColors.clueButton : Colors.grey[300],
                foregroundColor:
                    remaining > 0 ? Colors.black87 : Colors.grey[500],
              ),
              iconSize: 28,
            ),
            if (remaining > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$remaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
