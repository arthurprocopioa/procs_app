import 'package:flutter/material.dart';

/// V4 (DESIGN PREMIUM): Barra de progresso refinada e minimalista.
/// Estilo "Zing": Mais fina, sem sombras pesadas, foco na elegância.
class PremiumProgressBar extends StatelessWidget {
  final double progress; // 0.0 a 1.0

  const PremiumProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Garante um progresso mínimo visível para não "sumir"
    final displayProgress = progress.clamp(0.0, 1.0);

    return Container(
      // REDUÇÃO DE ESPESSURA: De 8.0 para 4.0 (ou 2.0 se quiser ultra-fino)
      height: 4.0,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        // Fundo do trilho: Cinza muito escuro e sutil
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2.0), // Bordas arredondadas finas
      ),
      child: FractionallySizedBox(
        widthFactor: displayProgress,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 500), // Animação mais suave e lenta
          curve: Curves.fastOutSlowIn, // Curva de animação mais elegante
          decoration: BoxDecoration(
            // Cor Dourada
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2.0),
            // Sombra REMOVIDA ou muito sutil para o look "flat" e limpo
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.4),
                blurRadius: 6.0,
                offset: const Offset(0, 0), // Glow centralizado
                spreadRadius: 0.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
