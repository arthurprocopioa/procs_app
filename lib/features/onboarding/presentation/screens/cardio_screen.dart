import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'training_time_screen.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/ai_feedback_card.dart';
import '../widgets/procs_back_button.dart';

/// REFACTOR: Opção "IA Decide" removida. Apenas Sim/Não.
class CardioScreen extends StatefulWidget {
  const CardioScreen({super.key});

  @override
  State<CardioScreen> createState() => _CardioScreenState();
}

class _CardioScreenState extends State<CardioScreen> {
  late final TextEditingController _otherCardioController;
  final FocusNode _otherCardioFocusNode = FocusNode();

  final Map<int, String> _cardioFrequencyOptions = {
    1: '1x na semana',
    2: '2x na semana',
    3: '3x na semana',
    4: '4x na semana',
    5: '5x na semana',
    6: '6x na semana',
    7: 'Todo dia',
  };

  @override
  void initState() {
    super.initState();
    final providerData = context.read<OnboardingProvider>().data;
    _otherCardioController =
        TextEditingController(text: providerData.cardioOtherDetail);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('cardio');
    });
  }

  @override
  void dispose() {
    _otherCardioController.dispose();
    _otherCardioFocusNode.dispose();
    super.dispose();
  }

  void _onNext() {
    HapticService.mediumImpact();
    final provider = context.read<OnboardingProvider>();
    final data = provider.data;

    FocusScope.of(context).unfocus();

    if (data.cardioType == 'outros') {
      provider.setCardioType('outros',
          otherDetail: _otherCardioController.text.trim());
    }

    context.read<AnalyticsService>().trackEvent(
      'onboarding_cardio_set',
      parameters: {
        'preference': data.cardioPreference,
        'type': data.cardioType,
        'times': data.cardioTimesPerWeek,
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TrainingTimeScreen(),
      ),
    );
  }

  bool _getCanContinue(OnboardingProvider provider) {
    final data = provider.data;
    final preference = data.cardioPreference;

    if (preference == null) return false;

    if (preference == 'nao') {
      return true;
    }

    if (preference == 'sim') {
      if (data.cardioType == null) return false;
      if (data.cardioType == 'outros' &&
          _otherCardioController.text.trim().isEmpty) {
        return false;
      }
      if (data.cardioTimesPerWeek == null) return false;
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;

    final bool canContinue = _getCanContinue(provider);

    return Scaffold(
      appBar: null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed: canContinue ? _onNext : null,
          child: const Text('Continuar'),
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
                    child: PremiumProgressBar(progress: 10 / 17),
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
                      "Você deseja adicionar cardio ao seu treino?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // PASSO 1: Preferência
                    PremiumSelectionCard(
                      text: "Sim, quero adicionar",
                      isSelected: provider.data.cardioPreference == 'sim',
                      onTap: () {
                        HapticService.lightImpact();
                        provider.setCardioPreference('sim');
                        _otherCardioFocusNode.unfocus();
                      },
                    ),
                    const SizedBox(height: 16),
                    PremiumSelectionCard(
                      text: "Não, prefiro focar na musculação",
                      isSelected: provider.data.cardioPreference == 'nao',
                      onTap: () {
                        HapticService.lightImpact();
                        provider.setCardioPreference('nao');
                        _otherCardioFocusNode.unfocus();
                      },
                    ),

                    const SizedBox(height: 24),

                    // PASSO 2 e 3 (Aninhados)
                    _buildCardioDetails(context, provider),

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

  Widget _buildCardioDetails(
      BuildContext context, OnboardingProvider provider) {
    final theme = Theme.of(context);
    final data = provider.data;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: (data.cardioPreference == 'sim')
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Qual cardio você prefere?",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                PremiumSelectionCard(
                  text: "Corrida / Caminhada",
                  isSelected: data.cardioType == 'corrida',
                  onTap: () {
                    HapticService.lightImpact();
                    provider.setCardioType('corrida');
                  },
                ),
                const SizedBox(height: 12),
                PremiumSelectionCard(
                  text: "Ciclismo (Bike)",
                  isSelected: data.cardioType == 'ciclismo',
                  onTap: () {
                    HapticService.lightImpact();
                    provider.setCardioType('ciclismo');
                  },
                ),
                const SizedBox(height: 12),
                PremiumSelectionCard(
                  text: "Natação",
                  isSelected: data.cardioType == 'natacao',
                  onTap: () {
                    HapticService.lightImpact();
                    provider.setCardioType('natacao');
                  },
                ),
                const SizedBox(height: 12),
                PremiumSelectionCard(
                  text: "Outros",
                  isSelected: data.cardioType == 'outros',
                  onTap: () {
                    HapticService.lightImpact();
                    provider.setCardioType('outros');
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: (data.cardioType == 'outros')
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextField(
                            controller: _otherCardioController,
                            focusNode: _otherCardioFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Qual outro cardio?',
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              _otherCardioFocusNode.unfocus();
                            },
                            onChanged: (text) {
                              provider.setCardioType('outros',
                                  otherDetail: text);
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 40),
                Text(
                  "Quantas vezes por semana?",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ..._cardioFrequencyOptions.entries.map((entry) {
                  final key = entry.key;
                  final text = entry.value;
                  final isSelected = data.cardioTimesPerWeek == key;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: PremiumSelectionCard(
                      text: text,
                      isSelected: isSelected,
                      onTap: () {
                        HapticService.lightImpact();
                        provider.setCardioTimesPerWeek(key);
                      },
                    ),
                  );
                }).toList(),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
