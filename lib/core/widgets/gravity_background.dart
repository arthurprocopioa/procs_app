import 'dart:math';
import 'package:flutter/material.dart';

class GravityBackground extends StatefulWidget {
  final Widget child;
  const GravityBackground({super.key, required this.child});

  @override
  State<GravityBackground> createState() => _GravityBackgroundState();
}

class _GravityBackgroundState extends State<GravityBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  int _particleCount = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 1), // Ticker driving the animation loops
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      final size = MediaQuery.of(context).size;
      // Initialize particles distributed across the screen
      for (int i = 0; i < _particleCount; i++) {
        _particles.add(Particle(
          random: _random,
          canvasSize: size,
        ));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Fundo Preto Absoluto
        Positioned.fill(
          child: Container(color: Colors.black),
        ),
        // 2. Partículas Animadas
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  _updateParticles(
                      Size(constraints.maxWidth, constraints.maxHeight));
                  return CustomPaint(
                    painter: ParticlePainter(
                      particles: _particles,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              );
            },
          ),
        ),
        // 3. Conteúdo da Tela
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }

  void _updateParticles(Size canvasSize) {
    for (var particle in _particles) {
      particle.update(canvasSize);
    }
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  double opacity;

  Particle({required Random random, required Size canvasSize})
      : x = random.nextDouble() * canvasSize.width,
        y = random.nextDouble() * canvasSize.height,
        size = random.nextDouble() * 3.0 + 1.0, // Tamanho entre 1 e 4
        speedX = (random.nextDouble() - 0.5) * 0.5, // Movimento lateral suave
        speedY = (random.nextDouble() - 0.5) * 0.5, // Movimento vertical suave
        opacity = random.nextDouble() * 0.5 + 0.1; // Opacidade entre 0.1 e 0.6

  void update(Size canvasSize) {
    x += speedX;
    y += speedY;

    // Bounce nas bordas (efeito de contenção) ou Wrap (efeito de fluxo)
    // Vamos usar Wrap para um fluxo contínuo
    if (x < 0) x = canvasSize.width;
    if (x > canvasSize.width) x = 0;
    if (y < 0) y = canvasSize.height;
    if (y > canvasSize.height) y = 0;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;

  ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
