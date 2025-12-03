import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importa a nova tela de localização do usuário
import 'user_location_screen.dart';
// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// V3 (NOVOS IMPORTS): Widgets reutilizáveis
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/procs_back_button.dart';

/// Tela 1.17: O usuário informa interesse em suplementação (Passo 14/15).
class SupplementsScreen extends StatefulWidget {
  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen> {
  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('supplements');
    });
  }

  /// V3: Ação de 'Finalizar'
  void _onNext() {
    // O valor já está salvo no Provider via onTap dos cards.
    final provider = context.read<OnboardingProvider>();

    // V3: Haptics (Impacto pesado para indicar o fim de uma fase)
    HapticService.heavyImpact();

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_supplements_set',
      parameters: {'interest': provider.data.interestInSupplements},
    );

    // V3: Navegação CORRIGIDA para a NOVA TELA (User Location, 15/15)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserLocationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final selectedInterest = provider.data.interestInSupplements;

    return Scaffold(
      // 1. AppBar removido
      appBar: null,

      // 4. Body para a barra de navegação customizada e conteúdo
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 14/15)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    // Progress bar: 14/15
                    child: PremiumProgressBar(progress: 15 / 16),
                  ),
                ],
              ),
            ),

            // CONTEÚDO ROLÁVEL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    // Título (V3)
                    Text(
                      "Interesse em suplementação?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Subtítulo (V3)
                    Text(
                      "O Procs AI pode oferecer sugestões educacionais (sem marcas ou dosagens) para otimizar seus resultados.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // V3: Cards de Seleção (Design Dourado - PremiumSelectionCard)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PremiumSelectionCard(
                        text: "Sim, estou aberto(a) a sugestões",
                        isSelected: selectedInterest == true,
                        onTap: () {
                          provider.setInterestInSupplements(true);
                          _onNext();
                        },
                      ),
                    ),

                    PremiumSelectionCard(
                      text: "Não, prefiro focar 100% na alimentação",
                      isSelected: selectedInterest == false,
                      onTap: () {
                        provider.setInterestInSupplements(false);
                        _onNext();
                      },
                    ),

                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
