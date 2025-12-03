import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Para ícones finos estilo iOS

/// V4.1 (DESIGN ULTRA-MINIMALISTA): Botão de voltar refinado.
/// Remove todo o padding e splash, focando apenas no ícone fino.
class ProcsBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;

  const ProcsBackButton({
    super.key,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.onSurface;

    return InkWell(
      // Efeito de toque (opcional, pode ser Colors.transparent)
      splashColor: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
      highlightColor: Colors.transparent,

      onTap: onPressed ?? () => Navigator.of(context).maybePop(),

      // O Container garante que a área de toque não seja microscópica,
      // mas visualmente o botão continua pequeno.
      child: Container(
        padding: const EdgeInsets.all(8.0), // Padding visual menor
        child: Icon(
          CupertinoIcons.arrow_left, // Ícone fino e minimalista
          size: 24,
          color: iconColor,
        ),
      ),
    );
  }
}
