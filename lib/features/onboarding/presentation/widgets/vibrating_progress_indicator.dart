import 'dart:math';
import 'package:flutter/material.dart';

class VibratingProgressIndicator extends StatefulWidget {
  final double size;
  final Duration duration;
  final Color color;
  final VoidCallback onComplete;

  const VibratingProgressIndicator({
    super.key,
    this.size = 150.0,
    required this.duration,
    required this.color,
    required this.onComplete,
  });

  @override
  State<VibratingProgressIndicator> createState() =>
      _VibratingProgressIndicatorState();
}

class _VibratingProgressIndicatorState extends State<VibratingProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _vibrationController;
  late Animation<double> _vibrationAnimation;

  @override
  void initState() {
    super.initState();

    // Controlador do progresso (0% a 100%)
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    // Controlador da vibração visual
    _vibrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50), // Vibração rápida
    );
    _vibrationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: -2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 1),
    ]).animate(_vibrationController);

    // Inicia as animações
    _progressController.forward().whenComplete(widget.onComplete);
    _vibrationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _vibrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_progressController, _vibrationController]),
      builder: (context, child) {
        final progress = _progressAnimation.value;
        final percentage = (progress * 100).toInt();
        final vibrationOffset = _vibrationAnimation.value;

        // Aplica a vibração visual apenas enquanto não completou
        final transform = progress < 1.0
            ? Matrix4.translationValues(vibrationOffset, 0.0, 0.0)
            : Matrix4.identity();

        return Transform(
          transform: transform,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                // Fundo do círculo
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.color.withOpacity(0.2),
                  ),
                ),
                // Círculo de progresso animado
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8.0,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                  strokeCap: StrokeCap.round,
                ),
                // Texto da porcentagem no centro
                Center(
                  child: Text(
                    '$percentage%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
