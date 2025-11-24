import 'package:flutter/material.dart';
import '../widgets/base_loading_screen.dart';
import 'result_ready_screen.dart'; // Próxima tela

class LoadingDietPlanScreen extends StatelessWidget {
  const LoadingDietPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLoadingScreen(
      title: "Montando sua dieta personalizada...",
      messages: const [
        "Calculando suas calorias...",
        "Distribuindo macronutrientes...",
        "Considerando suas restrições...",
        "Criando opções de refeições...",
        "Ajustando para sua rotina...",
      ],
      totalDuration: const Duration(seconds: 8),
      onComplete: () {
        // Fim do fluxo de onboarding, vai para o resumo
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ResultReadyScreen(),
          ),
          (route) => false, // Remove toda a pilha anterior
        );
      },
    );
  }
}
