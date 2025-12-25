import 'dart:ui';
import 'package:flutter/material.dart';

class ProcsGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? color;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ProcsGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.color,
    this.border,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    // Cor base padrão (branco ou preto dependendo do tema seria ideal, mas passamos via parametro ou usamos default)
    // Para efeito "Liquid Glass" universal, um branco com baixa opacidade geralmente funciona bem em modos dark/vibra.
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.surface.withOpacity(opacity);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.0,
                  ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
