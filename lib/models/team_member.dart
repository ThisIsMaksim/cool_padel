import 'game_format.dart';
import 'player.dart';

class TeamMember {
  const TeamMember({
    required this.playerId,
    required this.name,
    this.side,
  });

  final String playerId;
  final String name;
  final CourtSide? side;

  factory TeamMember.fromPlayer(Player player, {CourtSide? side}) {
    return TeamMember(
      playerId: player.id,
      name: player.name,
      side: side,
    );
  }

  String get shortName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : name;
  }

  String get displayWithSide {
    if (side == null) return name;
    return '$name (${side!.label})';
  }

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'name': name,
        if (side != null) 'side': side!.name,
      };

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      playerId: json['playerId'] as String,
      name: json['name'] as String,
      side: json['side'] != null
          ? CourtSide.values.byName(json['side'] as String)
          : null,
    );
  }
}
