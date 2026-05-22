enum MatchMode {
  standard('Классический', 'До 2 сетов по теннисным правилам'),
  tournament('Турнирный', 'До суммы очков, 1 мяч = 1 балл');

  const MatchMode(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
