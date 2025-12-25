import 'package:flutter/material.dart';
import '../../../../core/widgets/procs_glass_container.dart';

/// V3 (PONTO 7): O novo widget de Card de Seleção Premium.
/// REFACTOR FINAL: Design "Borda Pura" - Garantia de Fundo Neutro.
class PremiumSelectionCard extends StatelessWidget {
  final String text; // Título
  final String? subtitle; // Descrição
  final String? warningNote; // Nota de aviso (ex: "Difícil mas possível")
  final bool isSelected;
  final VoidCallback onTap;
  final TextAlign textAlign;
  final IconData? icon;

  const PremiumSelectionCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.warningNote,
    this.textAlign = TextAlign.left,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseColor = theme.cardTheme.color ?? colorScheme.surfaceContainer;

    // Conteúdo interno do card (extraído para evitar duplicação)
    Widget buildCardContent() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  textAlign: textAlign,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.bold,
                    fontSize: 16,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    textAlign: textAlign,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      height: 1.3,
                    ),
                  ),
                ],
                if (warningNote != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: Colors.orange.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline,
                            size: 12, color: Colors.orange),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            warningNote!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: isSelected
          ? ProcsGlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              border: Border.all(
                color: colorScheme.primary, // Amarelo/Dourado
                width: 2.0,
              ),
              // Cor de fundo leve para dar tom, mas mantendo a transparência do vidro
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: 16,
              blur: 15, // Efeito Liquid Glass forte
              child: buildCardContent(),
            )
          : AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.surfaceContainer,
                  width: 1.0,
                ),
                boxShadow: const [],
              ),
              child: buildCardContent(),
            ),
    );
  }
}
