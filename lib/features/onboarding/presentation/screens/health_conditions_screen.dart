import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cardio_screen.dart'; // Próxima tela (Caminho Feliz)
import 'safety_block_screen.dart'; // Tela de Bloqueio (Caminho Triste)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/procs_back_button.dart';

class HealthConditionsScreen extends StatefulWidget {
  const HealthConditionsScreen({super.key});

  @override
  State<HealthConditionsScreen> createState() => _HealthConditionsScreenState();
}

class _HealthConditionsScreenState extends State<HealthConditionsScreen> {
  final Map<String, String> _conditionOptions = {
    'diabetes': 'Diabetes',
    'hypertension': 'Hipertensão',
    'asthma': 'Asma / Respiratório',
    'heart_issue': 'Problema Cardíaco',
  };

  late final TextEditingController _otherConditionController;
  final FocusNode _otherConditionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final providerData = context.read<OnboardingProvider>().data;
    _otherConditionController =
        TextEditingController(text: providerData.healthConditionsOther);

    _otherConditionController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('health_conditions');
    });
  }

  @override
  void dispose() {
    _otherConditionController.dispose();
    _otherConditionFocusNode.dispose();
    super.dispose();
  }

  void _onNext() {
    final provider = context.read<OnboardingProvider>();
    HapticService.mediumImpact();
    FocusScope.of(context).unfocus();

    // Salva o texto de "Outros" se necessário
    if (provider.data.healthConditions.contains('outros')) {
      provider.setHealthConditionOther(_otherConditionController.text.trim());
    } else {
      provider.setHealthConditionOther(null);
    }

    final hasCondition = provider.data.hasHealthCondition ?? false;

    context.read<AnalyticsService>().trackEvent(
      'onboarding_health_conditions_set',
      parameters: {
        'has_condition': hasCondition,
        'conditions': provider.data.healthConditions.join(','),
        'has_other': provider.data.healthConditions.contains('outros'),
      },
    );

    if (!hasCondition) {
      // CAMINHO FELIZ: Usuário marcou "Não possuo"
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const CardioScreen()));
    } else {
      // CAMINHO DE BLOQUEIO: Usuário marcou "Possuo..."
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SafetyBlockScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();

    final bool? hasCondition = provider.data.hasHealthCondition;
    final selectedConditions = provider.data.healthConditions;
    final bool showOtherField = selectedConditions.contains('outros');

    // Validação:
    // 1. Deve ter escolhido Sim ou Não (hasCondition != null).
    // 2. Se escolheu Sim (hasCondition == true), precisa selecionar pelo menos uma condição OU preencher outros
    bool canContinue = false;
    if (hasCondition == false) {
      canContinue = true;
    } else if (hasCondition == true) {
      canContinue = selectedConditions.isNotEmpty &&
          (!showOtherField || _otherConditionController.text.trim().isNotEmpty);
    }

    return Scaffold(
      appBar: null,
      bottomNavigationBar: hasCondition == true
          ? Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      "O Procs AI adapta o plano, mas não substitui acompanhamento médico.",
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: canContinue ? _onNext : null,
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: PremiumProgressBar(progress: 9 / 17),
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
                      "Você possui alguma condição de saúde?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // NÍVEL 1: A Grande Pergunta
                    PremiumSelectionCard(
                      text: "Não possuo condições de saúde",
                      isSelected: hasCondition == false,
                      onTap: () {
                        HapticService.lightImpact();
                        provider.setHasHealthCondition(false);
                        _otherConditionController.clear();
                        FocusScope.of(context).unfocus();
                        _onNext(); // Auto-advance
                      },
                    ),
                    const SizedBox(height: 12),
                    PremiumSelectionCard(
                      text: "Possuo condições especiais de saúde",
                      isSelected: hasCondition == true,
                      onTap: () {
                        HapticService.lightImpact();
                        provider.setHasHealthCondition(true);
                      },
                    ),

                    // NÍVEL 2: Detalhes (Só aparece se hasCondition == true)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: hasCondition == true
                          ? Column(
                              children: [
                                const SizedBox(height: 24),
                                Text(
                                  "Selecione as condições:",
                                  style: textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                ..._conditionOptions.entries.map((entry) {
                                  final key = entry.key;
                                  final text = entry.value;
                                  final isSelected =
                                      selectedConditions.contains(key);

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    child: PremiumSelectionCard(
                                      text: text,
                                      isSelected: isSelected,
                                      onTap: () {
                                        HapticService.lightImpact();
                                        provider.toggleHealthCondition(key);
                                      },
                                    ),
                                  );
                                }),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Column(
                                    children: [
                                      PremiumSelectionCard(
                                        text: "Outros",
                                        isSelected: showOtherField,
                                        onTap: () {
                                          HapticService.lightImpact();
                                          provider
                                              .toggleHealthCondition('outros');
                                          if (!showOtherField) {
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 200), () {
                                              _otherConditionFocusNode
                                                  .requestFocus();
                                            });
                                          } else {
                                            FocusScope.of(context).unfocus();
                                          }
                                        },
                                      ),
                                      if (showOtherField)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12.0),
                                          child: TextField(
                                            controller:
                                                _otherConditionController,
                                            focusNode: _otherConditionFocusNode,
                                            decoration: const InputDecoration(
                                              labelText: 'Qual condição?',
                                              hintText:
                                                  'Ex: Hérnia de disco...',
                                            ),
                                            style: textTheme.bodyLarge,
                                            maxLines: 3,
                                            textInputAction:
                                                TextInputAction.done,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            onSubmitted: (_) =>
                                                FocusScope.of(context)
                                                    .unfocus(),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 40),
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
