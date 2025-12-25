import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// V3.1.17: purchases_flutter (RevenueCat) permanece removido (unused)

// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// V3.1.21 (NOVO): A "Estrela Norte V3.1.21" (Seu Handoff)
// Esta é a nova Tela 1.25 (V3.1.21)
import '../../../../features/home/presentation/main_wrapper.dart';

// IMPORTS V3.5 (Data Storage)
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/providers/user_data_provider.dart';

/// Tela 1.24: O "Paywall" V3
///
/// V3.1.21 (REFATORADO):
/// Remove o "Gatilho V2" (V3.1.21) (o _saveDataToFirebaseAndApi V3.4)
/// e (V3.1.21) navega para a LoginScreen (V3.1.21) (Tela 1.25),
/// aderindo 100% à arquitetura "Guest-first" (V3.1.7).
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAnalyticsAndRevenueCat();
    });
  }

  /// V3: Inicializa Analytics e (futuramente) busca pacotes RevenueCat
  Future<void> _setupAnalyticsAndRevenueCat() async {
    final analytics = context.read<AnalyticsService>();
    analytics.trackScreenView('checkout');

    // V3: Pré-seleciona o plano anual (REMOVIDO a pedido do usuário)
    // context.read<OnboardingProvider>().setSelectedPlan('annual');
  }

  // ---
  // AÇÕES V3 (O "Gatilho V2" V3.1.21)
  // ---

  /// V3.1.21: Ação de Checkout (Refatorada)
  Future<void> _onCheckout(OnboardingProvider provider) async {
    HapticService.heavyImpact();

    final String? selectedPlan = provider.data.selectedPlan;
    if (selectedPlan == null) return;

    setState(() => _isPurchasing = true);

    final analytics = context.read<AnalyticsService>();
    analytics.trackEvent(
      'checkout_initiated',
      parameters: {'plan': selectedPlan},
    );

    try {
      // 4. V3: LÓGICA REVENUECAT (Simulada)
      await Future.delayed(const Duration(seconds: 2));
      // (FIM DA SIMULAÇÃO)

      // 5. V3: SUCESSO
      analytics.trackEvent(
        'checkout_success',
        parameters: {'plan': selectedPlan},
      );

      if (!mounted) return;

      // --- LOGICA DE SALVAMENTO (RESTITUIDA E MELHORADA) ---

      // 1. Garantir Autenticação
      final auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      // Se user for null aqui, algo errado aconteceu no fluxo (pois forçamos login no inicio)
      if (user == null) {
        throw Exception(
            'Usuário não autenticado. Por favor, faça login novamente.');
      }

      // 2. Salvar dados no Firestore
      debugPrint('Salvando dados para UID: ${user.uid}');
      final firestoreService = FirestoreService();
      await firestoreService.saveOnboardingData(user.uid, provider.data);

      // 3. Iniciar escuta dos dados (para receber a resposta da IA)
      if (mounted) {
        context.read<UserDataProvider>().listenToUser(user.uid);
      }

      // --- FIM LOGICA DE SALVAMENTO ---

      // 7. Navega para a MainWrapper
      provider.setIsPremium(true); // Set Premium status

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainWrapper(),
        ),
        (route) => false,
      );

      setState(() => _isPurchasing = false);
    } catch (e) {
      // 8. V3: Tratamento de Erro
      if (e is! PlatformException || (e).code != "1") {
        analytics
            .trackEvent('checkout_error', parameters: {'error': e.toString()});
        debugPrint('Erro no checkout: $e');
      } else {
        analytics.trackEvent('checkout_cancelled');
      }

      if (mounted) {
        setState(() => _isPurchasing = false);
        // Opcional: Mostrar snackbar de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar: $e')),
        );
      }
    }
  }

  /// V3: Ação de Seleção (V3.1.21) (Sem mudanças)
  void _onSelectPlan(OnboardingProvider provider, String plan) {
    provider.setSelectedPlan(plan);
    HapticService.lightImpact();
  }

  void _showExitSurvey(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header with Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Balance spacing
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _finalizeExit(context, "skipped");
                    },
                    child: const Text(
                      "Pular",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Antes de ir, uma pergunta rápida para melhorarmos o Procs AI:",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildSurveyOption(
                      context, "O preço está acima do meu orçamento."),
                  _buildSurveyOption(
                      context, "Quero testar a versão grátis primeiro."),
                  _buildSurveyOption(
                      context, "Não entendi como a IA funciona."),
                  _buildSurveyOption(
                      context, "Faltou uma funcionalidade específica."),
                  _buildSurveyOption(
                      context, "Prefiro montar meus treinos sozinho."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyOption(BuildContext context, String text) {
    return ListTile(
      title: Text(text, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {
        Navigator.pop(context);
        _finalizeExit(context, text);
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  void _finalizeExit(BuildContext context, String reason) {
    final analytics = context.read<AnalyticsService>();
    analytics.trackEvent('checkout_rejection', parameters: {'reason': reason});

    final provider = context.read<OnboardingProvider>();
    provider.setIsPremium(false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainWrapper()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final provider = context.watch<OnboardingProvider>();
    final selectedPlanKey = provider.data.selectedPlan;
    final bool canContinue = selectedPlanKey != null && !_isPurchasing;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // V3: Remove back button
        leading: null,
        backgroundColor: Colors.transparent, // Transparent for future image
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Allow body to go behind app bar
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Half Placeholder (Future Image)
          const Spacer(flex: 4), // Takes up roughly 40-50% of screen

          // Bottom Half Content
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                // Optional: Add gradient fade from image to background if needed later
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Obtenha acesso completo ao seu plano Ganho muscular!",
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Horizontal Plan Cards
                    SizedBox(
                      height: 180, // Fixed height for cards
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _buildPlanCardHorizontal(
                              theme: theme,
                              planKey: 'monthly',
                              isSelected: selectedPlanKey == 'monthly',
                              title: "1\nMÊS",
                              price: "R\$ 69,90",
                              subtext: "mensalmente",
                              onTap: () => _onSelectPlan(provider, 'monthly'),
                              isFeatured: false,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPlanCardHorizontal(
                              theme: theme,
                              planKey: 'annual',
                              isSelected: selectedPlanKey == 'annual',
                              title: "12\nMESES",
                              price: "R\$ 699,00",
                              subtext: "anualmente",
                              onTap: () => _onSelectPlan(provider, 'annual'),
                              isFeatured: true, // Center card is featured
                              badgeText: "MELHOR CUSTO-\nBENEFÍCIO",
                              badgeColor: colorScheme.primary, // Gold
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPlanCardHorizontal(
                              theme: theme,
                              planKey: 'semiannual',
                              isSelected: selectedPlanKey == 'semiannual',
                              title: "6\nMESES",
                              price: "R\$ 389,90",
                              subtext: "semestralmente",
                              onTap: () =>
                                  _onSelectPlan(provider, 'semiannual'),
                              isFeatured: false,
                              badgeText: "POPULAR",
                              badgeColor: const Color(0xFF9CA3AF), // Grey
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    ElevatedButton(
                      onPressed:
                          canContinue ? () => _onCheckout(provider) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary, // Gold
                        disabledBackgroundColor: theme.colorScheme
                            .surfaceContainerHighest, // Dimmed when disabled
                        foregroundColor: colorScheme.onPrimary,
                        disabledForegroundColor:
                            theme.colorScheme.onSurface.withValues(alpha: 0.38),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isPurchasing
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Text(
                              'Continuar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Skip Button (More Visible)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _showExitSurvey(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Continuar com a versão limitada (sem IA)",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white, // High visibility
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white54,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "O pagamento será cobrado na sua conta Google/Apple. Você pode gerenciar sua assinatura e cancelar a qualquer momento nas configurações da sua conta, pelo menos 24h antes do fim do período de renovação.",
                      style: textTheme.bodySmall?.copyWith(
                        color:
                            textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCardHorizontal({
    required ThemeData theme,
    required String planKey,
    required bool isSelected,
    required String title,
    required String price,
    required String subtext,
    required VoidCallback onTap,
    required bool isFeatured,
    String? badgeText,
    Color? badgeColor,
  }) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Badge Header
          if (badgeText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Text(
                badgeText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Card Body
          Container(
            height: isFeatured ? 140 : 120, // Taller if featured
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isFeatured ? Colors.white : theme.cardTheme.color,
              borderRadius: badgeText != null
                  ? const BorderRadius.vertical(bottom: Radius.circular(12))
                  : BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: colorScheme.primary, width: 2.0)
                  : Border.all(color: Colors.transparent, width: 2.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Radio Icon (Selector)
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? colorScheme.primary
                        : (isFeatured ? Colors.grey.shade300 : Colors.white24),
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isFeatured ? Colors.black : null,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isFeatured ? Colors.black : null,
                    fontSize: 14, // Slightly smaller to fit
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtext,
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: isFeatured ? Colors.black54 : Colors.white54,
                    fontSize: 9,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
