import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// V3.1.8: FontAwesome não é mais necessário
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // Import HapticService
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
  // V3.1.7 (LÓGICA "GUEST-PRIMEIRO") - (INTOCADA)
  // ---
  Future<void> _onStart(BuildContext context) async {
    // V3: Haptics refatorado para usar o HapticService
    final analytics = context.read<AnalyticsService>();
    await HapticService.mediumImpact();

    analytics.trackEvent(
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
  // V3.1.7 (LÓGICA "JÁ TENHO CONTA") - (INTOCADA)
  // ---
  Future<void> _onLogin(BuildContext context) async {
    // V3: Haptics refatorado para usar o HapticService
    final analytics = context.read<AnalyticsService>();
    await HapticService.mediumImpact();

    analytics.trackEvent(
      'onboarding_login_attempt',
      parameters: {'login_method': 'login_button_stub'},
    );

    if (!context.mounted) return;

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
      // CRÍTICA 1: Força o fundo preto puro para mesclar com a imagem.
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false, // Permite que os botões fiquem na borda inferior
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            // CRÍTICA 3: Altera para .stretch para que os botões
            // ocupem a largura total, como na referência Zing.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // ---
              // CRÍTICA 4: Alinhamento de Texto
              // ---
              Text(
                'Bem-vindo ao Procs AI',
                style: textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                // CRÍTICA 4b: Textos agora centralizados
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Sua jornada de treino, dieta e acompanhamento 100% personalizada.',
                style: textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                // CRÍTICA 4b: Textos agora centralizados
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ---
              // CRÍTICA 2 e 3: Layout e Alinhamento da Imagem
              // ---
              Expanded(
                // Removemos o Container/ClipRRect desnecessário.
                // A imagem agora vai "flutuar" no fundo preto.
                child: Image.asset(
                  'assets/images/hero_image.png',
                  // BoxFit.contain garante que a imagem inteira seja
                  // exibida, sem cortes, como na referência Zing.
                  fit: BoxFit.contain,
                  // Garante que a imagem fique centralizada no espaço.
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(height: 32),

              // ---
              // CRÍTICA 5: Estilo dos Botões
              // ---
              ElevatedButton(
                onPressed: () => _onStart(context),
                child: const Text('Começar'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _onLogin(context),
                style: ElevatedButton.styleFrom(
                  // CRÍTICA 5: Usa a cor de container/fundo secundário
                  // definida no seu app_theme.dart (#1E1E1E)
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                child: const Text('Já tenho conta'),
              ),
              // V3: Aumenta o padding inferior para corresponder à referência
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
