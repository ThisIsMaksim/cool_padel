import '../models/player.dart';
import '../models/tournament.dart';
import '../models/user_profile.dart';

abstract final class MockData {
  static const organizerId = 'player_1';

  static final players = <Player>[
    const Player(
      id: 'player_1',
      name: 'Максим Федянин',
      rating: 1840,
      level: 'A',
      club: 'Padel Club Moscow',
      city: 'Москва',
      avatarColor: 0xFF1565C0,
    ),
    const Player(
      id: 'player_2',
      name: 'Алексей Смирнов',
      rating: 1720,
      level: 'B+',
      club: 'Padel Club Moscow',
      city: 'Москва',
      avatarColor: 0xFF2E7D52,
    ),
    const Player(
      id: 'player_3',
      name: 'Иван Петров',
      rating: 1650,
      level: 'B',
      club: 'Sky Padel',
      city: 'Москва',
      avatarColor: 0xFFC62828,
    ),
    const Player(
      id: 'player_4',
      name: 'Дмитрий Козлов',
      rating: 1580,
      level: 'B',
      club: 'Sky Padel',
      city: 'Москва',
      avatarColor: 0xFF6A1B9A,
    ),
    const Player(
      id: 'player_5',
      name: 'Сергей Волков',
      rating: 1490,
      level: 'C+',
      club: 'Luzhniki Padel',
      city: 'Москва',
      avatarColor: 0xFFEF6C00,
    ),
    const Player(
      id: 'player_6',
      name: 'Анна Белова',
      rating: 1760,
      level: 'A',
      club: 'Padel Club Moscow',
      city: 'Москва',
      avatarColor: 0xFF00838F,
    ),
    const Player(
      id: 'player_7',
      name: 'Елена Соколова',
      rating: 1610,
      level: 'B',
      club: 'Luzhniki Padel',
      city: 'Москва',
      avatarColor: 0xFFAD1457,
    ),
    const Player(
      id: 'player_8',
      name: 'Олег Морозов',
      rating: 1420,
      level: 'C',
      club: 'Sky Padel',
      city: 'Москва',
      avatarColor: 0xFF4527A0,
    ),
  ];

  static List<Tournament> tournaments() {
    final now = DateTime.now();
    return [
      Tournament(
        id: 't1',
        title: 'Weekend Open B+',
        description:
            'Открытый турнир для игроков уровня B+. Формат — олимпийская система, '
            'матчи до 2 сетов. Призы для финалистов.',
        club: 'Padel Club Moscow',
        address: 'ул. Ленинградская, 39',
        dateTime: now.add(const Duration(days: 2, hours: 10)),
        level: 'B+',
        format: TournamentFormat.doubles,
        maxParticipants: 16,
        organizerId: organizerId,
        participantIds: ['player_1', 'player_2', 'player_3', 'player_6'],
      ),
      Tournament(
        id: 't2',
        title: 'Sky Padel Singles Cup',
        description: 'Одиночный турнир уровня B. Регистрация до начала первого матча.',
        club: 'Sky Padel',
        address: 'пр. Мира, 119',
        dateTime: now.add(const Duration(days: 5, hours: 18)),
        level: 'B',
        format: TournamentFormat.singles,
        maxParticipants: 12,
        organizerId: 'player_3',
        participantIds: ['player_3', 'player_4', 'player_5'],
      ),
      Tournament(
        id: 't3',
        title: 'Luzhniki Night Padel',
        description: 'Вечерний парный турнир под открытым небом.',
        club: 'Luzhniki Padel',
        address: 'Лужники, 24',
        dateTime: now.add(const Duration(days: 1, hours: 20)),
        level: 'A',
        format: TournamentFormat.doubles,
        maxParticipants: 8,
        organizerId: 'player_6',
        participantIds: List.generate(8, (i) => players[i % 8].id),
        status: TournamentStatus.full,
      ),
      Tournament(
        id: 't4',
        title: 'Beginners Friendly',
        description: 'Турнир для новичков уровня C. Тренер на площадке.',
        club: 'Padel Club Moscow',
        address: 'ул. Ленинградская, 39',
        dateTime: now.add(const Duration(days: 7, hours: 11)),
        level: 'C',
        format: TournamentFormat.doubles,
        maxParticipants: 20,
        organizerId: organizerId,
        participantIds: ['player_5', 'player_8'],
      ),
    ];
  }

  static UserProfile demoUser({required String email, required String name}) {
    return UserProfile(
      id: 'user_${email.hashCode.abs()}',
      name: name,
      email: email,
      rating: 1840,
      level: 'A',
      club: 'Padel Club Moscow',
      city: 'Москва',
      tournamentHistory: const ['t1', 't3'],
    );
  }
}
