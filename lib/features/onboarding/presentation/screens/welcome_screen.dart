import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// V3.1.8: FontAwesome não é mais necessário
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/services/analytics_service.dart';
import 'terms_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analytics = context.read<AnalyticsService>();
      analytics.trackScreenView('welcome_screen');
    });
  }

  // ---
  // V3.1.7 (LÓGICA "GUEST-PRIMEIRO")
  // (A lógica V3.1.7 permanece 100% correta)
  // ---
  Future<void> _onStart(BuildContext context) async {
    await HapticFeedback.mediumImpact();
    context.read<AnalyticsService>().trackEvent(
      'onboarding_start_guest',
      parameters: {'login_method': 'guest'},
    );
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TermsScreen(),
      ),
    );
  }

  // ---
  // V3.1.7 (LÓGICA "JÁ TENHO CONTA")
  // (A lógica V3.1.7 permanece 100% correta)
  // ---
  Future<void> _onLogin(BuildContext context) async {
    await HapticFeedback.mediumImpact();
    context.read<AnalyticsService>().trackEvent(
      'onboarding_login_attempt',
      parameters: {'login_method': 'login_button_stub'},
    );

    // Handoff V3.1.7: Lógica (AuthServiceV3) não implementada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fluxo "Já tenho conta" (V3.1.7) não implementado.'),
        backgroundColor: Colors.grey,
      ),
    );
    // TODO (V3.1.7): Implementar fluxo de login pós-pagamento
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            // ---
            // V3.1.11 (FIX 1): O ALINHAMENTO (REVERSÃO V3.1.9)
            // Handoff V3.1.10 (Centralizado) causou o bug V3.1.11.
            // Handoff V3.1.9 (Start) é a correção V3.1.11.
            // ---
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // ---
              // V3.1.9 (FIX 2): A COR (IDENTIDADE V3)
              // (Esta parte V3.1.9 estava correta)
              // ---
              Text(
                'Bem-vindo ao Procs AI',
                // V3.1.9 (FIX 2): Aplica a cor V3 'primary'
                style: textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                // V3.1.11 (FIX 1): Alinha o texto
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 16),
              Text(
                'Sua jornada de treino, dieta e acompanhamento 100% personalizada.',
                style: textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                // V3.1.11 (FIX 1): Alinha o texto
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 32),

              // V3.1.8 (Imagem "Zing" - Sem Mudanças)
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Image.asset(
                    'assets/images/hero_image.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.0, -0.2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // V3.1.8 (Botões "Zing" - Sem Mudanças)
              ElevatedButton(
                onPressed: () => _onStart(context),
                child: const Text('Começar'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _onLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                child: const Text('Já tenho conta'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
