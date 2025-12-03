import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'training_time_screen.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/procs_back_button.dart';

/// REFACTOR: Opções simplificadas e seleção de dias.
class CardioScreen extends StatefulWidget {
  const CardioScreen({super.key});

  @override
  State<CardioScreen> createState() => _CardioScreenState();
}

class _CardioScreenState extends State<CardioScreen> {
  final Map<int, String> _cardioFrequencyOptions = {
    1: '1x na semana',
    2: '2x na semana',
    3: '3x na semana',
    4: '4x na semana',
    5: '5x na semana',
    6: '6x na semana',
    7: 'Todo dia',
  };

  final Map<String, String> _weekDays = {
    'monday': 'Segunda',
    'tuesday': 'Terça',
    'wednesday': 'Quarta',
    'thursday': 'Quinta',
    'friday': 'Sexta',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  final List<String> _weekDaysOrder = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('cardio');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onCardioDayToggled(String dayKey) {
    final provider = context.read<OnboardingProvider>();
    // Safe access for Hot Reload support
    final rawDays = provider.data.selectedCardioDays as dynamic;
    final currentDays =
        rawDays != null ? Set<String>.from(rawDays) : <String>{};

    if (currentDays.contains(dayKey)) {
      currentDays.remove(dayKey);
    } else {
      // Limita a seleção à frequência escolhida
      final frequency = provider.data.cardioTimesPerWeek ?? 0;
      if (currentDays.length < frequency) {
        currentDays.add(dayKey);
      } else {
        HapticService.lightImpact();
        return;
      }
    }

    provider.setSelectedCardioDays(currentDays);
    HapticService.lightImpact();
  }

  void _onNext() {
    HapticService.mediumImpact();
    final provider = context.read<OnboardingProvider>();
    final data = provider.data;

    // Safe access
    final rawDays = data.selectedCardioDays as dynamic;
    final selectedDaysList =
        rawDays != null ? (rawDays as Set<String>).toList() : <String>[];

    context.read<AnalyticsService>().trackEvent(
      'onboarding_cardio_set',
      parameters: {
        'preference': data.cardioPreference,
        'type': data.cardioType,
        'times': data.cardioTimesPerWeek,
        'selected_days': selectedDaysList,
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
      final frequency = data.cardioTimesPerWeek;
      if (frequency == null) return false;

      // Safe access
      final rawDays = data.selectedCardioDays as dynamic;
      final selectedDays =
          rawDays != null ? (rawDays as Set<String>) : <String>{};

      // Validação de dias selecionados
      if (selectedDays.length != frequency) return false;
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();

    final bool canContinue = _getCanContinue(provider);
    final bool showDetails = provider.data.cardioPreference == 'sim';

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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  ProcsBackButton(),
                  SizedBox(width: 16),
                  Expanded(
                    child: PremiumProgressBar(progress: 10 / 17),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
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
                        // Reset selections if changing preference
                        if (provider.data.cardioType == null) {
                          _scrollToBottom();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    PremiumSelectionCard(
                      text: "Não, prefiro focar na musculação",
                      isSelected: provider.data.cardioPreference == 'nao',
                      onTap: () {
                        HapticService.lightImpact();
                        provider.setCardioPreference('nao');
                      },
                    ),

                    const SizedBox(height: 24),

                    // PASSO 2 e 3 (Aninhados)
                    if (showDetails) _buildCardioDetails(context, provider),

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
    final frequency = data.cardioTimesPerWeek;

    // Safe access
    final rawDays = data.selectedCardioDays as dynamic;
    final selectedDays =
        rawDays != null ? (rawDays as Set<String>) : <String>{};

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Qual cardio você prefere?",
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          PremiumSelectionCard(
            text: "Caminhada ou Corrida (Esteira / Rua)",
            isSelected: data.cardioType == 'corrida',
            onTap: () {
              HapticService.lightImpact();
              provider.setCardioType('corrida');
              _scrollToBottom();
            },
          ),
          const SizedBox(height: 12),
          PremiumSelectionCard(
            text: "Ciclismo (Ergométrica / Rua)",
            isSelected: data.cardioType == 'ciclismo',
            onTap: () {
              HapticService.lightImpact();
              provider.setCardioType('ciclismo');
              _scrollToBottom();
            },
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
                  _scrollToBottom();
                },
              ),
            );
          }),

          // SEÇÃO DE DIAS (Só aparece se frequência selecionada)
          if (frequency != null) ...[
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Quais dias você prefere fazer cardio?",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Selecione $frequency dias.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selectedDays.length == frequency
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _weekDaysOrder.map((dayKey) {
                  final isSelected = selectedDays.contains(dayKey);
                  final label = _weekDays[dayKey]!;

                  return FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => _onCardioDayToggled(dayKey),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: theme.cardTheme.color,
                    checkmarkColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
