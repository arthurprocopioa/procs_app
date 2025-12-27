import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback
import 'package:provider/provider.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

import 'dart:async'; // Para Timer

import '../../../../core/services/analytics_service.dart';
import '../../application/onboarding_provider.dart';
import 'social_proof_screen.dart';
// import '../../../../core/widgets/gravity_background.dart';

class CommitmentScreen extends StatefulWidget {
  const CommitmentScreen({super.key});

  @override
  State<CommitmentScreen> createState() => _CommitmentScreenState();
}

class _CommitmentScreenState extends State<CommitmentScreen>
    with SingleTickerProviderStateMixin {
  // Controller principal para o "Hold"
  late AnimationController _holdController;
  late ConfettiController _confettiController;

  // Estado da Digitação
  String _displayedText = "";
  String _fullText = "";
  Timer? _typingTimer;
  int _typingIndex = 0;

  // Estado
  bool _isCompleted = false; // Se o ritual foi finalizado

  // Cores
  final Color _rippleColor = const Color(0xFFD4AF37); // Dourado (Brand)
  final Color _buttonColor = const Color(0xFFFFFFFF); // Branco (CTA Padrão)

  @override
  void initState() {
    super.initState();

    // Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('commitment_ritual_messenger');
    });

    // Configuração da Animação de Hold (3 segundos para completar)
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Listener para detectar o fim do hold
    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onRitualComplete();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Inicia a digitação apenas se ainda não começou
    if (_fullText.isEmpty) {
      final provider = context.read<OnboardingProvider>();
      final userName = provider.data.name ?? "Atleta";

      _fullText =
          "Eu, $userName,\n\nAssumo o compromisso de superar meus limites diariamente, honrar meu corpo e permanecer firme mesmo quando a motivação falhar.\n\nNão busco perfeição — busco progresso.\n\nE a partir de hoje, estou totalmente alinhado com a minha evolução.";

      _startTyping();
    }
  }

  void _startTyping() {
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_typingIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_typingIndex];
          _typingIndex++;
        });
        // Haptic leve a cada caractere para efeito tátil (opcional, pode ser removido se ficar muito intenso)
        if (_typingIndex % 3 == 0) HapticFeedback.lightImpact();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    _confettiController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  // --- LÓGICA DE INTERAÇÃO ---

  void _onPressStart() {
    if (_isCompleted) return;
    HapticFeedback.mediumImpact();
    _holdController.forward();
  }

  void _onPressEnd() {
    if (_isCompleted) return;
    // Se soltar antes de terminar, cancela (reverte)
    if (_holdController.status != AnimationStatus.completed) {
      _holdController.reverse();
    }
  }

  void _onRitualComplete() {
    setState(() {
      _isCompleted = true;
    });
    HapticFeedback.heavyImpact();
    _confettiController.play();
    context.read<AnalyticsService>().trackEvent('commitment_signed_messenger');
  }

  void _onNext() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SocialProofScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Raio máximo para cobrir a tela (diagonal a partir do centro-inferior)
    final maxRadius =
        math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. FUNDO & CONTEÚDO INICIAL (Desvanece conforme o progresso)
          AnimatedBuilder(
            animation: _holdController,
            builder: (context, child) {
              // Opacidade inversa ao progresso (1.0 -> 0.0)
              // Aceleramos um pouco o fade out para sumir antes de cobrir tudo
              final opacity =
                  (1.0 - (_holdController.value * 1.2)).clamp(0.0, 1.0);
              return Opacity(
                opacity: opacity,
                child: _buildContractContent(context),
              );
            },
          ),

          // 2. EXPANDING CIRCLE (O Overlay Dourado)
          AnimatedBuilder(
            animation: _holdController,
            builder: (context, child) {
              // Curva suave para a expansão
              final value =
                  Curves.easeInOutCubic.transform(_holdController.value);

              // Começa do tamanho do botão (raio 40) e cresce
              final startRadius = 40.0;
              final radius = startRadius + (value * maxRadius);

              // Interpolação de cor: Do Branco (Botão) para o Dourado (Brand)
              final currentColor =
                  Color.lerp(_buttonColor, _rippleColor, value) ?? _rippleColor;

              // Se não começou, não desenha nada
              if (value == 0) return const SizedBox.shrink();

              // Centro do botão: Bottom Spacing (120) + Metade do Botão (40) = 160
              const buttonCenterY = 160.0;

              return Positioned(
                bottom: buttonCenterY - radius,
                left: size.width / 2 - radius,
                child: Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          // 3. TEXTO DINÂMICO (Feedback durante o hold)
          if (!_isCompleted)
            AnimatedBuilder(
              animation: _holdController,
              builder: (context, child) {
                final value = _holdController.value;
                if (value <= 0.05)
                  return const SizedBox.shrink(); // Só mostra se começou

                String text = "Continue segurando!";
                if (value > 0.6) text = "Quase lá...";

                // Posição: um pouco acima do centro do botão, subindo conforme expande
                final bottomOffset = 260 + (value * 100);

                return Positioned(
                  bottom: bottomOffset,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0), // Aparece conforme segura
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black, // Contraste com o Dourado
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

          // 4. CONFETTI (No topo, cai sobre tudo)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2, // Para baixo
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                Color(0xFFD4AF37), // Dourado
                Colors.white,
                Colors.black,
              ],
            ),
          ),

          // 5. TELA DE SUCESSO (Fade In após completar)
          if (_isCompleted)
            Positioned.fill(
              child: _buildSuccessState(context)
                  .animate()
                  .fade(duration: 800.ms, curve: Curves.easeOut),
            ),

          // 6. GATILHO INVISÍVEL (Para manter a interação mesmo quando o botão some visualmente)
          // Precisamos garantir que o usuário continue segurando
          if (!_isCompleted)
            Positioned(
              bottom: 120, // Área do botão original (Atualizado)
              left: 0,
              right: 0,
              height: 160, // Área de toque generosa
              child: GestureDetector(
                behavior: HitTestBehavior
                    .translucent, // Pega toques mesmo transparente
                onTapDown: (_) => _onPressStart(),
                onTapUp: (_) => _onPressEnd(),
                onTapCancel: _onPressEnd,
                child: Container(color: Colors.transparent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContractContent(BuildContext context) {
    final theme = Theme.of(context);
    // final provider = context.watch<OnboardingProvider>(); // Removido pois não é mais usado aqui
    // final userName = provider.data.name ?? "Atleta"; // Removido pois agora é usado no didChangeDependencies

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header REMOVIDO conforme solicitado

            const Spacer(),

            // Texto com efeito de digitação
            SizedBox(
              height: 300, // Altura fixa para evitar pulos no layout
              child: Center(
                child: Text(
                  _displayedText,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const Spacer(),

            // Área do Gatilho (Visual)
            Column(
              children: [
                Text(
                  "SEGURE PARA SE COMPROMETER",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white54,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(duration: 1000.ms),

                const SizedBox(height: 24),

                // O Botão Visual (Branco Padrão CTA)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // Branco Padrão
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    color: Colors.black, // Ícone Preto
                    size: 40,
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 2000.ms),

                const SizedBox(height: 120), // AUMENTADO PARA 120
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // color: Colors.black, // Fundo Preto Padrão - Removido para mostrar GravityBackground
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Ícone de Sucesso
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37), // Dourado
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.black, // Ícone Preto
                  size: 48,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: 40),

              Text(
                "Compromisso Firmado!",
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 300.ms).moveY(begin: 20),

              const SizedBox(height: 16),

              Text(
                "Sua jornada começa agora. Vamos fazer acontecer.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 500.ms).moveY(begin: 20),

              const Spacer(),

              // Botão Continuar (Padrão do App)
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _onNext,
                  // Removemos o style customizado para usar o padrão do tema (Branco/Preto)
                  child: const Text(
                    "CONTINUAR",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ).animate().fade(delay: 800.ms).moveY(begin: 40),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
