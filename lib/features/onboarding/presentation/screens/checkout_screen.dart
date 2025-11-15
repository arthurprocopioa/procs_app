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
import '../../domain/onboarding_data_model.dart';
// V3.1.21 (NOVO): A "Estrela Norte V3.1.21" (Seu Handoff)
// Esta é a nova Tela 1.25 (V3.1.21)
import 'login_screen.dart';

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

    // V3: Pré-seleciona o plano anual
    context.read<OnboardingProvider>().setSelectedPlan('annual');
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
      // (O Handoff V3.4 (V3.1.21) permanece 100% o mesmo)
      await Future.delayed(const Duration(seconds: 2));
      // (FIM DA SIMULAÇÃO)

      // 5. V3: SUCESSO
      analytics.trackEvent(
        'checkout_success',
        parameters: {'plan': selectedPlan},
      );

      if (!mounted) return;

      // 6. V3.1.21 (A CORREÇÃO): "Gatilho V2" (V3.1.21) Removido
      // O Handoff V3.4 (V3.1.21) chamava o _saveDataToFirebaseAndApi (V3.4) aqui.
      // O Handoff V3.1.21 (correto) "mata" (V3.1.21) essa chamada,
      // pois ela V3.1.21 viola a "Estrela Norte V2" (V3.1) (sem auth V3.1).
      // await _saveDataToFirebaseAndApi(context, provider.data); // <-- V3.1.21 (REMOVIDO)

      // 7. V3.1.21 (A "Estrela Norte V3.1.21"): Navega para a Tela 1.25
      // (Handoff V3.1.21: "A tela checkout_screen deve começar a ir para login_screen")
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );

      // 8. V3.1.21: Para o spinner (V3.1.21) *após* a navegação (V3.1.21)
      // (O usuário não verá isso, mas é uma boa prática V3.1.21)
      setState(() => _isPurchasing = false);
    } catch (e) {
      // 8. V3: Tratamento de Erro (V3.1.21)
      if (e is! PlatformException || (e).code != "1") {
        // 1 = "Compra cancelada"
        analytics
            .trackEvent('checkout_error', parameters: {'error': e.toString()});
      } else {
        analytics.trackEvent('checkout_cancelled');
      }

      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  // V3.1.21 (REMOVIDO): A "Regra de Negócio V2" (V3.1.21)
  // foi 100% "morta" (V3.1.21) deste Handoff V3.1.21 (arquivo)
  // e (V3.1.21) movida para a 'login_screen.dart' (V3.1.21).
  /*
  Future<void> _saveDataToFirebaseAndApi(
      BuildContext context, OnboardingDataModel data) async {
    // ... (Lógica V3.4 removida)
  }
  */

  /// V3: Ação de Seleção (V3.1.21) (Sem mudanças)
  void _onSelectPlan(OnboardingProvider provider, String plan) {
    provider.setSelectedPlan(plan);
    HapticService.lightImpact();
  }

  // V3.1.17: (Dívidas V3.1.17 já "mortas" V3.1.17)
  // _navigateToNext (unused)
  // colorScheme (unused)

  @override
  Widget build(BuildContext context) {
    // ... (O Handoff V3.4 (V3.1.21) da UI permanece 100% o mesmo)
    // ... (Não há mudanças de UI neste Handoff V3.1.21)
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final provider = context.watch<OnboardingProvider>();
    final selectedPlanKey = provider.data.selectedPlan;
    final bool canContinue = selectedPlanKey != null && !_isPurchasing;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      "Seu plano está pronto",
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Escolha o plano que melhor se adapta ao seu progresso.",
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    _buildPlanCard(
                      theme: theme,
                      planKey: 'annual',
                      isSelected: selectedPlanKey == 'annual',
                      title: "Plano Anual",
                      price: "R\$ 699,00",
                      subtext: "/ano",
                      badgeText: "Economize 2 meses!",
                      onTap: () => _onSelectPlan(provider, 'annual'),
                    ),
                    const SizedBox(height: 16),
                    _buildPlanCard(
                      theme: theme,
                      planKey: 'monthly',
                      isSelected: selectedPlanKey == 'monthly',
                      title: "Plano Mensal",
                      price: "R\$ 69,90",
                      subtext: "/mês",
                      badgeText: null,
                      onTap: () => _onSelectPlan(provider, 'monthly'),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: canContinue ? () => _onCheckout(provider) : null,
                    child: _isPurchasing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1C1C1E),
                            ),
                          )
                        : const Text('Assinar Agora'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "O pagamento será cobrado na sua conta Google/Apple. Você pode gerenciar sua assinatura e cancelar a qualquer momento nas configurações da sua conta, pelo menos 24h antes do fim do período de renovação.",
                    style: textTheme.bodySmall?.copyWith(
                      color: textTheme.bodyMedium?.color,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper V3: Card de Plano (V3.1.21) (Sem mudanças)
  Widget _buildPlanCard({
    required ThemeData theme,
    required String planKey,
    required bool isSelected,
    required String title,
    required String price,
    required String subtext,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    // ... (A UI V3.4 (V3.1.21) permanece 100% a mesma)
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12.0),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2.0)
              : Border.all(color: theme.cardTheme.color!, width: 2.0),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          price,
                          style: textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subtext,
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected
                      ? colorScheme.primary
                      : theme.textTheme.bodyMedium?.color,
                ),
              ],
            ),
            if (badgeText != null)
              Positioned(
                top: -26,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    badgeText,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
