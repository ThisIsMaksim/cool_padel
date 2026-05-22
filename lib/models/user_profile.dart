class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    this.level = 'B',
    this.club = '',
    this.city = '',
    this.tournamentHistory = const [],
  });

  final String id;
  final String name;
  final String email;
  final int rating;
  final String level;
  final String club;
  final String city;
  final List<String> tournamentHistory;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  UserProfile copyWith({
    String? name,
    int? rating,
    String? level,
    String? club,
    String? city,
    List<String>? tournamentHistory,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email,
      rating: rating ?? this.rating,
      level: level ?? this.level,
      club: club ?? this.club,
      city: city ?? this.city,
      tournamentHistory: tournamentHistory ?? this.tournamentHistory,
    );
  }
}
