import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_diet_plan_screen.dart';
// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// V3 (NOVOS IMPORTS): Widgets reutilizáveis
import '../widgets/premium_progress_bar.dart';
import '../widgets/procs_back_button.dart';

/// Tela 1.16: O usuário informa o que NÃO gosta de comer (Passo 14/15).
/// Refatorada para Fundação V3, UI Premium e correção de bugs do TextField.
class FoodPreferencesScreen extends StatefulWidget {
  const FoodPreferencesScreen({super.key});

  @override
  State<FoodPreferencesScreen> createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  // V3: Opções pré-definidas (Lógica V1)
  final List<String> _foodOptions = [
    'Brócolis',
    'Ovo',
    'Peixe',
    'Frango',
    'Carne Vermelha',
    'Jiló',
    'Quiabo',
    'Beterraba',
    'Abacate'
  ];

  // Estado local para gerenciar as seleções e o campo "Outros"
  late Set<String> _dislikedFoods;
  late final TextEditingController _otherController;
  final FocusNode _otherFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final providerData = context.read<OnboardingProvider>().data;

    // Inicializa o estado local com os dados do provider
    _dislikedFoods = Set<String>.from(providerData.foodDislikes);

    // Encontra a string "Outros" (se houver) e a coloca no controller
    final otherFood = _dislikedFoods.firstWhere(
      (food) => !_foodOptions.contains(food), // Encontra o que não é padrão
      orElse: () => '', // Retorna vazio se não houver "Outros"
    );
    _otherController = TextEditingController(text: otherFood);

    // Remove o "Outros" do Set para não ser tratado como chip
    if (otherFood.isNotEmpty) {
      _dislikedFoods.remove(otherFood);
    }

    // Se não tem nada selecionado e nem texto, assumimos que não marcou nada ainda
    // (ou poderíamos assumir que come de tudo se já tivesse passado por aqui,
    // mas para forçar a escolha, deixamos false).
    // Se quiser persistir o "como de tudo", precisaríamos de um flag no provider.
    // Por enquanto, vamos inferir: se a lista está vazia mas o usuário já tinha avançado...
    // Na verdade, melhor deixar o usuário escolher explicitamente.

    _otherController.addListener(() {
      setState(() {}); // Atualiza para habilitar/desabilitar botão
    });

    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('food_preferences');
    });
  }

  @override
  void dispose() {
    _otherController.dispose();
    _otherFocusNode.dispose();
    super.dispose();
  }

  /// V3: Ação de 'Próximo' (Continuar com restrições)
  void _onNext() {
    HapticService.mediumImpact();
    FocusScope.of(context).unfocus();

    // Adiciona o texto de "Outros" ao Set final
    final otherText = _otherController.text.trim();
    if (otherText.isNotEmpty) {
      _dislikedFoods.add(otherText);
    }

    final provider = context.read<OnboardingProvider>();
    provider.setFoodDislikes(_dislikedFoods);

    final analytics = context.read<AnalyticsService>();
    analytics.trackEvent(
      'onboarding_food_dislikes_set',
      parameters: {
        'dislikes_count': _dislikedFoods.length,
        'has_other': otherText.isNotEmpty,
        'eats_everything': false,
      },
    );

    _finishOnboarding(context, provider, analytics);
  }

  /// Ação de 'Como de tudo' (Sem restrições)
  void _onEatsEverything() {
    HapticService.mediumImpact();
    FocusScope.of(context).unfocus();

    final provider = context.read<OnboardingProvider>();
    provider.setEatsEverything();

    final analytics = context.read<AnalyticsService>();
    analytics.trackEvent(
      'onboarding_food_dislikes_set',
      parameters: {
        'dislikes_count': 0,
        'has_other': false,
        'eats_everything': true,
      },
    );

    _finishOnboarding(context, provider, analytics);
  }

  void _finishOnboarding(BuildContext context, OnboardingProvider provider,
      AnalyticsService analytics) {
    // Check if region was auto-detected and log it
    if (provider.data.userRegion != null) {
      analytics.trackEvent(
        'onboarding_region_set',
        parameters: {
          'region': provider.data.userRegion!,
          'auto_detected': true,
        },
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoadingDietPlanScreen(),
      ),
    );
  }

  /// V3: Lógica de toggle local para os chips
  void _toggleFood(String food) {
    HapticService.lightImpact();
    setState(() {
      if (_dislikedFoods.contains(food)) {
        _dislikedFoods.remove(food);
      } else {
        _dislikedFoods.add(food);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Validação: Continuar só habilita se tiver algo selecionado ou escrito
    final bool canContinue =
        _dislikedFoods.isNotEmpty || _otherController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botão "Como de tudo" (Estilo similar ao Continuar)
            ElevatedButton(
              onPressed: _onEatsEverything,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurface,
              ),
              child: const Text('Como de tudo (Sem restrições)'),
            ),
            const SizedBox(height: 12),
            // Botão Continuar
            ElevatedButton(
              onPressed: canContinue ? _onNext : null,
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),

      // 3. Body para a barra de navegação customizada e conteúdo
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 14/15)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    // Progress bar: 14/15
                    child: PremiumProgressBar(progress: 14 / 16),
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
                    // Título (Copywriting Aprimorado - Ponto 4)
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: textTheme.headlineMedium,
                        children: [
                          const TextSpan(text: "O que você "),
                          TextSpan(
                            text: "não", // "não" em minúsculo
                            style: TextStyle(
                                color: theme.colorScheme.primary), // Dourado
                          ),
                          const TextSpan(text: " gosta de comer?"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtítulo (Copywriting Aprimorado - Ponto 5)
                    Text(
                      "Sua dieta será montada com base nas suas preferências, garantindo que seu plano seja prazeroso e fácil de seguir.",
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // V3: Chips de Seleção (Design Premium)
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      alignment: WrapAlignment.center,
                      children: _foodOptions.map((food) {
                        final isSelected = _dislikedFoods.contains(food);
                        return _buildFoodChip(theme, food, isSelected);
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // V3 (PONTO 3): Caixa "Outros" (Corrigida)
                    TextField(
                      controller: _otherController,
                      focusNode: _otherFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Outros (opcional)',
                      ),
                      style: textTheme.bodyLarge,
                      // CORREÇÃO DO BUG (3b): Ação para OK/Concluir
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        _otherFocusNode.unfocus(); // Fecha o teclado
                      },
                    ),

                    const SizedBox(height: 64), // Espaço para o botão
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper V3: Constrói os Chips de Alimentos (Design Premium)
  /// Substitui o design antigo que usava "check"
  Widget _buildFoodChip(ThemeData theme, String food, bool isSelected) {
    final colorScheme = theme.colorScheme;

    return FilterChip(
      label: Text(food),
      selected: isSelected,
      onSelected: (bool selected) => _toggleFood(food),

      // --- ESTILO PREMIUM (Ponto 4 da sua crítica anterior) ---
      showCheckmark: false, // Remove o ícone de "check"
      backgroundColor: theme.cardTheme.color,
      selectedColor:
          colorScheme.primary.withValues(alpha: 0.1), // Fundo dourado sutil

      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected
            ? colorScheme.primary // Texto dourado
            : colorScheme.onSurface.withValues(alpha: 0.8),
      ),

      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary // Borda dourada
              : colorScheme.surfaceContainer.withValues(alpha: 0.5),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
    );
  }
}
