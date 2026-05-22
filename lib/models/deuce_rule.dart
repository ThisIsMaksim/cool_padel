enum DeuceRule {
  advantage('Преимущество', 'Классические правила deuce / AD'),
  goldenPoint('Золотой мяч', 'При 40:40 следующее очко выигрывает гейм');

  const DeuceRule(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
