enum MatchMode {
  standard('Стандартный', 'Сеты, геймы, счёт 15-30-40'),
  tournament('Турнирный', 'Суммарный лимит очков');

  const MatchMode(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
