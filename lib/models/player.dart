class Player {
  const Player({
    required this.id,
    required this.name,
    required this.rating,
    this.level = 'B',
    this.club = '',
    this.city = '',
    this.avatarColor,
  });

  final String id;
  final String name;
  final int rating;
  final String level;
  final String club;
  final String city;
  final int? avatarColor;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Player copyWith({
    String? name,
    int? rating,
    String? level,
    String? club,
    String? city,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      level: level ?? this.level,
      club: club ?? this.club,
      city: city ?? this.city,
      avatarColor: avatarColor,
    );
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: json['rating'] as int? ?? 1500,
      level: json['level'] as String? ?? 'B',
      club: json['club'] as String? ?? '',
      city: json['city'] as String? ?? '',
      avatarColor: json['avatarColor'] as int?,
    );
  }
}
