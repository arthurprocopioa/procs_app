import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'injuries_screen.dart'; // Próxima tela
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart'; // O Card Oficial
import '../widgets/procs_back_button.dart';

class FocusAreaScreen extends StatefulWidget {
  const FocusAreaScreen({super.key});

  @override
  State<FocusAreaScreen> createState() => _FocusAreaScreenState();
}

class _FocusAreaScreenState extends State<FocusAreaScreen> {
  final Map<String, String> _focusOptions = {
    'full_body': 'Corpo Inteiro',
    'shoulders': 'Ombros',
    'arms': 'Braços',
    'back': 'Costas',
    'chest': 'Peito',
    'abs': 'Abdômen',
    'glutes': 'Glúteos',
    'legs': 'Pernas',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('focus_area');
    });
  }

  void _onNext() {
    final provider = context.read<OnboardingProvider>();
    HapticService.mediumImpact();

    final analyticsParams = {
      'focus_areas': provider.data.focusAreas.join(','),
    };
    context.read<AnalyticsService>().trackEvent(
          'onboarding_focus_area_set',
          parameters: analyticsParams,
        );

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const InjuriesScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final selectedAreas = provider.data.focusAreas;

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: PremiumProgressBar(progress: 7 / 17),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      "Em quais áreas seu treinamento deve se concentrar?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Isto é opcional. Selecione 'Corpo Inteiro' ou áreas específicas.",
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ..._focusOptions.entries.map((entry) {
                      final key = entry.key;
                      final text = entry.value;
                      final isSelected = selectedAreas.contains(key);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: PremiumSelectionCard(
                          text: text,
                          isSelected: isSelected,
                          onTap: () {
                            HapticService.lightImpact();
                            provider.toggleFocusArea(key);
                            // Auto-advance only for Full Body
                            if (key == 'full_body') {
                              _onNext();
                            }
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: selectedAreas.isNotEmpty ? _onNext : null,
                child: const Text("Continuar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Classe _FocusSelectionCard removida.
