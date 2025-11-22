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

    // O botão só é habilitado se uma região for selecionada
    final bool canContinue = selectedRegion != null;

    return Scaffold(
      appBar: null,

      // Botão de Ação (Inferior Fixo - V3 UI)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed: canContinue ? _onNext : null,
          child: const Text('Continuar'),
        ),
      ),

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
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.arrow_back,
                        color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    // Progress bar: 15/15 (Completa!)
                    child: PremiumProgressBar(progress: 16 / 17),
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
                            HapticService.lightImpact();
                            provider.setUserRegion(key);
                          },
                        ),
                      );
                    }).toList(),

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
