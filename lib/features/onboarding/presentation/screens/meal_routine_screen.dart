import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'food_preferences_screen.dart'; // Próxima tela (1.14/15)
// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// V3 (NOVOS IMPORTS): Widgets reutilizáveis
import '../widgets/premium_progress_bar.dart';
import '../widgets/procs_back_button.dart';

/// Tela 1.15: O usuário informa o número de refeições diárias.
/// Refatorada para Fundação V3 e UI V3 ("Ruler Picker").
class MealRoutineScreen extends StatefulWidget {
  const MealRoutineScreen({super.key});

  @override
  State<MealRoutineScreen> createState() => _MealRoutineScreenState();
}

class _MealRoutineScreenState extends State<MealRoutineScreen> {
  // ---
  // ESTADO LOCAL V3 (Para o Ruler Picker)
  // ---
  late final PageController _pageController;
  late int _currentMealCount;

  // Lógica V1 mantida: Min/Max de refeições
  final int _minMeals = 3;
  final int _maxMeals = 6;
  late final int _totalMeals;

  @override
  void initState() {
    super.initState();
    _totalMeals = _maxMeals - _minMeals + 1;

    // V3: Inicializa o estado local com os dados do Provider
    final providerData = context.read<OnboardingProvider>().data;
    _currentMealCount = providerData.mealCount ?? 4; // Padrão V1 (4)

    // Calcula a página inicial baseada no valor (3=0, 4=1, 5=2, 6=3)
    final initialPage =
        (_currentMealCount - _minMeals).clamp(0, _totalMeals - 1);

    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: 0.25, // Mostra 3-4 números
    );

    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('meal_routine');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---
  // AÇÕES V3
  // ---
  void _onNext() {
    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Salva o estado local no Provider
    final provider = context.read<OnboardingProvider>();
    provider.setMealCount(_currentMealCount);

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_meal_count_set',
      parameters: {'meal_count': _currentMealCount},
    );

    // V3: Navegação para a próxima tela (Food Preferences, 14/15)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FoodPreferencesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      // 1. AppBar removido
      appBar: null,

      // 2. Botão de Ação (Inferior Fixo - V3 UI)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          // O botão é sempre ativo (lógica original)
          onPressed: _onNext,
          child: const Text('Continuar'),
        ),
      ),

      // 3. Body para a barra de navegação customizada e conteúdo
      body: SafeArea(
        child: Column(
          children: [
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 13/15)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    // Progress bar: 13/15
                    child: PremiumProgressBar(progress: 13 / 16),
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
                    const SizedBox(height: 16),
                    // 4. Título (Copywriting Aprimorado)
                    Text(
                      "Quantas refeições você pretende fazer por dia?",
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // 5. Subtítulo (Copywriting Aprimorado)
                    Text(
                      "O seu plano de nutrição será adaptado para o seu número de REFEIÇÕES preferido, otimizando o planejamento calórico e o timing de macronutrientes.",
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 64),

                    // 6. Input V3 (Ruler Picker)
                    _buildMealRuler(theme),

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

  /// Helper V3: Constrói o "Ruler Picker" (Padrão V3)
  Widget _buildMealRuler(ThemeData theme) {
    return SizedBox(
      height: 120, // Altura fixa para o ruler
      child: Stack(
        alignment: Alignment.center,
        children: [
          // O PageView com os números
          PageView.builder(
            controller: _pageController,
            itemCount: _totalMeals,
            onPageChanged: (int pageIndex) {
              final int mealValue = pageIndex + _minMeals;
              if (_currentMealCount != mealValue) {
                // V3: Haptics
                HapticService.lightImpact();
                setState(() {
                  _currentMealCount = mealValue;
                });
              }
            },
            itemBuilder: (context, index) {
              final int mealValue = index + _minMeals;
              final bool isSelected = (_currentMealCount == mealValue);

              // V3: Estilo do Tema
              final style = isSelected
                  ? theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    )
                  : theme.textTheme.headlineMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color,
                    );

              return Center(
                child: Text(
                  mealValue.toString(),
                  style: style,
                ),
              );
            },
          ),

          // O indicador central (V3: Dourado)
          Positioned(
            bottom: 0,
            child: Container(
              width: 3,
              height: 30,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // O subtítulo "REFEIÇÕES" (V3: Dourado - AGORA EM MAIÚSCULAS)
          Positioned(
            top: 0,
            child: Text(
              "REFEIÇÕES", // CAPITALIZAÇÃO CORRIGIDA
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
