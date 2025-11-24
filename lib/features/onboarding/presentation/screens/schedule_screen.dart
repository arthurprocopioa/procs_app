import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'equipment_screen.dart'; // Próxima tela (1.9)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/procs_back_button.dart';

/// V3 (PONTO 6): Tela de Agenda (Frequência)
/// REFACTOR FINAL: Seleção direta de quantidade de treinos. Simples e direto.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('schedule');
    });
  }

  void _onNext(BuildContext context) {
    final provider = context.read<OnboardingProvider>();
    HapticService.mediumImpact();

    context.read<AnalyticsService>().trackEvent(
      'onboarding_schedule_set',
      parameters: {
        'schedule_times': provider.data.scheduleTimesPerWeek,
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

    // Apenas valida se a quantidade foi selecionada
    final bool canContinue = data.scheduleTimesPerWeek != null;

    return Scaffold(
      appBar: null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed: canContinue ? () => _onNext(context) : null,
          child: const Text('Continuar'),
        ),
      ),
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

                    // Lista direta de opções de frequência
                    ..._frequencyOptions.entries.map((entry) {
                      final key = entry.key;
                      final text = entry.value;
                      final isSelected = data.scheduleTimesPerWeek == key;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: PremiumSelectionCard(
                          text: text,
                          isSelected: isSelected,
                          onTap: () {
                            HapticService.lightImpact();
                            provider.setScheduleTimesPerWeek(key);
                          },
                        ),
                      );
                    }).toList(),

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
