enum DeuceRule {
  advantage('Преимущество', 'Классические правила deuce / AD'),
  goldenPoint('Золотой мяч', 'После возврата с AD на 40:40 следующее очко решает гейм');

  const DeuceRule(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
