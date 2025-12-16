import 'package:flutter/material.dart';
import '../widgets/exercise_card.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // Mock Data for "Block 1" - Week Days
  final List<String> _weekDays = [
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SAB',
    'DOM'
  ];
  int _selectedDayIndex = 0; // Monday selected by default

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Treino', style: TextStyle(color: Colors.white)),
        // Assuming this is a top level screen in navigation, we might need a back button if pushed,
        // or leading null if it's a tab. It's a tab now.
        centerTitle: true,
        leading: const Icon(Icons.arrow_back_ios,
            size: 18,
            color: Colors
                .white), // Visual only as per wireframe requests "< Treino"
        // In real nav, this might actually pop if we allow going back to onboarding? No.
        // For now, visual match.
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // BLOCO 1: Divisão da Semana (Scroll Lateral)
          SizedBox(
            height: 80,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: _weekDays.length,
              separatorBuilder: (c, i) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDayIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1A1A1A)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(color: colorScheme.primary, width: 1)
                              : Border.all(color: Colors.transparent),
                        ),
                        child: Text(
                          _weekDays[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.transparent, // Gold dot
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: Colors.grey
                                      .withOpacity(0.3)), // Empty circle
                        ),
                        // UX Update: Filled for selected, empty outline for unselected
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // BLOCO 2: Nome do Treino
                  const Text(
                    "Treino de Hoje — A",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Peito | Tríceps | Ombro",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 32), // Respiro visual

                  // BLOCO 3: Lista de Exercícios (Mock)
                  const ExerciseCard(
                    name: "Supino Reto com Barra",
                    setsReps: "4 séries | 8–10 repetições",
                    rest: "90s",
                    load: "20kg (cada lado)",
                  ),
                  const ExerciseCard(
                    name: "Desenvolvimento Halteres",
                    setsReps: "3 séries | 12 repetições",
                    rest: "60s",
                    load: "16kg",
                  ),
                  const ExerciseCard(
                    name: "Tríceps Corda",
                    setsReps: "4 séries | 15 repetições",
                    rest: "45s",
                  ),
                  const ExerciseCard(
                    name: "Elevação Lateral",
                    setsReps: "3 séries | 15-20 repetições",
                    rest: "45s",
                  ),

                  const SizedBox(height: 32),

                  // BLOCO 4: Botão Finalizar
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Treino finalizado com sucesso!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary, // Gold
                      foregroundColor: Colors.black, // Dark text on Gold
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "✔  Finalizar Treino",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
