enum Difficulty {
  easy(label: 'Easy', cellsToRemove: 36),
  medium(label: 'Medium', cellsToRemove: 45),
  hard(label: 'Hard', cellsToRemove: 50),
  expert(label: 'Expert', cellsToRemove: 55);

  const Difficulty({required this.label, required this.cellsToRemove});

  final String label;
  final int cellsToRemove;
}
