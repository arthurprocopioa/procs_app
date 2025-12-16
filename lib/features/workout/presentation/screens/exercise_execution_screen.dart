import 'package:flutter/material.dart';

class ExerciseExecutionScreen extends StatelessWidget {
  final String exerciseName;

  const ExerciseExecutionScreen({super.key, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Immersive black
      appBar: AppBar(
        title: Text(exerciseName),
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Placeholder
            Container(
              height: 250,
              color: Colors.grey[900],
              child: const Center(
                child: Icon(Icons.play_circle_fill,
                    size: 64, color: Colors.white54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Descrição Técnica",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "• Mantenha a postura ereta.\n• Controle a respiração.\n• Execute o movimento completo.",
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Erros Comuns",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "• Balançar o tronco.\n• Usar carga excessiva.",
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
