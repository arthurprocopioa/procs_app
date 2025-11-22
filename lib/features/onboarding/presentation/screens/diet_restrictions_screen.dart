import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'meal_routine_screen.dart'; // Próxima tela (1.13/15)
// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// V3 (NOVOS IMPORTS): Widgets reutilizáveis
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart'; // Para seleção única/múltipla

/// Tela 1.14: Início da "Fase 2 - Dieta" (Passo 12/15).
/// Refatorada para Fundação V3, UI Premium e lógica de exclusividade.
class DietRestrictionsScreen extends StatefulWidget {
  const DietRestrictionsScreen({super.key});

  @override
  State<DietRestrictionsScreen> createState() => _DietRestrictionsScreenState();
}

class _DietRestrictionsScreenState extends State<DietRestrictionsScreen> {
  // V3: Lógica V1 (Chaves) mantida, mas agora como um Map V3
  final Map<String, String> _restrictionOptions = {
    'vegano': 'Vegano',
    'vegetariano': 'Vegetariano',
    'sem_gluten': 'Sem Glúten',
    'sem_lactose': 'Sem Lactose',
  };

  // Controller e FocusNode para a opção "Outros"
  final TextEditingController _otherRestrictionController =
      TextEditingController();
  final FocusNode _otherRestrictionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // V3: Inicializa o controller com o dado do provider (se existir)
    final initialOther =
        context.read<OnboardingProvider>().data.dietOtherRestriction;
    _otherRestrictionController.text = initialOther ?? '';

    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('diet_restrictions');
    });
  }

  @override
  void dispose() {
    _otherRestrictionController.dispose();
    _otherRestrictionFocusNode.dispose();
    super.dispose();
  }

  /// V3: Ação de 'Próximo'
  void _onNext() {
    // V3: Haptics
    HapticService.mediumImpact();
    FocusScope.of(context).unfocus(); // Fecha o teclado com segurança

    final provider = context.read<OnboardingProvider>();
    final data = provider.data;

    // 1. Salva o campo "Outros" (apenas se 'Outros' estiver entre as restrições)
    if (data.dietRestrictions.contains('outros')) {
      provider.setDietOtherRestriction(_otherRestrictionController.text.trim());
    } else {
      // Se não tem 'outros' selecionado, garante que o campo está limpo no provider
      provider.setDietOtherRestriction(null);
    }

    // 2. Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_diet_restrictions_set',
      parameters: {
        'restrictions': data.dietRestrictions.join(','),
        'has_no_restriction': data.dietHasNoRestrictions,
        'other_details_length': _otherRestrictionController.text.trim().length,
      },
    );

    // V3: Navegação
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MealRoutineScreen(), // Navega para 13/15
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;

    // A validação é sempre TRUE se o usuário não tiver restrições,
    // ou se tiver pelo menos uma restrição (incluindo 'outros').
    final bool canContinue =
        data.dietHasNoRestrictions || data.dietRestrictions.isNotEmpty;

    final bool showOtherTextField = data.dietRestrictions.contains('outros');

    return Scaffold(
      // 1. AppBar removido
      appBar: null,

      // 2. Botão de Continuação fixado no rodapé
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed: canContinue ? _onNext : null,
          child: const Text('Continuar'),
        ),
      ),

      // 3. Body para a barra de navegação customizada e conteúdo
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 12/15)
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
                    // Progress bar: 12/15
                    child: PremiumProgressBar(progress: 12 / 17),
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
                    // Título (V3)
                    Text(
                      "Você tem alguma restrição alimentar?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Subtítulo (V3)
                    Text(
                      "Isso nos ajuda a criar a dieta ideal. Pode marcar mais de uma.",
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // --- NOVO CARD: NÃO TENHO RESTRIÇÃO (EXCLUSIVO) ---
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: PremiumSelectionCard(
                        text: "Não tenho restrição alimentar",
                        isSelected: data.dietHasNoRestrictions,
                        onTap: () {
                          HapticService.lightImpact();
                          provider.setDietHasNoRestrictions(
                              !data.dietHasNoRestrictions);
                          FocusScope.of(context).unfocus(); // Fecha teclado
                        },
                      ),
                    ),

                    // --- SELEÇÃO MÚLTIPLA (Restrições Padrão) ---
                    ..._restrictionOptions.entries.map((entry) {
                      return _buildRestrictionCard(
                        key: entry.key,
                        text: entry.value,
                        provider: provider,
                        isNoRestrictionActive: data.dietHasNoRestrictions,
                      );
                    }),

                    // --- NOVA OPÇÃO: OUTROS ---
                    _buildRestrictionCard(
                      key: 'outros',
                      text: 'Outros',
                      provider: provider,
                      isNoRestrictionActive: data.dietHasNoRestrictions,
                    ),

                    // --- TEXTFIELD CONDICIONAL PARA OUTROS ---
                    AnimatedOpacity(
                      opacity: showOtherTextField ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Visibility(
                        visible: showOtherTextField,
                        maintainState: true,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: TextField(
                            controller: _otherRestrictionController,
                            focusNode: _otherRestrictionFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Quais outras restrições?',
                            ),
                            style: textTheme.bodyLarge,
                            maxLines: 2,
                            textInputAction:
                                TextInputAction.done, // OK/Concluir
                            onSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                      ),
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

  /// Helper V3: Constrói os cards de restrição (Seleção Múltipla)
  Widget _buildRestrictionCard({
    required String key,
    required String text,
    required OnboardingProvider provider,
    required bool isNoRestrictionActive,
  }) {
    // DESABILITA TODOS OS CARDS SE "NÃO TENHO RESTRIÇÃO" ESTIVER ATIVO
    final bool isEnabled = !isNoRestrictionActive;
    final bool isSelected = provider.data.dietRestrictions.contains(key);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Cor do texto quando o card está desabilitado
    final Color disabledTextColor =
        theme.colorScheme.onSurface.withOpacity(0.3);
    // Cor da borda quando o card está desabilitado
    final Color disabledBorderColor = theme.colorScheme.surfaceContainer;

    // Se estiver desabilitado, o onTap é nulo.
    final VoidCallback? onTap = isEnabled
        ? () {
            HapticService.lightImpact();
            provider.toggleDietRestriction(key);
            // Move o foco para o campo "Outros" se for a opção 'outros'
            if (key == 'outros' && !isSelected) {
              Future.delayed(const Duration(milliseconds: 100), () {
                _otherRestrictionFocusNode.requestFocus();
              });
            } else {
              _otherRestrictionFocusNode.unfocus();
            }
          }
        : null;

    // Usamos o design de card limpo (Seleção Múltipla - Borda Dourada)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: isSelected && isEnabled
                ? colorScheme.primary.withOpacity(0.1)
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected && isEnabled
                  ? colorScheme.primary
                  : disabledBorderColor,
              width: isSelected && isEnabled ? 2.0 : 1.0,
            ),
            boxShadow: isSelected && isEnabled
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.15),
                      blurRadius: 12.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight:
                  isSelected && isEnabled ? FontWeight.w600 : FontWeight.normal,
              color: isEnabled
                  ? (isSelected ? colorScheme.primary : colorScheme.onSurface)
                  : disabledTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
