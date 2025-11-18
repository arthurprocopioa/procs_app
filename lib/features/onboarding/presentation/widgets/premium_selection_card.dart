import 'package:flutter/material.dart';

/// V3 (PONTO 7): O novo widget de Card de Seleção Premium.
/// Substitui todos os botões de seleção customizados e inconsistentes.
/// Garante o padrão "Dourado" ao invés de "check".
class PremiumSelectionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  // V3 (PONTO 5): Por padrão, o texto é alinhado à esquerda.
  final TextAlign textAlign;

  const PremiumSelectionCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.textAlign = TextAlign.left, // Padrão de alinhamento
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      // V3: Anima a mudança de cor, borda e sombra.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1) // Fundo sutil dourado
              : theme.cardTheme.color, // Cor base do card
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : theme.colorScheme.surfaceContainer, // Borda inativa
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.15),
                    blurRadius: 12.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [], // Sem sombra
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                // V3 (PONTO 5): Aplica o alinhamento de texto
                textAlign: textAlign,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? colorScheme.primary // Texto dourado
                      : colorScheme.onSurface, // Texto padrão
                ),
              ),
            ),
            // V3 (PONTO 7): Mostra o círculo dourado (estilo rádio)
            // ao invés de um "check".
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                      color: theme.colorScheme.surfaceContainer, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
