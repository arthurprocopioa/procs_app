import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'food_preferences_screen.dart'; // Próxima tela (1.16)
// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: O caminho correto
import '../../application/onboarding_provider.dart';
// (Remove 'haptics.dart' V1)
// (Remove 'app_theme.dart' V1)

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
    final initialPage = _currentMealCount - _minMeals;

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

    // V3: Implementa o TODO (Salva o estado local no Provider)
    final provider = context.read<OnboardingProvider>();
    provider.setMealCount(_currentMealCount);

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_meal_count_set',
      parameters: {'meal_count': _currentMealCount},
    );

    // V3: Navegação
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FoodPreferencesScreen(), // Navega para 1.16
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Lógica V1 mantida: Esta tela é opcional, o botão está sempre ativo.
    // const bool canContinue = true; // [CORREÇÃO] Variável agora é desnecessária

    return Scaffold(
      // 1. AppBar V3 (Padrão)
      appBar: const _OnboardingAppBar(progress: 11 / 13),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // 4. Título (V3)
                  Text(
                    "Quantas refeições você faz por dia?",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64), // Mais espaço (V1)

                  // 5. Input V3 (Ruler Picker)
                  // (Descarta _Slider V1)
                  _buildMealRuler(theme),

                  const SizedBox(height: 96), // Espaço para o botão
                ],
              ),
            ),
          ),
        ],
      ),
      // 7. Botão de Ação (Inferior Fixo - V3 UI)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          // [CORREÇÃO] 1. Removido 'canContinue ? ... : null' (dead_code)
          onPressed: _onNext,
          child: const Text('Continuar'),
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
            itemCount: _totalMeals, // 3, 4, 5, 6 (4 itens)
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

          // O subtítulo "refeições" (V3: Dourado)
          Positioned(
            top: 0,
            child: Text(
              "refeições",
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

// ---
// V3: Widget de AppBar Consistente
// (Padrão V3)
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
