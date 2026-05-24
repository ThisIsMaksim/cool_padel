import 'account_type.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    this.level = 'B',
    this.club = '',
    this.city = '',
    this.accountType = AccountType.personal,
    this.tournamentHistory = const [],
  });

  final String id;
  final String name;
  final String email;
  final int rating;
  final String level;
  final String club;
  final String city;
  final AccountType accountType;
  final List<String> tournamentHistory;

  bool get isClub => accountType == AccountType.club;

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
    AccountType? accountType,
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
      accountType: accountType ?? this.accountType,
      tournamentHistory: tournamentHistory ?? this.tournamentHistory,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      rating: json['rating'] as int? ?? 1500,
      level: json['level'] as String? ?? 'B',
      club: json['club'] as String? ?? '',
      city: json['city'] as String? ?? '',
      accountType: AccountType.fromApi(json['accountType'] as String?),
      tournamentHistory: (json['tournamentHistory'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}
