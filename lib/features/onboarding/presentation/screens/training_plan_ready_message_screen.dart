import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // Removed unused import
// import 'package:provider/provider.dart';
// import '../../application/onboarding_provider.dart';
import 'diet_restrictions_screen.dart'; // Próxima tela (ajustar conforme fluxo real)
import '../../../../core/services/haptic_service.dart';
// import '../../../../core/widgets/gravity_background.dart';

class TrainingPlanReadyMessageScreen extends StatefulWidget {
  const TrainingPlanReadyMessageScreen({super.key});

  @override
  State<TrainingPlanReadyMessageScreen> createState() =>
      _TrainingPlanReadyMessageScreenState();
}

class _TrainingPlanReadyMessageScreenState
    extends State<TrainingPlanReadyMessageScreen>
    with TickerProviderStateMixin {
  late final List<String> _script;

  int _currentPhraseIndex = 0;
  String _displayedText = "";
  bool _isTyping = false;
  bool _showButton = false;

  late AnimationController _cursorController;
  Timer? _typingTimer;

  final Duration _typingSpeed = const Duration(milliseconds: 40);
  final Duration _readPause = const Duration(seconds: 2);
  final Duration _fadeDuration = const Duration(milliseconds: 500);

  double _textOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    _script = [
      "Plano de treino finalizado.",
      "Obrigado por confiar no processo até aqui.",
      "Agora, faltam apenas algumas perguntas sobre sua alimentação.",
      "Assim que terminarmos, seu plano completo estará pronto.",
    ];

    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 1), _startTypingPhrase);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startTypingPhrase() {
    if (_currentPhraseIndex >= _script.length) {
      setState(() {
        _showButton = true;
        _isTyping = false;
      });
      HapticService.heavyImpact();
      return;
    }

    setState(() {
      _isTyping = true;
      _displayedText = "";
      _textOpacity = 1.0;
    });

    final String fullText = _script[_currentPhraseIndex];
    int charIndex = 0;

    _typingTimer = Timer.periodic(_typingSpeed, (timer) {
      if (charIndex < fullText.length) {
        setState(() {
          _displayedText += fullText[charIndex];
        });
        charIndex++;

        if (charIndex % 3 == 0 || ".,!?".contains(fullText[charIndex - 1])) {
          HapticService.lightImpact();
        }
      } else {
        timer.cancel();
        setState(() => _isTyping = false);

        if (_currentPhraseIndex == _script.length - 1) {
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() => _showButton = true);
            HapticService.heavyImpact();
          });
        } else {
          Future.delayed(_readPause, _fadeOutAndNext);
        }
      }
    });
  }

  void _fadeOutAndNext() {
    setState(() {
      _textOpacity = 0.0;
    });

    Future.delayed(_fadeDuration, () {
      if (mounted) {
        setState(() {
          _currentPhraseIndex++;
        });
        _startTypingPhrase();
      }
    });
  }

  void _onNext() {
    HapticService.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DietRestrictionsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final TextStyle messageStyle = theme.textTheme.headlineSmall!.copyWith(
      height: 1.4,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
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
                              text: _displayedText,
                              style: messageStyle,
                            ),
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
                const Spacer(flex: 2),
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
                          "CONTINUAR",
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
    );
  }
}
