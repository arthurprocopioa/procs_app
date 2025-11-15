import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../application/onboarding_provider.dart';
import '../../../../core/services/analytics_service.dart';
import 'target_weight_screen.dart';
// Removido: custom_selection_button.dart
// Removido: app_theme.dart (cores estáticas não são mais necessárias)

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

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    final currentObjective = onboardingProvider.data.objective;
    final theme = Theme.of(context);

    return Scaffold(
      // ---
      // V3: AppBar com Progress Bar Tematizado
      // ---
      appBar: const _OnboardingAppBar(progress: 2 / 13),

      body: Column(
        children: [
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
                  // V3: Botões de Seleção (Refatorados)
                  // ---
                  _ObjectiveCard(
                    text: 'Perder Gordura',
                    isSelected: currentObjective == 'perder_gordura',
                    onTap: () {
                      context
                          .read<OnboardingProvider>()
                          .setObjective('perder_gordura');
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(height: 16),

                  // V3: Opção "Manter" (da Lógica V1) com o estilo V3
                  _ObjectiveCard(
                    text: 'Manter/Saúde',
                    isSelected: currentObjective == 'manter_saude',
                    onTap: () {
                      context
                          .read<OnboardingProvider>()
                          .setObjective('manter_saude');
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(height: 16),

                  _ObjectiveCard(
                    text: 'Ganhar Músculo',
                    isSelected: currentObjective == 'ganhar_musculo',
                    onTap: () {
                      context
                          .read<OnboardingProvider>()
                          .setObjective('ganhar_musculo');
                      HapticFeedback.lightImpact();
                    },
                  ),
                ],
              ),
            ),
          ),

          // ---
          // V3: Botão de Navegação (Haptics, Analytics)
          // ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ElevatedButton(
              // V3: Estilo (Branco) é aplicado automaticamente pelo AppTheme
              onPressed: currentObjective == null
                  ? null // Botão desabilitado
                  : () {
                      // V3: Haptics
                      HapticFeedback.mediumImpact();

                      // V3: Analytics
                      context.read<AnalyticsService>().trackEvent(
                        'onboarding_objective_selected',
                        parameters: {'objective': currentObjective},
                      );

                      // V3: Navegação
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const TargetWeightScreen(),
                      ));
                    },
              child: const Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---
// V3: Widget de Card de Seleção (Local)
// Substitui o 'CustomSelectionButton'
// ---
class _ObjectiveCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ObjectiveCard({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        // V3: Usa a cor e borda do CardTheme
        color: isSelected
            // [CORREÇÃO] 1. 'withOpacity' depreciado. Usando 'withAlpha'
            ? theme.colorScheme.primary.withAlpha((255 * 0.1).round())
            : theme.cardTheme.color,
        shape: isSelected
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.primary, width: 2),
              )
            : theme.cardTheme.shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ---
// V3: Widget de AppBar Consistente
// (Baseado no que foi feito em 'vital_data_screen.dart')
// ---
class _OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double progress; // Ex: 1 / 13

  const _OnboardingAppBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      // V3: Estilo (cor, elevação) vem do AppTheme
      leading: const BackButton(), // V3: Cor vem do AppTheme
      title: Text(
        "Etapa ${(progress * 13).toInt()} de 13",
        style: theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: LinearProgressIndicator(
          value: progress,
          // V3: Cores vêm do AppTheme
          backgroundColor: theme.colorScheme.surfaceContainer,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}
