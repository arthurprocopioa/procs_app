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

  // ---
  // LÓGICA DE NAVEGAÇÃO (INTOCADA)
  // ---
  void _onNext(BuildContext context, String currentObjective) {
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
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();
    final currentObjective = onboardingProvider.data.objective;
    final theme = Theme.of(context);

    return Scaffold(
      // ---
      // V3: AppBar com Progress Bar Tematizado (INTOCADO)
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
                  // V3: Título (Tematizado) (INTOCADO)
                  // ---
                  Text(
                    "Qual é o seu principal objetivo?",
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // ---
                  // V3: Botões de Seleção (Refatorados)
                  // A LÓGICA DE CHAMADA (onTap) É A MESMA.
                  // ---
                  _ObjectiveCard(
                    text: 'Perder Gordura',
                    icon: Icons.local_fire_department_rounded, // Ícone Premium
                    isSelected: currentObjective == 'perder_gordura',
                    onTap: () {
                      context
                          .read<OnboardingProvider>()
                          .setObjective('perder_gordura');
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(height: 16),
                  _ObjectiveCard(
                    text: 'Manter/Saúde',
                    icon: Icons.health_and_safety_rounded, // Ícone Premium
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
                    icon: Icons.fitness_center_rounded, // Ícone Premium
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
          // V3: Botão de Navegação (INTOCADO)
          // ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ElevatedButton(
              onPressed: currentObjective == null
                  ? null // Botão desabilitado
                  : () => _onNext(context, currentObjective),
              child: const Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---
// V3: O NOVO WIDGET DE CARD PREMIUM (REFATORADO)
// ---
class _ObjectiveCard extends StatelessWidget {
  final String text;
  final IconData icon; // Novo: Ícone para dar polimento
  final bool isSelected;
  final VoidCallback onTap;

  const _ObjectiveCard({
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      // 1. Substituímos o Card por um AnimatedContainer para suavizar
      //    a mudança de cor, borda e sombra.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          // 2. A cor de fundo é mais sutil quando selecionada
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : theme.cardTheme.color, // Cor base do tema
          borderRadius: BorderRadius.circular(16),
          // 3. A borda muda de cor e espessura
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.surfaceContainer, // Cor 'inativa' do tema
            width: isSelected ? 2.0 : 1.0,
          ),
          // 4. (O TOQUE PREMIUM) Adicionamos um brilho (glow) quando selecionado
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.15),
                    blurRadius: 12.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [], // Sem sombra quando não selecionado
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 5. Adicionamos o Ícone para polimento visual
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                // 6. O texto também muda de cor para dar ênfase
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---
// V3: Widget de AppBar Consistente (INTOCADO)
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
