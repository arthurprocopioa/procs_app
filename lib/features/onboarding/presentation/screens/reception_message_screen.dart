import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/onboarding_provider.dart';
import 'vital_data_screen.dart'; // V3.1.14: O próximo passo V3.0

/// V3.1.14 (Handoff V3.1.13): Nova Tela 1.2.2
/// Mostra a mensagem de "boas-vindas" personalizada
/// e navega automaticamente para a próxima etapa (V3.0).
class ReceptionMessageScreen extends StatefulWidget {
  const ReceptionMessageScreen({super.key});

  @override
  State<ReceptionMessageScreen> createState() => _ReceptionMessageScreenState();
}

class _ReceptionMessageScreenState extends State<ReceptionMessageScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Handoff V3.1.14: Espera 3 segundos (V3.1.14) antes de navegar
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Handoff V3.1.14: O fluxo V3.0 ("Guest-first") continua
    // para a 'VitalDataScreen' (V3.0).
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VitalDataScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Handoff V3.1.14: Lê o nome da "Memória RAM" V3 (Provider V3.1.14)
    final String name =
        context.watch<OnboardingProvider>().data.name ?? "Usuário";

    return Scaffold(
      // V3.1.14: Não há AppBar para uma tela "splash" (V3.1.14)
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Handoff V3.1.14: O Handoff V3.1.13 (Nome)
              // permite esta personalização (V3.1.14).
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: textTheme.displayLarge,
                  children: [
                    const TextSpan(text: "É um prazer ter você aqui, "),
                    TextSpan(
                      text: "$name!",
                      // Handoff V3.1.14: Aplica o "Dourado" V3
                      // ao nome V3.1.14 (Identidade V3).
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Vamos começar a personalizar sua jornada.",
                style: textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
