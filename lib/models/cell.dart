class Cell {
  int? value;
  final bool isGiven;
  bool isRevealed;
  Set<int> notes;

  Cell({
    this.value,
    this.isGiven = false,
    this.isRevealed = false,
    Set<int>? notes,
  }) : notes = notes ?? {};

  bool get isEditable => !isGiven && !isRevealed;
}
