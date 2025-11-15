import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'supplements_screen.dart'; // Próxima tela (1.17)
// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: O caminho correto
import '../../application/onboarding_provider.dart';
// (Remove 'haptics.dart' V1)
// (Remove 'app_theme.dart' V1)

/// Tela 1.16: O usuário informa os alimentos que NÃO gosta.
/// Refatorada para Fundação V3 (Tema, Haptics, Provider).
class FoodPreferencesScreen extends StatefulWidget {
  const FoodPreferencesScreen({super.key});

  @override
  State<FoodPreferencesScreen> createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  // --- ESTADO LOCAL V3 ---
  // (Mantém a lógica V1, pois a UI é complexa e salva no 'onNext')

  // V3: Lógica V1 mantida (Mock)
  final List<String> _foodOptions = [
    'Brócolis',
    'Ovo',
    'Peixe',
    'Frango',
    'Carne Vermelha',
    'Jiló',
    'Quiabo',
    'Beterraba',
    'Abacate',
  ];

  // V3: Mantém o estado local (Lógica V1)
  final Set<String> _selectedDislikes = {};
  late final TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    // V3: Inicializa o estado local com os dados do Provider
    // (Útil se o usuário voltar para esta tela)
    final providerData = context.read<OnboardingProvider>().data;
    _selectedDislikes.addAll(providerData.foodDislikes);

    // V3: Lógica para separar "Outros"
    String otherText = '';
    final providerOther = _selectedDislikes.firstWhere(
      (e) => !_foodOptions.contains(e),
      orElse: () => '',
    );
    if (providerOther.isNotEmpty) {
      otherText = providerOther;
      _selectedDislikes.remove(providerOther); // Remove do Set de chips
    }

    _otherController = TextEditingController(text: otherText);

    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('food_preferences');
    });
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  // --- AÇÕES V3 ---

  void _onNext() {
    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Implementa o TODO
    // 1. Pega os chips selecionados
    final Set<String> finalDislikes = Set<String>.from(_selectedDislikes);
    // 2. Pega o "Outros" (Lógica V1)
    final String otherDislike = _otherController.text.trim();
    if (otherDislike.isNotEmpty) {
      finalDislikes.add(otherDislike);
    }

    // 3. Salva TUDO no Provider V3
    context.read<OnboardingProvider>().setFoodDislikes(finalDislikes);

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_food_dislikes_set',
      parameters: {
        'dislikes': finalDislikes.join(','),
        'count': finalDislikes.length,
      },
    );

    // V3: Navegação
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SupplementsScreen(), // Navega para 1.17
      ),
    );
  }

  /// Helper V3: Atualiza o estado do chip (Haptics V3)
  void _onChipSelected(String food, bool selected) {
    setState(() {
      if (selected) {
        _selectedDislikes.add(food);
      } else {
        _selectedDislikes.remove(food);
      }
    });
    // V3: Haptics (Substitui V1)
    HapticService.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // [CORREÇÃO] 2. Variável 'canContinue' removida (unused_local_variable)
    // Ela não era usada pois o botão está sempre ativo.
    // const bool canContinue = true;

    return Scaffold(
      // 1. AppBar V3 (Padrão)
      appBar: const _OnboardingAppBar(progress: 12 / 13),
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
                    "O que você NÃO gosta de comer?",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // 5. Subtítulo (V3)
                  Text(
                    "Isso ajuda a IA a criar suas variações. Pode marcar quantos quiser.",
                    // V3: Usa o Tema (Remove AppTheme.secondaryText V1)
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // 6. Input 1 (Seleção Múltipla - Chips V3)
                  // (Refatorado para usar o Tema V3)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _foodOptions
                        .map((food) => _buildFoodChip(food, theme))
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // 7. Input 2 (Texto "Outros" V3)
                  TextField(
                    controller: _otherController,
                    decoration: const InputDecoration(
                      labelText: 'Outros (opcional)',
                      // V3: Estilo V3 (Vem do Tema)
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 96), // Espaço para o botão
                ],
              ),
            ),
          ),
        ],
      ),
      // 8. Botão de Ação (Inferior Fixo - V3 UI)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          // [CORREÇÃO] 1. Removido 'canContinue ? ... : null' (dead_code)
          // Como 'canContinue' era 'const true', o 'null' nunca seria atingido.
          onPressed: _onNext,
          child: const Text('Continuar'),
        ),
      ),
    );
  }

  /// Helper V3: Constrói os FilterChips (Refatorado para Tema V3)
  Widget _buildFoodChip(String food, ThemeData theme) {
    final bool isSelected = _selectedDislikes.contains(food);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      label: Text(food),
      selected: isSelected,
      onSelected: (bool selected) => _onChipSelected(food, selected),
      // ---
      // V3: Estilização (Remove 100% das cores @Deprecated V1)
      // ---
      selectedColor: colorScheme.primary, // V3: Dourado (Tema)
      checkmarkColor: colorScheme.onPrimary, // V3: Preto (Tema)
      labelStyle: TextStyle(
        // V3: Usa o Tema
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
      ),
      backgroundColor: theme.cardTheme.color, // V3: Fundo Card (Tema)
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary // V3: Dourado (Tema)
              : theme.textTheme.bodyMedium!.color!, // V3: Cinza (Tema)
          width: 1.0, // V3: Borda mais grossa
        ),
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
