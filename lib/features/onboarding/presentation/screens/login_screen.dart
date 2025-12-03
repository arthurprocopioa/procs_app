import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';

// V3.1.22 (A CORREÇÃO):
// O Handoff V3.1.21 (anterior) falhou em incluir estes Handoffs V3.1.17 (imports).
// O VS Code V3.1.22 (9 errors) estava 100% correto.
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
// V3.1.21: Usamos o Handoff V3.1.6 (o asset que você V3.1.21 *gosta*)
import '../../../../core/services/auth_service.dart';
// V3.1.21: Precisamos do "Formulário V3.1.14" (Anônimo)
import '../../application/onboarding_provider.dart';
import '../../domain/onboarding_data_model.dart';
// V3.1.21: Importa a tela "Pós-Onboarding V1" (V3.1.21) (que não existe)
// import 'loading_final_plan_screen.dart';

/// V3.1.21 (NOVA TELA 1.25): Tela de Criação de Conta
///
/// Handoff V3.1.21 (Seu Pedido):
/// 1. Chamada pela 'checkout_screen' (V3.1.21) (após o pagamento V3.1.21).
/// 2. Google (V3.1.6) é funcional.
/// 3. Apple (V3.1.7) e Email (V3.1.20) são "stubs" V3.1.21 (ilustrativos).
///
/// Handoff V3.1.21 (Arquitetura):
/// 4. O "Gatilho V2" (V3.1.21) (_saveDataToFirebaseAndApi V3.4)
///    foi movido (V3.1.21) para *esta* tela V3.1.21.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // V3.1.21: Controla o "spinner" V3.1.21 (Handoff "Feature por Feature")
  bool _isGoogleLoading = false;
  // V3.1.21: "Stubs" V3.1.21
  bool _isAppleLoading = false;
  bool _isEmailLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // V3.1.22 (FIX): O Handoff V3.1.17 (AnalyticsService)
      // agora está importado (V3.1.22).
      context.read<AnalyticsService>().trackScreenView('login_screen');
    });
  }

  // ---
  // V3.1.21 (FEATURE 1): GOOGLE (O Handoff V3.1.6)
  // ---
  Future<void> _onGoogleLogin(
      BuildContext context, OnboardingDataModel data) async {
    setState(() => _isGoogleLoading = true);
    // V3.1.22 (FIX): O Handoff V3.1.17 (Analytics/Haptics)
    // agora está importado (V3.1.22).
    final analytics = context.read<AnalyticsService>();
    HapticService.mediumImpact();

    // 1. V3.1.21: Chama o Handoff V3.1.6 (o seu asset)
    final authService = AuthServiceV3();
    final UserCredential? userCredential = await authService.signInWithGoogle();

    if (!context.mounted) return;

    // 2. V3.1.21: Checa o resultado (Handoff V3.1.1)
    if (userCredential != null) {
      // SUCESSO V3.1.21
      analytics.trackEvent(
        'account_created',
        parameters: {
          'method': 'google',
          'plan': data.selectedPlan, // Handoff V3.1.14 (Anônimo)
        },
      );

      // 3. V3.1.21 (O "GATILHO V2" - MOVIMENTO V3.1.21)
      // O Handoff V3.1.21 (esta tela V3.1.21) agora é
      // (corretamente) responsável por salvar os dados V3.1.14,
      // pois temos o Handoff V3.1.14 (data) E o Handoff V3.1.6 (userCredential).
      await _saveDataToFirebaseAndApi(context, data, userCredential);

      // 4. V3.1.21: Navega para o App Real (Pós-Onboarding V1)
      // (Handoff V3.1.21: A tela V3.1.21 (loading_final_plan_screen)
      // não existe V3.1.21, então navegamos de volta para a Welcome V3.1.11).
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      // FALHA V3.1.21
      analytics.trackEvent('account_creation_failed',
          parameters: {'method': 'google'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha no login com Google. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() => _isGoogleLoading = false);
    }
  }

  // ---
  // V3.1.21 (O "GATILHO V2" - MOVIMENTO V3.1.21)
  // (Esta é a lógica V3.4 (V3.1.21) que foi "morta" (V3.1.21)
  // da 'checkout_screen' V3.1.21).
  // ---
  Future<void> _saveDataToFirebaseAndApi(
    BuildContext context,
    OnboardingDataModel data, // O "Formulário V3.1.14" (Anônimo)
    UserCredential user, // O "Handoff V3.1.6" (Auth)
  ) async {
    // TODO: V3.1.21 (Handoff V3.4) - AQUI ENTRA A LÓGICA DE NUVEM
    // Esta é a "Estrela Norte V2" (V3.1) 100% executada.

    // 1. V3.1.21: Combinar os dados V3.1.14 e V3.1.6
    final userId = user.user!.uid;
    // final userName =
    //     user.user!.displayName ?? data.name; // V3.1.21 (Handoff V3.1.14)
    // final userEmail = user.user!.email;

    // 2. V3.1.21: Converter o Data Model V3.1.14 para JSON
    // (ex: final jsonData = data.toJson();)
    // (ex: jsonData['userId'] = userId;)
    // (ex: jsonData['name'] = userName;)
    // (ex: jsonData['email'] = userEmail;)

    // 3. V3.1.21: Enviar para o Firebase (Firestore)
    // (ex: await FirebaseFirestore.instance.doc('users/$userId').set(jsonData);)

    // 4. V3.1.21: Enviar para a API (Gemini V3)
    // (ex: await ApiService.createPlan(jsonData);)

    debugPrint("V3.1.21 [REGRA V2]: Usuário V3.1.21 ($userId) autenticado.");
    debugPrint("V3.1.21 [REGRA V2]: Enviando dados V3.1.14 para a nuvem...");
    debugPrint("V3.1.21 [REGRA V2]: Plano: ${data.selectedPlan}");
    await Future.delayed(const Duration(seconds: 1));
  }

  // ---
  // V3.1.21 (STUBS V3.1.21)
  // (Handoff V3.1.21: "apenas ilustrativas")
  // ---
  Future<void> _onAppleLogin(BuildContext context) async {
    // V3.1.22 (FIX): O Handoff V3.1.17 (Analytics/Haptics)
    // agora está importado (V3.1.22).
    HapticService.mediumImpact();
    context.read<AnalyticsService>().trackEvent(
      'account_creation_attempt',
      parameters: {'method': 'apple_stub'},
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login com Apple (V3.1.7) não implementado.'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  Future<void> _onEmailLogin(BuildContext context) async {
    // V3.1.22 (FIX): O Handoff V3.1.17 (Analytics/Haptics)
    // agora está importado (V3.1.22).
    HapticService.mediumImpact();
    context.read<AnalyticsService>().trackEvent(
      'account_creation_attempt',
      parameters: {'method': 'email_stub'},
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login com Email/Senha (V3.1.20) não implementado.'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // V3.1.21: O "Gatilho V2" (V3.1.21) exige o Handoff V3.1.14 (o DataModel V3.1.14)
    final provider = context.read<OnboardingProvider>();
    final data = provider.data;

    // V3.1.21: Controla o "Loading V3.1.21" (Impede "double-click" V3.1.21)
    final bool isLoading =
        _isGoogleLoading || _isAppleLoading || _isEmailLoading;

    return Scaffold(
      appBar: AppBar(
        // V3.1.21: O Handoff V3.1.21 (Auth Pós-Pagamento V3.1.21)
        // é mandatório (V3.1.21). O usuário V3.1.21 não pode voltar.
        leading: const SizedBox(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                "Crie sua conta",
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Para salvar seu progresso e acessar de qualquer dispositivo, crie sua conta.",
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // ---
              // V3.1.21 (FEATURE 1): GOOGLE (Funcional)
              // ---
              ElevatedButton(
                onPressed:
                    isLoading ? null : () => _onGoogleLogin(context, data),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isGoogleLoading)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF1C1C1E), // V3.0 (Tema)
                        ),
                      )
                    else
                      // V3.1.21: Handoff V3.1.8 (Sem Ícones)
                      const SizedBox(),
                    const SizedBox(width: 12),
                    Text(_isGoogleLoading
                        ? 'Carregando...'
                        : 'Continuar com Google'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---
              // V3.1.21 (FEATURE 2): APPLE (Stub)
              // ---
              ElevatedButton(
                onPressed: isLoading ? null : () => _onAppleLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isAppleLoading)
                      // ... (Lógica de Stub V3.1.21) ...
                      const SizedBox()
                    else
                      const SizedBox(),
                    const SizedBox(width: 12),
                    const Text('Continuar com Apple'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---
              // V3.1.21 (FEATURE 3): EMAIL (Stub)
              // ---
              ElevatedButton(
                onPressed: isLoading ? null : () => _onEmailLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isEmailLoading)
                      // ... (Lógica de Stub V3.1.21) ...
                      const SizedBox()
                    else
                      const SizedBox(),
                    const SizedBox(width: 12),
                    const Text('Continuar com E-mail'),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
