import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_diet_plan_screen.dart'; // Próximo destino (Loading)
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

/// NOVA TELA (Passo 15/15): O usuário informa a região do Brasil para otimizar a dieta.
/// REFACTOR: Última etapa de coleta, ajustada para UX premium.
class UserLocationScreen extends StatefulWidget {
  const UserLocationScreen({super.key});

  @override
  State<UserLocationScreen> createState() => _UserLocationScreenState();
}

class _UserLocationScreenState extends State<UserLocationScreen> {
  // Mapa das Regiões Brasileiras
  final Map<String, String> _regionOptions = {
    'sudeste': 'Sudeste',
    'sul': 'Sul',
    'centro_oeste': 'Centro-Oeste',
    'norte': 'Norte',
    'nordeste': 'Nordeste',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('user_location');
    });
  }

  /// Ação de 'Próximo'
  void _onNext() {
    final provider = context.read<OnboardingProvider>();
    final selectedRegion = provider.data.userRegion;

    if (selectedRegion == null) return;

    HapticService.heavyImpact();

    context.read<AnalyticsService>().trackEvent(
      'onboarding_region_set',
      parameters: {'region': selectedRegion},
    );

    // Navega para a tela de Loading da Dieta
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoadingDietPlanScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final selectedRegion = provider.data.userRegion;

    return Scaffold(
      appBar: null,

      // Body para a barra de navegação customizada e conteúdo
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 15/15)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    // Progress bar: 15/15 (Completa!)
                    child: PremiumProgressBar(progress: 16 / 16),
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
                      "Qual é a sua região no Brasil?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Subtítulo (V3)
                    Text(
                      "Isso nos ajuda a montar sua dieta com ingredientes regionalmente disponíveis e com preços mais acessíveis.",
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // V3: Cards de Seleção (Design Dourado - PremiumSelectionCard)
                    ..._regionOptions.entries.map((entry) {
                      final key = entry.key;
                      final text = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: PremiumSelectionCard(
                          text: text,
                          isSelected: selectedRegion == key,
                          onTap: () {
                            provider.setUserRegion(key);
                            _onNext();
                          },
                        ),
                      );
                    }),

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
