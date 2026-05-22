enum TournamentFormat { singles, doubles }

enum TournamentStatus { open, full, finished }

class Tournament {
  Tournament({
    required this.id,
    required this.title,
    required this.description,
    required this.club,
    required this.address,
    required this.dateTime,
    required this.level,
    required this.format,
    required this.maxParticipants,
    required this.organizerId,
    List<String>? participantIds,
    List<String>? waitlistIds,
    this.status = TournamentStatus.open,
  })  : participantIds = List.unmodifiable(participantIds ?? []),
        waitlistIds = List.unmodifiable(waitlistIds ?? []);

  final String id;
  final String title;
  final String description;
  final String club;
  final String address;
  final DateTime dateTime;
  final String level;
  final TournamentFormat format;
  final int maxParticipants;
  final String organizerId;
  final List<String> participantIds;
  final List<String> waitlistIds;
  TournamentStatus status;

  bool get isFull => participantIds.length >= maxParticipants;

  int get freeSlots => (maxParticipants - participantIds.length).clamp(0, maxParticipants);

  String get formatLabel =>
      format == TournamentFormat.doubles ? 'Парный' : 'Одиночный';

  Tournament copyWith({
    List<String>? participantIds,
    List<String>? waitlistIds,
    TournamentStatus? status,
  }) {
    return Tournament(
      id: id,
      title: title,
      description: description,
      club: club,
      address: address,
      dateTime: dateTime,
      level: level,
      format: format,
      maxParticipants: maxParticipants,
      organizerId: organizerId,
      participantIds: participantIds ?? this.participantIds,
      waitlistIds: waitlistIds ?? this.waitlistIds,
      status: status ?? this.status,
    );
  }
}
