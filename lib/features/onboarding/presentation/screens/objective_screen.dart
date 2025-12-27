import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../application/onboarding_provider.dart';
import '../../domain/onboarding_data_model.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: Haptics
import '../widgets/premium_progress_bar.dart'; // V3: Novo Widget de Progresso
import '../widgets/premium_selection_card.dart'; // V3: Novo Widget de Card
import 'target_weight_screen.dart'; // Próxima tela
import '../widgets/procs_back_button.dart'; // Botão de voltar
import '../widgets/ai_feedback_card.dart'; // Import do Feedback Card V3
// import '../../../../core/widgets/gravity_background.dart';

class ObjectiveScreen extends StatefulWidget {
  const ObjectiveScreen({super.key});

  @override
  State<ObjectiveScreen> createState() => _ObjectiveScreenState();
}

class _ObjectiveScreenState extends State<ObjectiveScreen> {
  @override
  void initState() {
    super.initState();
    // V3: Analytics (initState)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('objective');
    });
  }

  // ---
  // LÓGICA DE RECOMENDAÇÃO (V4)
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
    final data = onboardingProvider.data;
    final currentObjective = data.objective;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
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
                    child: PremiumProgressBar(progress: 3 / 17),
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
                    // V3: Botões de Seleção (Novas Opções)
                    // ---
                    _buildOption(
                      context,
                      'Emagrecer',
                      'perder_gordura',
                      'Dieta e treinos focados em emagrecimento',
                      currentObjective == 'perder_gordura',
                    ),
                    const SizedBox(height: 16),

                    _buildOption(
                      context,
                      'Constância',
                      'manter_saude',
                      'Dieta e treinos adaptados para que você tenha qualidade de vida e não seja sedentário',
                      currentObjective == 'manter_saude',
                    ),
                    const SizedBox(height: 16),

                    _buildOption(
                      context,
                      'Ganho de massa',
                      'ganhar_musculo',
                      'Dieta e treino adaptados para hipertrofia muscular',
                      currentObjective == 'ganhar_musculo',
                    ),

                    const SizedBox(height: 24), // Espaço extra no final
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, String value,
      String subtitle, bool isSelected,
      {String? warningNote}) {
    final theme = Theme.of(context);

    return PremiumSelectionCard(
      text: title, // Agora é o título
      subtitle: subtitle, // Pequena descrição
      warningNote: warningNote, // Nota opcional
      isSelected: isSelected,
      onTap: () {
        context.read<OnboardingProvider>().setObjective(value);
        _onNext(context, value);
      },
    );
  }
}
