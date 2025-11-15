import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/onboarding_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // <-- V3
import 'schedule_screen.dart'; // Próxima tela (1.8)

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  // V3: Os dados de opção agora são locais e mapeados
  // (Lógica V3 da imagem de referência)
  final Map<String, String> _experienceOptions = {
    'iniciante': 'Sou novo no fitness',
    'intermediario': 'Eu malho de vez em quando',
    'avancado': 'Eu me exercito regularmente',
  };

  @override
  void initState() {
    super.initState();
    // V3: Analytics (initState)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('experience');
    });
  }

  void _onNext(BuildContext context, String selectedExperience) {
    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Analytics (Evento)
    context.read<AnalyticsService>().trackEvent(
      'onboarding_experience_set',
      parameters: {'experience': selectedExperience},
    );

    // V3: Navegação
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ScheduleScreen(), // Navega para 1.8
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // V3: O estado vem do Provider
    final provider = context.watch<OnboardingProvider>();
    final selectedExperience = provider.data.experienceLevel;
    final bool canContinue = selectedExperience != null;

    return Scaffold(
      // V3: AppBar (Reutilizado)
      appBar: const _OnboardingAppBar(progress: 4 / 13),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // V3: Título (Tematizado)
                  Text(
                    "Qual é o seu nível de preparo físico atual?",
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // V3: Botões de Card (Substitui _buildSelectionButton V1)
                  ..._experienceOptions.entries.map((entry) {
                    final key = entry.key;
                    final subtitle = entry.value;
                    // V3: O título é o 'key' capitalizado
                    final title = key[0].toUpperCase() + key.substring(1);

                    return _ExperienceCard(
                      title: title,
                      subtitle: subtitle,
                      isSelected: selectedExperience == key,
                      onTap: () {
                        // V3: Salva no Provider e Haptics
                        context
                            .read<OnboardingProvider>()
                            .setExperienceLevel(key);
                        HapticService.lightImpact();
                      },
                    );
                  }).expand((widget) => [widget, const SizedBox(height: 16)]),
                ],
              ),
            ),
          ),

          // V3: Botão de Navegação (Tematizado)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ElevatedButton(
              // V3: Estilo (Branco) é aplicado automaticamente pelo AppTheme
              onPressed: canContinue
                  ? () => _onNext(context, selectedExperience)
                  : null,
              child: const Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---
// V3: Widget de Card de Seleção (Pixel-Perfect com a Referência)
// Substitui o 'OutlinedButton' V1
// ---
class _ExperienceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExperienceCard({
    required this.title,
    required this.subtitle,
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
            // [CORREÇÃO] 1. Substituído 'withOpacity(0.1)' por 'withAlpha(26)'
            // (deprecated_member_use)
            ? theme.colorScheme.primary.withAlpha(26)
            : theme.cardTheme.color,
        shape: isSelected
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.primary, width: 2),
              )
            : theme.cardTheme.shape,
        child: ListTile(
          // V3: Layout Título/Subtítulo da Referência
          title: Text(title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}

// ---
// V3: Widget de AppBar Consistente
// ---
class _OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double progress;

  const _OnboardingAppBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading: const BackButton(),
      title: Text(
        "Etapa ${(progress * 13).round()} de 13",
        style: theme.appBarTheme.titleTextStyle,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.surfaceContainer,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}
