import 'package:flutter/material.dart';
import '../widgets/base_loading_screen.dart';
import 'diet_restrictions_screen.dart'; // Próxima tela

class LoadingTrainPlanScreen extends StatelessWidget {
  const LoadingTrainPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLoadingScreen(
      title: "Criando seu plano de treino...",
      messages: const [
        "Analisando sua frequência...",
        "Selecionando os melhores exercícios...",
        "Ajustando volume e intensidade...",
        "Calculando tempo de descanso...",
        "Personalizando para seu objetivo...",
      ],
      totalDuration: const Duration(seconds: 8),
      onComplete: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DietRestrictionsScreen(),
          ),
        );
      },
    );
  }
}
