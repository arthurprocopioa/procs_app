import 'package:flutter/material.dart';
import '../screens/exercise_execution_screen.dart';

class ExerciseCard extends StatelessWidget {
  final String name;
  final String setsReps;
  final String rest;
  final String? load;

  const ExerciseCard({
    super.key,
    required this.name,
    required this.setsReps,
    required this.rest,
    this.load,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark card background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ExerciseExecutionScreen(exerciseName: name),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: colorScheme.primary, // Gold
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.repeat, setsReps),
                          if (load != null) ...[
                            const SizedBox(height: 4),
                            _buildInfoRow(Icons.monitor_weight_outlined,
                                "Carga inicial: $load"),
                          ],
                          const SizedBox(height: 4),
                          _buildInfoRow(
                              Icons.timer_outlined, "Descanso: $rest"),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Ver execução →",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFC9C9C9)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFC9C9C9),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
