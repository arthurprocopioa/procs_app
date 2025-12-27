import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/onboarding_provider.dart';
import 'vital_data_screen.dart'; // Próxima tela
import '../../../../core/services/haptic_service.dart'; // Haptics
// import '../../../../core/widgets/gravity_background.dart';

class ReceptionMessageScreen extends StatefulWidget {
  const ReceptionMessageScreen({super.key});

  @override
  State<ReceptionMessageScreen> createState() => _ReceptionMessageScreenState();
}

class _ReceptionMessageScreenState extends State<ReceptionMessageScreen>
    with TickerProviderStateMixin {
  // As frases do roteiro
  late final List<String> _script;

  // Estado da animação
  int _currentPhraseIndex = 0;
  String _displayedText = "";
  bool _isTyping = false;
  bool _showButton = false;

  // Controladores
  late AnimationController _cursorController;
  Timer? _typingTimer;

  // Configurações de tempo
  final Duration _typingSpeed =
      const Duration(milliseconds: 40); // Velocidade da digitação
  final Duration _readPause =
      const Duration(seconds: 2); // Tempo para ler antes de trocar
  final Duration _fadeDuration =
      const Duration(milliseconds: 500); // Tempo de fade out/in

  // Controle de Opacidade para transição suave entre frases
  double _textOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    // Pega o nome do usuário para personalizar a primeira frase
    final String userName =
        context.read<OnboardingProvider>().data.name ?? "Viajante";

    // Define o roteiro final
    // Define o roteiro final
    _script = [
      "Olá, $userName. Eu sou o Procs AI,\nseu assistente de desenvolvimento corporal, treino e nutrição",
      "Para montar a melhor rotina para seus objetivos,\npreciso te fazer algumas perguntas.",
      "Podemos começar?",
    ];

    // Animação do cursor piscando
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // Inicia a sequência após um breve delay inicial
    Future.delayed(const Duration(seconds: 1), _startTypingPhrase);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  /// Inicia a digitação da frase atual
  void _startTypingPhrase() {
    if (_currentPhraseIndex >= _script.length) {
      // Fim do roteiro -> Mostra botão
      setState(() {
        _showButton = true;
        _isTyping = false;
      });
      HapticService.heavyImpact(); // Impacto final
      return;
    }

    setState(() {
      _isTyping = true;
      _displayedText = "";
      _textOpacity = 1.0; // Garante que está visível
    });

    final String fullText = _script[_currentPhraseIndex];
    int charIndex = 0;

    _typingTimer = Timer.periodic(_typingSpeed, (timer) {
      if (charIndex < fullText.length) {
        setState(() {
          _displayedText += fullText[charIndex];
        });
        charIndex++;

        // Haptics: Vibra em intervalos para não saturar
        if (charIndex % 3 == 0 || ".,!?".contains(fullText[charIndex - 1])) {
          HapticService.lightImpact();
        }
      } else {
        // Frase terminada
        timer.cancel();
        setState(() => _isTyping = false);

        // Se for a última frase, não apaga, apenas mostra o botão
        if (_currentPhraseIndex == _script.length - 1) {
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() => _showButton = true);
            HapticService.heavyImpact();
          });
        } else {
          // Aguarda leitura e então troca
          Future.delayed(_readPause, _fadeOutAndNext);
        }
      }
    });
  }

  /// Faz o texto desaparecer e inicia a próxima frase
  void _fadeOutAndNext() {
    setState(() {
      _textOpacity = 0.0; // Inicia o Fade Out
    });

    // Aguarda o tempo do fade out terminar para trocar o índice e reiniciar
    Future.delayed(_fadeDuration, () {
      if (mounted) {
        setState(() {
          _currentPhraseIndex++;
        });
        _startTypingPhrase(); // Recomeça o ciclo para a próxima frase
      }
    });
  }

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

    // Estilo do Texto Principal
    final TextStyle messageStyle = theme.textTheme.headlineSmall!.copyWith(
      height: 1.4,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    );

    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto imersivo
      body: Stack(
        children: [
          // CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centraliza verticalmente
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Espaço flexível superior
                  const Spacer(flex: 2),

                  // O TEXTO ANIMADO
                  AnimatedOpacity(
                    opacity: _textOpacity,
                    duration: _fadeDuration,
                    child: SizedBox(
                      height: 200, // Altura fixa para evitar pulos
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _displayedText,
                                style: messageStyle,
                              ),
                              // CORREÇÃO DO BUG DO MARGIN NEGATIVO
                              if (_isTyping && _textOpacity > 0)
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Transform.translate(
                                    offset: const Offset(
                                        2, 0), // Ajuste de posição seguro
                                    child: FadeTransition(
                                      opacity: _cursorController,
                                      child: Container(
                                        width: 2,
                                        height: 24,
                                        color: theme.colorScheme
                                            .primary, // Cursor Dourado
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

                  const Spacer(flex: 2),

                  // BOTÃO "COMEÇAR EVOLUÇÃO"
                  AnimatedOpacity(
                    opacity: _showButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: IgnorePointer(
                      ignoring: !_showButton,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        // CORREÇÃO DO BOTÃO:
                        // Removida estilização customizada para usar o padrão do AppTheme
                        // (Fundo Branco, Texto Preto, Largura Total)
                        child: ElevatedButton(
                          onPressed: _onNext,
                          child: const Text(
                            "COMEÇAR EVOLUÇÃO",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
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
}
