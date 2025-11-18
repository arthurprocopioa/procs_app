import 'package:flutter/material.dart';

/// V3 (PONTO 3): A nova barra de progresso premium.
/// Substitui o LinearProgressIndicator "ofuscado".
class PremiumProgressBar extends StatelessWidget {
  final double progress; // 0.0 a 1.0

  const PremiumProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Garante que o progresso nunca seja menor que um valor mínimo
    // para que a barra sempre tenha uma "cabeça" visível.
    final displayProgress = progress.clamp(0.02, 1.0);

    return Container(
      height: 8.0, // Altura mais "grossa"
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer, // Fundo cinza
        borderRadius: BorderRadius.circular(4.0),
      ),
      // Usa um FractionallySizedBox para "preencher" a barra
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: displayProgress,
        // AnimatedContainer para suavizar a mudança entre as telas
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary, // Cor Dourada
            borderRadius: BorderRadius.circular(4.0),
            // V3: Adiciona um brilho premium à barra
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.5),
                blurRadius: 8.0,
                spreadRadius: -2.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
