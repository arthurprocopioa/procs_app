import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// V3.1.8: FontAwesome não é mais necessário
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:firebase_auth/firebase_auth.dart'; // Auth
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // Import HapticService
import '../../../../core/services/auth_service.dart'; // Auth
import '../../../../core/services/firestore_service.dart'; // FirestoreService
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import '../../../../core/providers/user_data_provider.dart'; // Import UserDataProvider
import 'terms_screen.dart';
import '../../../../core/widgets/gravity_background.dart';

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
  // ---
  // LÓGICA LOGIN: Google -> Checar Firestore -> Navegar
  // ---
  // ---
  // LÓGICA V3 PURE: START = GUEST AUTH AUTOMÁTICO
  // ---
  Future<void> _onStart(BuildContext context) async {
    final analytics = context.read<AnalyticsService>();
    await HapticService.mediumImpact();

    analytics.trackEvent(
      'onboarding_start_guest',
      parameters: {'login_method': 'guest'},
    );

    // V3: Autenticação Anônima SILENCIOSA agora mesmo.
    // Isso garante que temos um UID para salvar os dados do onboarding desde o passo 1.
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
    } catch (e) {
      debugPrint("Erro ao criar usuário anônimo: $e");
      // Mesmo com erro, deixamos prosseguir, o checkout tentará novamente.
    }

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TermsScreen(),
      ),
    );
  }

  Future<void> _onLogin(BuildContext context) async {
    // Fluxo "Já Tenho Conta" (Login explícito com Google)
    final analytics = context.read<AnalyticsService>();
    await HapticService.mediumImpact();

    analytics.trackEvent('onboarding_login_attempt',
        parameters: {'method': 'google'});

    final authService = AuthServiceV3();
    final userCredential = await authService.signInWithGoogle();

    if (userCredential != null && context.mounted) {
      // Sucesso -> Home
      // Importante: Iniciar o carregamento dos dados do usuário logado!
      context.read<UserDataProvider>().listenToUser(userCredential.user!.uid);

      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      // CRÍTICA 1: Força o fundo preto puro para mesclar com a imagem.
      // backgroundColor: Colors.black,
      body: GravityBackground(
        child: SafeArea(
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
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                child: const Text('Já tenho conta'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
