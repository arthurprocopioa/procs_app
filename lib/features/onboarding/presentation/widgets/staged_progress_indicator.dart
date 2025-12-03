// import 'dart:math';
import 'package:flutter/material.dart';

class StagedProgressIndicator extends StatefulWidget {
  final double size;
  final Duration duration;
  final Color color;
  final VoidCallback onComplete;
  final List<double>? stops; // Pontos de parada (0.0 a 1.0)

  const StagedProgressIndicator({
    super.key,
    this.size = 150.0,
    required this.duration,
    required this.color,
    required this.onComplete,
    this.stops,
  });

  @override
  State<StagedProgressIndicator> createState() =>
      _StagedProgressIndicatorState();
}

class _StagedProgressIndicatorState extends State<StagedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.stops != null && widget.stops!.isNotEmpty) {
      // Cria uma sequência de Tweens com paradas
      final List<TweenSequenceItem<double>> items = [];

      // Estratégia:
      // O controller dura 'duration'. Vamos dividir o tempo proporcionalmente.
      // Cada segmento de movimento tem um peso baseado na distância percorrida.
      // Cada parada tem um peso fixo.

      final stops = [...widget.stops!, 1.0];
      // Ordena e remove duplicatas/inválidos
      stops.sort();

      double lastStop = 0.0;
      const double pauseWeight = 20.0; // Peso da pausa
      const double moveWeightBase =
          100.0; // Peso base do movimento (por unidade de progresso)

      for (final stop in stops) {
        if (stop <= lastStop) continue;

        // Movimento até o stop
        // O peso é proporcional à distância percorrida
        final distance = stop - lastStop;
        items.add(TweenSequenceItem(
          tween: Tween(begin: lastStop, end: stop)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: moveWeightBase * distance,
        ));

        // Pausa no stop (exceto se for 1.0 final)
        if (stop < 1.0) {
          items.add(TweenSequenceItem(
            tween: ConstantTween(stop),
            weight: pauseWeight,
          ));
        }

        lastStop = stop;
      }

      _progressAnimation =
          TweenSequence<double>(items).animate(_progressController);
    } else {
      // Comportamento linear padrão se não houver stops
      _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.linear),
      );
    }

    _progressController.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final progress = _progressAnimation.value;
        final percentage = (progress * 100).toInt();

        return SizedBox(
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
                  widget.color.withValues(alpha: 0.2),
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
        );
      },
    );
  }
}
