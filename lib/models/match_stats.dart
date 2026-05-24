class MatchStats {
  const MatchStats({
    this.totalGames = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.winRate = 0,
    this.currentStreak = 0,
    this.bestWinStreak = 0,
  });

  final int totalGames;
  final int wins;
  final int losses;
  final int draws;
  final int winRate;
  final int currentStreak;
  final int bestWinStreak;

  factory MatchStats.fromJson(Map<String, dynamic> json) {
    return MatchStats(
      totalGames: json['totalGames'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      winRate: json['winRate'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestWinStreak: json['bestWinStreak'] as int? ?? 0,
    );
  }

  factory MatchStats.empty() => const MatchStats();
}
