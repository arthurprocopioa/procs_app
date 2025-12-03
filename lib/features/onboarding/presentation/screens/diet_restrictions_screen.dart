import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'meal_routine_screen.dart'; // Próxima tela
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/procs_back_button.dart'; // Botão de voltar minimalista

/// Tela 1.14: Início da "Fase 2 - Dieta" (Passo 12/17).
/// REFACTOR FINAL: Correção da lógica de seleção exclusiva "Não tenho restrição".
class DietRestrictionsScreen extends StatefulWidget {
  const DietRestrictionsScreen({super.key});

  @override
  State<DietRestrictionsScreen> createState() => _DietRestrictionsScreenState();
}

class _DietRestrictionsScreenState extends State<DietRestrictionsScreen> {
  final Map<String, String> _restrictionOptions = {
    'vegano': 'Vegano',
    'vegetariano': 'Vegetariano',
    'sem_gluten': 'Sem Glúten',
    'sem_lactose': 'Sem Lactose',
  };

  late final TextEditingController _otherRestrictionController;
  final FocusNode _otherRestrictionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final initialOther =
        context.read<OnboardingProvider>().data.dietOtherRestriction;
    _otherRestrictionController =
        TextEditingController(text: initialOther ?? '');

    // Adiciona listener para atualizar o botão quando o texto mudar
    _otherRestrictionController.addListener(() {
      setState(() {});
    });

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

  void _onNext() {
    HapticService.mediumImpact();
    FocusScope.of(context).unfocus();

    final provider = context.read<OnboardingProvider>();
    final data = provider.data;

    // Salva o campo "Outros" se necessário
    if (data.dietRestrictions.contains('outros')) {
      provider.setDietOtherRestriction(_otherRestrictionController.text.trim());
    } else {
      provider.setDietOtherRestriction(null);
    }

    context.read<AnalyticsService>().trackEvent(
      'onboarding_diet_restrictions_set',
      parameters: {
        'restrictions': data.dietRestrictions.join(','),
        'has_no_restriction': data.dietHasNoRestrictions,
        'other_details_length': _otherRestrictionController.text.trim().length,
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MealRoutineScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;

    final bool showOtherTextField = data.dietRestrictions.contains('outros');

    // Validação: Pode continuar se "Não tenho" for true OU se tiver alguma restrição marcada
    // E se "Outros" estiver marcado, o texto não pode ser vazio.
    final bool canContinue =
        (data.dietHasNoRestrictions || data.dietRestrictions.isNotEmpty) &&
            (!showOtherTextField ||
                _otherRestrictionController.text.trim().isNotEmpty);

    return Scaffold(
      appBar: null,
      bottomNavigationBar: showOtherTextField
          ? Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: canContinue ? _onNext : null,
                child: const Text('Continuar'),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra de Progresso (12/17) e Botão Voltar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: PremiumProgressBar(progress: 12 / 17),
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
                      "Você tem alguma restrição alimentar?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Isso nos ajuda a criar a dieta ideal. Pode marcar mais de uma.",
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // CARD EXCLUSIVO: NÃO TENHO RESTRIÇÃO
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: PremiumSelectionCard(
                        text: "Não tenho restrição alimentar",
                        isSelected: data.dietHasNoRestrictions,
                        onTap: () {
                          HapticService.lightImpact();
                          provider.setDietHasNoRestrictions(
                              !data.dietHasNoRestrictions);

                          _otherRestrictionController.clear();
                          FocusScope.of(context).unfocus();
                          _onNext(); // Auto-advance
                        },
                      ),
                    ),

                    // SELEÇÃO MÚLTIPLA
                    ..._restrictionOptions.entries.map((entry) {
                      final isSelected =
                          data.dietRestrictions.contains(entry.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: PremiumSelectionCard(
                          text: entry.value,
                          isSelected: isSelected,
                          onTap: () {
                            HapticService.lightImpact();
                            provider.toggleDietRestriction(entry.key);
                            _onNext(); // Auto-advance
                          },
                        ),
                      );
                    }),

                    // OPÇÃO OUTROS
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Column(
                        children: [
                          PremiumSelectionCard(
                            text: "Outros",
                            isSelected: showOtherTextField,
                            onTap: () {
                              HapticService.lightImpact();
                              provider.toggleDietRestriction('outros');

                              if (!showOtherTextField) {
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  _otherRestrictionFocusNode.requestFocus();
                                });
                              } else {
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),

                          // Campo de texto animado
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: showOtherTextField
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: TextField(
                                      controller: _otherRestrictionController,
                                      focusNode: _otherRestrictionFocusNode,
                                      decoration: const InputDecoration(
                                        labelText: 'Quais outras restrições?',
                                      ),
                                      style: textTheme.bodyLarge,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) =>
                                          FocusScope.of(context).unfocus(),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 64),
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
