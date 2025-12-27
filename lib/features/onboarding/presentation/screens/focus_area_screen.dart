import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'injuries_screen.dart'; // Próxima tela
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/procs_back_button.dart';
// import '../../../../core/widgets/gravity_background.dart';

class FocusAreaScreen extends StatefulWidget {
  const FocusAreaScreen({super.key});

  @override
  State<FocusAreaScreen> createState() => _FocusAreaScreenState();
}

class _FocusAreaScreenState extends State<FocusAreaScreen> {
  final List<Map<String, String>> _focusOptions = [
    {
      'key': 'full_body',
      'label': 'Corpo inteiro',
      'image': 'assets/images/focus_areas/full_body.png'
    },
    {
      'key': 'shoulders',
      'label': 'Ombros',
      'image': 'assets/images/focus_areas/shoulders.png'
    },
    {
      'key': 'arms',
      'label': 'Braços',
      'image': 'assets/images/focus_areas/arms.png'
    },
    {
      'key': 'back',
      'label': 'Costas',
      'image': 'assets/images/focus_areas/back.png'
    },
    {
      'key': 'chest',
      'label': 'Peito',
      'image': 'assets/images/focus_areas/chest.png'
    },
    {
      'key': 'abs',
      'label': 'Abdômen',
      'image': 'assets/images/focus_areas/abs.png'
    },
    {
      'key': 'glutes',
      'label': 'Glúteos',
      'image': 'assets/images/focus_areas/glutes.png'
    },
    {
      'key': 'legs',
      'label': 'Pernas',
      'image': 'assets/images/focus_areas/legs.png'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Forçar limpeza de cache para garantir que novas imagens geradas apareçam
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

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
      backgroundColor: Colors.black,
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
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "Em quais áreas seu treinamento deve se concentrar?",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Selecione 'Corpo Inteiro' ou áreas específicas.",
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.75, // Ajustado para imagem + texto
                      ),
                      itemCount: _focusOptions.length,
                      itemBuilder: (context, index) {
                        final option = _focusOptions[index];
                        final key = option['key']!;
                        final label = option['label']!;
                        final imagePath = option['image']!;
                        final isSelected = selectedAreas.contains(key);

                        return GestureDetector(
                          onTap: () {
                            HapticService.lightImpact();
                            provider.toggleFocusArea(key);
                            if (key == 'full_body') {
                              // Optional: auto-advance or just update selection
                              // _onNext(); // Keeping manual based on previous request "Continuar button"
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    // Removemos a cor de fundo branca explícita, a imagem cobrirá tudo
                                    // color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : Colors
                                              .transparent, // Borda apenas quando selecionado
                                      width: isSelected
                                          ? 3
                                          : 1, // Espessura ajustada
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                    ],
                                  ),
                                  clipBehavior: Clip
                                      .antiAlias, // Garante que a imagem respeite o arredondamento
                                  // Sem padding para a imagem preencher o card
                                  child: Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover, // Preenche todo o espaço
                                    // Se a imagem tiver fundo branco, ela será o próprio fundo do card
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.fitness_center,
                                          color: Colors.grey);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                label,
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: selectedAreas.isNotEmpty ? _onNext : null,
                child: const Text("Próximo"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Classe _FocusSelectionCard removida.
