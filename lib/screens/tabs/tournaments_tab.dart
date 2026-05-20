import 'package:flutter/material.dart';

class TournamentsTab extends StatelessWidget {
  const TournamentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Турниры')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Турниры скоро',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Здесь появится создание и управление турнирами',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
