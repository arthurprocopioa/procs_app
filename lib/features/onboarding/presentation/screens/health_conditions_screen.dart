import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cardio_screen.dart'; // Próxima tela
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/procs_back_button.dart'; // Botão de voltar minimalista

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

    if (provider.data.healthConditions.contains('outros')) {
      provider.setHealthConditionOther(_otherConditionController.text.trim());
    } else {
      provider.setHealthConditionOther(null);
    }

    context.read<AnalyticsService>().trackEvent(
      'onboarding_health_conditions_set',
      parameters: {
        'conditions': provider.data.healthConditions.join(','),
        'has_other': provider.data.healthConditions.contains('outros'),
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CardioScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final selectedConditions = provider.data.healthConditions;

    final bool showOtherField = selectedConditions.contains('outros');

    return Scaffold(
      appBar: null,
      bottomNavigationBar: Padding(
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
              onPressed: _onNext,
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
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

                    const SizedBox(height: 8),
                    Text(
                      "Selecione uma ou mais opções abaixo. Se não encontrar a sua, selecione 'Outros' para descrever.",
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),

                    // CORREÇÃO DE ESPAÇAMENTO:
                    // Reduzi para 24 e removi o padding bottom extra do primeiro item
                    // para que o ritmo vertical seja constante.
                    const SizedBox(height: 24),

                    // Card: Não possuo
                    // Removido o Padding bottom: 16.0 específico que causava o gap extra
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: PremiumSelectionCard(
                        text: "Não possuo condição de saúde",
                        isSelected: selectedConditions.contains('none'),
                        onTap: () {
                          HapticService.lightImpact();
                          provider.toggleHealthCondition('none');
                          _otherConditionController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),

                    // Lista de condições
                    ..._conditionOptions.entries.map((entry) {
                      final key = entry.key;
                      final text = entry.value;
                      final isSelected = selectedConditions.contains(key);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Column(
                        children: [
                          PremiumSelectionCard(
                            text: "Outros",
                            isSelected: showOtherField,
                            onTap: () {
                              HapticService.lightImpact();
                              provider.toggleHealthCondition('outros');

                              if (!showOtherField) {
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  _otherConditionFocusNode.requestFocus();
                                });
                              } else {
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: showOtherField
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: TextField(
                                      controller: _otherConditionController,
                                      focusNode: _otherConditionFocusNode,
                                      decoration: const InputDecoration(
                                        labelText: 'Qual condição?',
                                        hintText: 'Ex: Hérnia de disco...',
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
