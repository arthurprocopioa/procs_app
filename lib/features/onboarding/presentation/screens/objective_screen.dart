import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// Removido: font_awesome_flutter (não é mais necessário)

import '../../application/onboarding_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: Haptics
import '../widgets/premium_progress_bar.dart'; // V3: Novo Widget de Progresso
import '../widgets/premium_selection_card.dart'; // V3: Novo Widget de Card
import 'target_weight_screen.dart';
import '../widgets/procs_back_button.dart';

class ObjectiveScreen extends StatefulWidget {
  const ObjectiveScreen({super.key});

  @override
  State<ObjectiveScreen> createState() => _ObjectiveScreenState();
}

class _ObjectiveScreenState extends State<ObjectiveScreen> {
  @override
  void initState() {
    super.initState();
    // V3: Analytics (initState) - Já estava correto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('objective');
    });
  }

  // ---
  // LÓGICA DE NAVEGAÇÃO (INTOCADA)
  // ---
  void _onNext(BuildContext context, String currentObjective) {
    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_objective_selected',
      parameters: {'objective': currentObjective},
    );

    // V3: Navegação
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const TargetWeightScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    final currentObjective = onboardingProvider.data.objective;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. BARRA DE PROGRESSO E BOTÃO DE VOLTAR (FIXO NO TOPO)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    // Usa a nova barra de progresso
                    child: PremiumProgressBar(progress: 2 / 16),
                  ),
                ],
              ),
            ),

            // 2. CONTEÚDO ROLÁVEL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---
                    // V3: Título (Tematizado)
                    // ---
                    Text(
                      "Qual é o seu principal objetivo?",
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // ---
                    // V3: Botões de Seleção (Substituído por PremiumSelectionCard)
                    // (Removemos os ícones laterais e alinhamos à esquerda)
                    // ---
                    PremiumSelectionCard(
                      text: 'Perder Gordura',
                      isSelected: currentObjective == 'perder_gordura',
                      onTap: () {
                        context
                            .read<OnboardingProvider>()
                            .setObjective('perder_gordura');
                        _onNext(context, 'perder_gordura');
                      },
                    ),
                    const SizedBox(height: 16),
                    PremiumSelectionCard(
                      text: 'Manter/Saúde',
                      isSelected: currentObjective == 'manter_saude',
                      onTap: () {
                        context
                            .read<OnboardingProvider>()
                            .setObjective('manter_saude');
                        _onNext(context, 'manter_saude');
                      },
                    ),
                    const SizedBox(height: 16),
                    PremiumSelectionCard(
                      text: 'Ganhar Músculo',
                      isSelected: currentObjective == 'ganhar_musculo',
                      onTap: () {
                        context
                            .read<OnboardingProvider>()
                            .setObjective('ganhar_musculo');
                        _onNext(context, 'ganhar_musculo');
                      },
                    ),
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

// ---
// V3: REMOVIDOS OS WIDGETS ANTIGOS (_ObjectiveCard e _OnboardingAppBar)
// Eles foram substituídos pelos widgets centrais e reutilizáveis (PremiumProgressBar, PremiumSelectionCard).
// ---
