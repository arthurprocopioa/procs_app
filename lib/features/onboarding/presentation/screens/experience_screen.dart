import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/onboarding_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // <-- V3
import '../widgets/premium_progress_bar.dart'; // Importa a barra premium
import '../widgets/premium_selection_card.dart'; // Importa o card padrão (sem ícone)
import 'schedule_screen.dart'; // Próxima tela (1.8)

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  // V3: Os dados de opção agora são locais e mapeados
  // (Mantivemos a chave original para o Provider)
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
      // 1. AppBar removido
      appBar: null,

      // 2. Botão de Continuação fixado no rodapé
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed:
              canContinue ? () => _onNext(context, selectedExperience!) : null,
          child: const Text('Continuar'),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 4/13)
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
                    // Usa a barra premium
                    child: PremiumProgressBar(progress: 4 / 17),
                  ),
                ],
              ),
            ),

            // CONTEÚDO ROLÁVEL
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
                      final text = entry.value;

                      return PremiumSelectionCard(
                        text: text,
                        // O card premium por padrão tem `textAlign: left`,
                        // o que é o novo padrão para consistência.
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
          ],
        ),
      ),
    );
  }
}
