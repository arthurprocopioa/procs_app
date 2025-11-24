import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/vibrating_progress_indicator.dart';

class BaseLoadingScreen extends StatefulWidget {
  final String title;
  final List<String> messages;
  final Duration totalDuration;
  final VoidCallback onComplete;

  const BaseLoadingScreen({
    super.key,
    required this.title,
    required this.messages,
    required this.totalDuration,
    required this.onComplete,
  });

  @override
  State<BaseLoadingScreen> createState() => _BaseLoadingScreenState();
}

class _BaseLoadingScreenState extends State<BaseLoadingScreen> {
  int _currentMessageIndex = 0;
  late Timer _messageTimer;

  @override
  void initState() {
    super.initState();
    // Timer para trocar as mensagens a cada 2 segundos
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentMessageIndex =
            (_currentMessageIndex + 1) % widget.messages.length;
      });
    });
  }

  @override
  void dispose() {
    _messageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto imersivo
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título Principal
              Text(
                widget.title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Novo Indicador de Progresso Vibrante
              VibratingProgressIndicator(
                duration: widget.totalDuration,
                color: theme.colorScheme.primary,
                onComplete: widget.onComplete,
              ),
              const SizedBox(height: 40),

              // Texto "Carregando..."
              Text(
                "Carregando...",
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),

              // Frases que mudam com animação suave
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  widget.messages[_currentMessageIndex],
                  key: ValueKey<int>(_currentMessageIndex),
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
