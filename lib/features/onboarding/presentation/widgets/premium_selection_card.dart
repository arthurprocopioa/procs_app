import 'package:flutter/material.dart';

/// V3 (PONTO 7): O novo widget de Card de Seleção Premium.
/// REFACTOR FINAL: Design "Borda Pura" - Garantia de Fundo Neutro.
class PremiumSelectionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final TextAlign textAlign;
  final IconData? icon; // NOVO

  const PremiumSelectionCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.textAlign = TextAlign.left,
    this.icon, // NOVO
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Definindo a cor base explicitamente para garantir que não haja herança indesejada
    // Usamos a cor do CardTheme ou surfaceContainer se disponível
    final baseColor = theme.cardTheme.color ?? colorScheme.surfaceContainer;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          // O fundo é SEMPRE a baseColor. Nunca muda.
          color: baseColor,

          borderRadius: BorderRadius.circular(16),

          // A borda é quem brilha
          border: Border.all(
            color: isSelected
                ? colorScheme.primary // Amarelo/Dourado
                : theme.colorScheme.surfaceContainer, // Cinza/Neutro
            width: isSelected ? 2.0 : 1.0,
          ),

          // Sem sombra para evitar qualquer "glow" amarelo no fundo
          boxShadow: const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                size: 24,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                text,
                textAlign: textAlign,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  // Texto fica amarelo para indicar seleção
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
