import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// V3 (PONTO 4): Define os estados do feedback da IA
/// (Movido para este arquivo centralizado)
enum FeedbackState { neutral, success, warning, error }

/// V3 (PONTO 4): Widget de Feedback Dinâmico com cores
/// (Movido do target_weight_screen.dart para ser reutilizável)
class AiFeedbackCard extends StatelessWidget {
  final String title;
  final String message;
  final FeedbackState state;

  const AiFeedbackCard({
    super.key,
    required this.message,
    this.title = "Feedback da IA",
    this.state = FeedbackState.neutral,
  });

  // V3 (PONTO 4): Lógica de Cor
  Color _getBorderColor(ThemeData theme) {
    switch (state) {
      case FeedbackState.error:
        return Colors.red.shade700;
      case FeedbackState.warning:
        return Colors.orange.shade700;
      case FeedbackState.success:
      case FeedbackState
            .neutral: // CORREÇÃO: Usa a cor primária mesmo em Neutral
        return theme.colorScheme.primary; // Dourado
    }
  }

  // V3 (NOVO): Lógica para cor do Título (para o brilho)
  Color _getTitleColor(ThemeData theme) {
    switch (state) {
      case FeedbackState.error:
        return Colors.red.shade400; // Um vermelho mais claro para o texto
      case FeedbackState.warning:
        return Colors.orange.shade400; // Um laranja mais claro para o texto
      case FeedbackState.success:
      case FeedbackState
            .neutral: // CORREÇÃO: Usa a cor primária mesmo em Neutral
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color borderColor = _getBorderColor(theme);
    final Color titleColor = _getTitleColor(theme);

    // V3: Anima a mudança da borda
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        // V3 (PONTO 4): A borda muda de cor
        border: Border.all(
          color: borderColor,
          width: 2.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone (CORRIGIDO: usa FontAwesomeIcons.brain ou Icon.bolt, dependendo da sua preferência)
          Icon(
            FontAwesomeIcons.brain, // Mantendo o ícone que estava no seu código
            color: titleColor, // Ícone usa a cor do título (dourado)
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: titleColor, // Título agora é sempre dourado/colorido
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
