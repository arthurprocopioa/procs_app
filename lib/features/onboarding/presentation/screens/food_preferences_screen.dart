import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'supplements_screen.dart'; // Próxima tela (1.15/15)
// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// V3 (NOVOS IMPORTS): Widgets reutilizáveis
import '../widgets/premium_progress_bar.dart';

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

  /// V3: Ação de 'Próximo'
  void _onNext() {
    // V3: Haptics
    HapticService.mediumImpact();
    // CORREÇÃO DO BUG: Fecha o teclado com segurança
    FocusScope.of(context).unfocus();

    // Adiciona o texto de "Outros" ao Set final
    final otherText = _otherController.text.trim();
    if (otherText.isNotEmpty) {
      _dislikedFoods.add(otherText);
    }

    final provider = context.read<OnboardingProvider>();
    provider.setFoodDislikes(_dislikedFoods);

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_food_dislikes_set',
      parameters: {
        'dislikes_count': _dislikedFoods.length,
        'has_other': otherText.isNotEmpty,
      },
    );

    // V3: Navegação para a última tela de Dieta (Suplementos)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SupplementsScreen(), // Navega para 15/15
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

    return Scaffold(
      // 1. AppBar removido
      appBar: null,

      // 2. Botão de Continuação fixado no rodapé (Resolve Bug 3a)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          // Tela opcional, botão sempre ativo
          onPressed: _onNext,
          child: const Text('Continuar'),
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
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.arrow_back,
                        color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    // Progress bar: 14/15
                    child: PremiumProgressBar(progress: 14 / 17),
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
          colorScheme.primary.withOpacity(0.1), // Fundo dourado sutil

      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected
            ? colorScheme.primary // Texto dourado
            : colorScheme.onSurface.withOpacity(0.8),
      ),

      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary // Borda dourada
              : colorScheme.surfaceContainer.withOpacity(0.5),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
    );
  }
}
