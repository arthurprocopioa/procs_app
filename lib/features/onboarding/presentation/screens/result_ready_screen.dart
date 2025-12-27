import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notifications_screen.dart'; // Próxima tela
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// import '../../../../core/widgets/gravity_background.dart';

class ResultReadyScreen extends StatefulWidget {
  const ResultReadyScreen({super.key});

  @override
  State<ResultReadyScreen> createState() => _ResultReadyScreenState();
}

class _ResultReadyScreenState extends State<ResultReadyScreen>
    with TickerProviderStateMixin {
  // Controle do Roteiro
  List<String> _script = [];
  int _currentPhraseIndex = 0;
  String _displayedText = "";
  bool _isTyping = false;
  bool _showButton = false;

  // Estado para a Checklist (aparece em um momento específico)
  bool _showChecklist = false;

  // Controladores
  late AnimationController _cursorController;
  Timer? _typingTimer;

  // Configurações de tempo
  final Duration _typingSpeed =
      const Duration(milliseconds: 35); // Rápido e fluido
  final Duration _readPause = const Duration(seconds: 2);
  final Duration _fadeDuration = const Duration(milliseconds: 500);

  // Controle de Opacidade
  double _textOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    // Analytics e Haptics Iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('result_ready');
      HapticService.heavyImpact(); // Impacto inicial forte
    });

    final String userName =
        context.read<OnboardingProvider>().data.name ?? "Campeão";

    // ROTEIRO DE PERSUASÃO
    // Nota: A checklist é tratada como um "evento visual" entre as frases 2 e 3.
    _script = [
      "Tudo pronto, $userName!",
      "A IA finalizou a análise do seu perfil.",
      // AQUI ENTRA A CHECKLIST VISUAL (Index 2 é um placeholder para a checklist)
      "CHECKLIST_EVENT",
      "Seu sistema de transformação física começa hoje.",
      "Vamos configurar os últimos detalhes para garantir sua consistência.",
    ];

    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // Inicia diretamente
    Future.delayed(const Duration(milliseconds: 500), _startTypingPhrase);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startTypingPhrase() {
    if (_currentPhraseIndex >= _script.length) {
      // Fim do roteiro -> Botão
      setState(() {
        _showButton = true;
        _isTyping = false;
      });
      HapticService.heavyImpact();
      return;
    }

    final String content = _script[_currentPhraseIndex];

    // Se for o evento de checklist, tratamos diferente
    if (content == "CHECKLIST_EVENT") {
      setState(() {
        _showChecklist = true;
        _isTyping = false;
        _displayedText = ""; // Limpa o texto anterior
      });
      HapticService.mediumImpact();
      // Deixa a checklist na tela por uns 3.5 segundos antes de continuar
      Future.delayed(const Duration(milliseconds: 3500), () {
        setState(
            () => _showChecklist = false); // Opcional: pode deixar ela ou sumir
        // Vamos sumir com ela para focar na mensagem final ("Seu sistema...")
        _fadeOutAndNext();
      });
      return;
    }

    setState(() {
      _isTyping = true;
      _displayedText = "";
      _textOpacity = 1.0;
    });

    int charIndex = 0;
    _typingTimer = Timer.periodic(_typingSpeed, (timer) {
      if (charIndex < content.length) {
        setState(() {
          _displayedText += content[charIndex];
        });
        charIndex++;
        if (charIndex % 3 == 0) HapticService.lightImpact();
      } else {
        timer.cancel();
        setState(() => _isTyping = false);
        Future.delayed(_readPause, _fadeOutAndNext);
      }
    });
  }

  void _fadeOutAndNext() {
    setState(() => _textOpacity = 0.0);
    Future.delayed(_fadeDuration, () {
      if (mounted) {
        setState(() {
          _currentPhraseIndex++;
          // Se a checklist estava visível, garante que ela suma agora para limpar a tela
          _showChecklist = false;
        });
        _startTypingPhrase();
      }
    });
  }

  void _onNext() {
    HapticService.mediumImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Estilo do texto (Dourado ou Branco, bem legível)
    final TextStyle messageStyle = theme.textTheme.headlineSmall!.copyWith(
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // 2. ÁREA DE TEXTO DIGITADO (Typewriter)
                  if (!_showChecklist)
                    AnimatedOpacity(
                      opacity: _textOpacity,
                      duration: _fadeDuration,
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: _displayedText, style: messageStyle),
                                if (_isTyping && _textOpacity > 0)
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Transform.translate(
                                      offset: const Offset(2, 0),
                                      child: FadeTransition(
                                        opacity: _cursorController,
                                        child: Container(
                                          width: 2,
                                          height: 24,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 3. CHECKLIST ANIMADA (Aparece no meio do roteiro)
                  if (_showChecklist)
                    AnimatedOpacity(
                      opacity: _showChecklist ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: SizedBox(
                        height: 250, // Altura fixa para a checklist
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCheckItem(
                                theme, "Estratégia de Treino: Definida.", 0),
                            const SizedBox(height: 24),
                            _buildCheckItem(
                                theme, "Metas de Nutrição: Calculadas.", 1),
                            const SizedBox(height: 24),
                            _buildCheckItem(
                                theme, "Variações de Exercício: Prontas.", 2),
                          ],
                        ),
                      ),
                    ),

                  const Spacer(flex: 2),

                  // 4. BOTÃO FINAL
                  AnimatedOpacity(
                    opacity: _showButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: IgnorePointer(
                      ignoring: !_showButton,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: ElevatedButton(
                          onPressed: _onNext,
                          child: const Text(
                            "VAMOS LÁ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget da Checklist com animação escalonada simples
  Widget _buildCheckItem(ThemeData theme, String text, int index) {
    // Pequeno delay para cada item aparecer um após o outro
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), // Sobe um pouquinho
            child: child,
          ),
        );
      },
      child: Center(
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
