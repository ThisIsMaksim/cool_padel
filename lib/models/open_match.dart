enum OpenMatchFormat { singles, doubles }

enum OpenMatchStatus { open, full, cancelled }

class OpenMatch {
  OpenMatch({
    required this.id,
    required this.creatorId,
    required this.club,
    required this.address,
    required this.dateTime,
    required this.level,
    required this.format,
    required this.maxPlayers,
    required this.participantIds,
    required this.status,
    this.note = '',
    this.freeSlots = 0,
  });

  final String id;
  final String creatorId;
  final String club;
  final String address;
  final DateTime dateTime;
  final String level;
  final OpenMatchFormat format;
  final int maxPlayers;
  final String note;
  final List<String> participantIds;
  final OpenMatchStatus status;
  final int freeSlots;

  bool get isOpen => status == OpenMatchStatus.open;

  String get formatLabel =>
      format == OpenMatchFormat.doubles ? 'Парный' : 'Одиночный';

  factory OpenMatch.fromJson(Map<String, dynamic> json) {
    return OpenMatch(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      club: json['club'] as String,
      address: json['address'] as String? ?? '',
      dateTime: DateTime.parse(json['dateTime'] as String),
      level: json['level'] as String,
      format: OpenMatchFormat.values.byName(json['format'] as String),
      maxPlayers: json['maxPlayers'] as int,
      note: json['note'] as String? ?? '',
      participantIds: (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: OpenMatchStatus.values.byName(json['status'] as String),
      freeSlots: json['freeSlots'] as int? ?? 0,
    );
  }
}
