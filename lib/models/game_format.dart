enum GameFormat {
  doubles2x2('2×2', 'Парная игра'),
  singles1x1('1×1', 'Одиночная игра');

  const GameFormat(this.label, this.subtitle);

  final String label;
  final String subtitle;

  int get playersPerTeam => this == GameFormat.doubles2x2 ? 2 : 1;
  int get totalPlayers => playersPerTeam * 2;
}

enum CourtSide {
  left('Слева'),
  right('Справа');

  const CourtSide(this.label);

  final String label;
}
