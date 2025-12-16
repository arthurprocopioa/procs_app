import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'equipment_screen.dart'; // Próxima tela (1.9)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/procs_back_button.dart';

/// V3 (PONTO 6): Tela de Agenda (Frequência e Dias)
/// REFACTOR FINAL: Seleção de quantidade de treinos e dias da semana.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScrollController _scrollController = ScrollController();

  // Mapa simplificado apenas para quantidade
  final Map<int, String> _frequencyOptions = {
    1: '1 treino por semana',
    2: '2 treinos por semana',
    3: '3 treinos por semana',
    4: '4 treinos por semana',
    5: '5 treinos por semana',
    6: '6 treinos por semana',
    7: '7 treinos por semana',
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

  // Ordem correta dos dias para exibição
  final List<String> _weekDaysOrder = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('schedule');
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
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onFrequencySelected(int times) {
    HapticService.lightImpact();
    final provider = context.read<OnboardingProvider>();
    provider.setScheduleTimesPerWeek(times);

    // OTIMIZAÇÃO: Se for 7 dias, seleciona todos automaticamente
    if (times == 7) {
      provider.setSelectedTrainingDays(_weekDaysOrder.toSet());
    }

    _scrollToBottom();
  }

  void _onDayToggled(String dayKey) {
    final provider = context.read<OnboardingProvider>();
    final currentDays = Set<String>.from(provider.data.selectedTrainingDays);

    if (currentDays.contains(dayKey)) {
      currentDays.remove(dayKey);
    } else {
      // Limita a seleção à frequência escolhida
      final frequency = provider.data.scheduleTimesPerWeek ?? 0;
      if (currentDays.length < frequency) {
        currentDays.add(dayKey);
      } else {
        // Opcional: Feedback visual ou haptico de erro/limite
        HapticService.lightImpact();
        return;
      }
    }

    provider.setSelectedTrainingDays(currentDays);
    HapticService.lightImpact();
  }

  void _onNext(BuildContext context) {
    final provider = context.read<OnboardingProvider>();
    HapticService.mediumImpact();

    context.read<AnalyticsService>().trackEvent(
      'onboarding_schedule_set',
      parameters: {
        'schedule_times': provider.data.scheduleTimesPerWeek,
        'selected_days': provider.data.selectedTrainingDays.toList(),
      },
    );

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const EquipmentScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;
    final frequency = data.scheduleTimesPerWeek;

    // Validação: Frequência selecionada E número de dias igual à frequência
    final bool isValid =
        frequency != null && data.selectedTrainingDays.length == frequency;

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            // Barra de progresso (Passo 5/17)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: PremiumProgressBar(progress: 5 / 17),
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
                      "Com que frequência você vai treinar?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Escolha a quantidade ideal de dias para o seu compromisso semanal.",
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // SEÇÃO 1: Frequência
                    ..._frequencyOptions.entries.map((entry) {
                      final key = entry.key;
                      final text = entry.value;
                      final isSelected = frequency == key;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: PremiumSelectionCard(
                          text: text,
                          isSelected: isSelected,
                          onTap: () => _onFrequencySelected(key),
                        ),
                      );
                    }),

                    const SizedBox(height: 40),

                    // SEÇÃO 2: Dias da Semana (Só aparece se frequência selecionada)
                    if (frequency != null) ...[
                      Text(
                        "Quais dias você prefere treinar?",
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Selecione $frequency dias.",
                        style: textTheme.bodyMedium?.copyWith(
                          color: data.selectedTrainingDays.length == frequency
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: _weekDaysOrder.map((dayKey) {
                          final isSelected =
                              data.selectedTrainingDays.contains(dayKey);
                          final label = _weekDays[dayKey]!;

                          return FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (_) => _onDayToggled(dayKey),
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
                            checkmarkColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : theme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ),

            // Botão Continuar
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: isValid ? () => _onNext(context) : null,
                child: const Text("Continuar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
