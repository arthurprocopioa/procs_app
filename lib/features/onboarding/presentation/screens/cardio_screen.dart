import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'training_time_screen.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/procs_back_button.dart';
import '../../../../core/widgets/gravity_background.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final rawDays = provider.data.selectedCardioDays as dynamic;
    final currentDays =
        rawDays != null ? Set<String>.from(rawDays) : <String>{};

    if (currentDays.contains(dayKey)) {
      currentDays.remove(dayKey);
    } else {
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
    // Verifica se precisa limpar dados caso seja 'nao'
    final provider = context.read<OnboardingProvider>();
    if (provider.data.cardioPreference == 'nao') {
      // Opcional: limpar type, freq, days se existirem
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TrainingTimeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;

    // Lógica de Visibilidade das Seções
    final bool showSection2 = data.cardioPreference == 'sim';
    final bool showSection3 = showSection2 && data.cardioType != null;
    final bool showSection4 = showSection3 && data.cardioTimesPerWeek != null;

    // Validação para o botão Continuar
    bool canContinue = false;
    if (data.cardioPreference == 'nao') {
      canContinue = true;
    } else if (data.cardioPreference == 'sim') {
      if (data.cardioType != null && data.cardioTimesPerWeek != null) {
        final rawDays = data.selectedCardioDays as dynamic;
        final selectedDays =
            rawDays != null ? (rawDays as Set<String>) : <String>{};
        if (selectedDays.length == data.cardioTimesPerWeek) {
          canContinue = true;
        }
      }
    }

    return Scaffold(
      appBar: null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed: canContinue ? _onNext : null,
          child: const Text('Continuar'),
        ),
      ),
      body: GravityBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header Fixo
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const ProcsBackButton(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PremiumProgressBar(progress: 10 / 17),
                    ),
                  ],
                ),
              ),

              // Conteúdo Scrollável
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

                      // SEÇÃO 1: Preferência (Sim / Não)
                      PremiumSelectionCard(
                        text: "Sim, quero adicionar",
                        isSelected: data.cardioPreference == 'sim',
                        onTap: () {
                          HapticService.lightImpact();
                          provider.setCardioPreference('sim');
                          _scrollToBottom();
                        },
                      ),
                      const SizedBox(height: 16),
                      PremiumSelectionCard(
                        text: "Não, prefiro focar na musculação",
                        isSelected: data.cardioPreference == 'nao',
                        onTap: () {
                          HapticService.lightImpact();
                          provider.setCardioPreference('nao');
                          _onNext();
                        },
                      ),

                      const SizedBox(height: 24),

                      // SEÇÃO 2: Tipo de Cardio
                      if (showSection2) ...[
                        AnimatedOpacity(
                          opacity: showSection2 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
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
                            ],
                          ),
                        ),
                      ],

                      // SEÇÃO 3: Frequência
                      if (showSection3) ...[
                        AnimatedOpacity(
                          opacity: showSection3 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Quantas vezes por semana?",
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              ..._cardioFrequencyOptions.entries.map((entry) {
                                final key = entry.key;
                                final text = entry.value;
                                final isSelected =
                                    data.cardioTimesPerWeek == key;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: PremiumSelectionCard(
                                    text: text,
                                    isSelected: isSelected,
                                    onTap: () {
                                      HapticService.lightImpact();
                                      provider.setCardioTimesPerWeek(key);
                                      if (key == 7) {
                                        provider.setSelectedCardioDays(
                                            _weekDaysOrder.toSet());
                                      }
                                      _scrollToBottom();
                                    },
                                  ),
                                );
                              }),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],

                      // SEÇÃO 4: Dias da Semana
                      if (showSection4) ...[
                        AnimatedOpacity(
                          opacity: showSection4 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Column(
                            children: [
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
                                  "Selecione ${data.cardioTimesPerWeek} dias.",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
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
                                    final rawDays =
                                        data.selectedCardioDays as dynamic;
                                    final selectedDays = rawDays != null
                                        ? (rawDays as Set<String>)
                                        : <String>{};
                                    final isSelected =
                                        selectedDays.contains(dayKey);
                                    final label = _weekDays[dayKey]!;

                                    return FilterChip(
                                      label: Text(label),
                                      selected: isSelected,
                                      onSelected: (_) =>
                                          _onCardioDayToggled(dayKey),
                                      selectedColor: theme.colorScheme.primary,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.onSurface,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      backgroundColor: theme.cardTheme.color,
                                      checkmarkColor:
                                          theme.colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Colors.transparent
                                              : theme.colorScheme.outline
                                                  .withOpacity(0.3),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 8),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
