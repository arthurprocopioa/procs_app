import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'welcome_screen.dart'; // Tela inicial
import '../../../../core/services/haptic_service.dart';

class SafetyBlockScreen extends StatelessWidget {
  const SafetyBlockScreen({super.key});

  void _onBackToStart(BuildContext context) {
    HapticService.mediumImpact();
    // Reseta para o início do fluxo (WelcomeScreen)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image (Opcional, mantendo consistência com outras telas de mensagem)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_premium.png'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Ícone de Alerta
                  Icon(
                    FontAwesomeIcons.triangleExclamation,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 32),

                  // Título
                  Text(
                    "Sua segurança em 1º lugar",
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Mensagem
                  Text(
                    "O Procs AI é um sistema de alta performance. Para sua segurança, dado o seu histórico de saúde, recomendamos acompanhamento médico presencial.",
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),

                  // Botão Voltar ao Início
                  ElevatedButton(
                    onPressed: () => _onBackToStart(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                    child: const Text("Voltar ao Início"),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
