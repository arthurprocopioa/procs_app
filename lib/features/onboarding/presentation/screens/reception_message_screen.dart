import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/onboarding_provider.dart';
import 'vital_data_screen.dart'; // O próximo passo
import '../../../../core/services/haptic_service.dart'; // V3: Haptics

class ReceptionMessageScreen extends StatefulWidget {
  const ReceptionMessageScreen({super.key});

  @override
  State<ReceptionMessageScreen> createState() => _ReceptionMessageScreenState();
}

class _ReceptionMessageScreenState extends State<ReceptionMessageScreen>
    with TickerProviderStateMixin {
  final List<String> _pitchMessages = [];
  final List<String> _displayedMessages = [];
  bool _showContinueButton = false;
  int _currentMessageIndex = 0;

  late AnimationController _textController;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();

    // Pega o nome do provider
    final String userName =
        context.read<OnboardingProvider>().data.name ?? "Usuário";

    // V3 (NOVO PITCH): Mais curto, mais rápido, mais forte.
    _pitchMessages.addAll([
      "E aí, $userName. Sou eu, o Procs AI.",
      "Vamos ser diretos: você não precisa de mim pra ter um 'plano de treino'. O ChatGPT faz isso de graça.",
      "O meu trabalho é outro.\nEu sou um **sistema de execução**.",
      "Vamos transformar isso num jogo. Você vai ganhar XP, competir em 'Temporadas' e ganhar **prêmios reais** (whey, creatina, roupas).",
      "Vou te acompanhar, enviar notificações inteligentes e ajustar seu plano em tempo real.",
      "Minha única missão é fazer você **não quebrar a corrente**."
    ]);

    // Preenche a lista de exibição com strings vazias
    _displayedMessages.addAll(List.filled(_pitchMessages.length, ""));

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Duração da digitação
    );

    // Inicia a sequência de animação
    _startNextMessageAnimation();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// V3 (NOVO): Inicia a animação de digitação para a próxima mensagem
  void _startNextMessageAnimation() {
    if (_currentMessageIndex >= _pitchMessages.length) {
      // Todas as mensagens foram exibidas
      setState(() => _showContinueButton = true);
      HapticService.lightImpact();
      return;
    }

    final String message = _pitchMessages[_currentMessageIndex];
    _textAnimation = IntTween(begin: 0, end: message.length).animate(
      CurvedAnimation(parent: _textController, curve: Curves.linear),
    )..addListener(() {
        setState(() {
          _displayedMessages[_currentMessageIndex] =
              message.substring(0, _textAnimation.value);
        });
      });

    _textController.reset();
    _textController.forward().whenComplete(() {
      // Mensagem concluída
      HapticService.lightImpact();
      _currentMessageIndex++;
      // Pequena pausa antes da próxima mensagem
      Future.delayed(
          const Duration(milliseconds: 500), _startNextMessageAnimation);
    });
  }

  /// V3 (NOVO): Ação do botão "Continuar"
  void _onNext() {
    HapticService.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VitalDataScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // V3 (NOVO): Fundo preto puro para imersão total
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // V3 (NOVO): Avatar da IA com pulso
                  const _AiAvatar(),
                  const SizedBox(height: 32),

                  // V3 (NOVO): Área de texto com animação
                  Expanded(
                    child: ListView.builder(
                      itemCount: _displayedMessages.length,
                      itemBuilder: (context, index) {
                        // Não mostra a caixa até que a animação comece
                        if (_displayedMessages[index].isEmpty &&
                            index > _currentMessageIndex) {
                          return const SizedBox.shrink();
                        }
                        return _buildAnimatedText(
                          theme,
                          _displayedMessages[index],
                        );
                      },
                    ),
                  ),

                  // V3 (NOVO): Botão "Continuar" animado
                  AnimatedOpacity(
                    opacity: _showContinueButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: IgnorePointer(
                      ignoring: !_showContinueButton,
                      child: ElevatedButton(
                        onPressed: _onNext,
                        child: const Text("Vamos começar"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // V3 (NOVO): Botão de voltar flutuante
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BackButton(
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }

  /// V3 (NOVO): Helper para construir o texto animado
  Widget _buildAnimatedText(ThemeData theme, String text) {
    // Lógica para o Markdown simples (**bold**)
    final parts = text.split('**');
    List<TextSpan> textSpans = [];

    for (int i = 0; i < parts.length; i++) {
      final bool isBold = i % 2 == 1;
      textSpans.add(
        TextSpan(
            text: parts[i],
            style: (isBold
                    ? theme.textTheme.headlineSmall
                    : theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w400))
                ?.copyWith(
              // V3: Texto da IA tem um leve brilho dourado para ser premium
              color: isBold
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              shadows: isBold
                  ? [
                      Shadow(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                        blurRadius: 10,
                      )
                    ]
                  : [],
            )),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: RichText(
        text: TextSpan(
          children: textSpans,
        ),
      ),
    );
  }
}

/// V3 (NOVO): Avatar da IA com animação de pulso
class _AiAvatar extends StatefulWidget {
  const _AiAvatar();

  @override
  State<_AiAvatar> createState() => _AiAvatarState();
}

class _AiAvatarState extends State<_AiAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // V3: Gradiente Dourado Premium
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.7),
              theme.colorScheme.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          // V3: Círculo interno preto para criar a borda
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: Icon(
              Icons.bolt, // Ícone da IA
              color: theme.colorScheme.primary,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
