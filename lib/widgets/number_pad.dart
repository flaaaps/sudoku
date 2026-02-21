import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sudoku_board.dart';

class NumberPad extends StatelessWidget {
  final bool notesMode;

  const NumberPad({super.key, this.notesMode = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...List.generate(9, (i) {
            final number = i + 1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AspectRatio(
                  aspectRatio: 0.85,
                  child: ElevatedButton(
                    onPressed: () {
                      final board = context.read<SudokuBoard>();
                      if (notesMode) {
                        board.toggleNote(number);
                      } else {
                        board.placeNumber(number);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
