import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'equipment_screen.dart'; // Próxima tela (1.9)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// V3 (NOVOS IMPORTS): Widgets reutilizáveis
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';

/// V3 (PONTO 6): Tela de Agenda (Frequência)
/// Refatorada para a nova UX (Ponto 6) e para usar
/// o Data Model e Provider do Sprint 1.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // V3 (PONTO 6): A UI agora é baseada no `scheduleMode`
  // 'days_of_week' ou 'times_per_week'

  // V3: Mapa para os dias da semana
  final Map<String, String> _fixedOptions = {
    'sunday': 'Domingo',
    'monday': 'Segunda',
    'tuesday': 'Terça',
    'wednesday': 'Quarta',
    'thursday': 'Quinta',
    'friday': 'Sexta',
    'saturday': 'Sábado',
  };

  // V3: Mapa para a frequência
  final Map<int, String> _smartOptions = {
    1: '1 vez por semana',
    2: '2 vezes por semana',
    3: '3 vezes por semana',
    4: '4 vezes por semana',
    5: '5 vezes por semana',
    6: '6 vezes por semana',
    7: '7 vezes por semana',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('schedule');
    });
  }

  /// V3: Ação de 'Próximo' (usando nova lógica do Provider)
  void _onNext(BuildContext context) {
    final provider = context.read<OnboardingProvider>();
    HapticService.mediumImpact();

    final analyticsParams = {
      'schedule_mode': provider.data.scheduleMode,
      'schedule_days': provider.data.scheduleDaysOfWeek.join(','),
      'schedule_times': provider.data.scheduleTimesPerWeek?.toString(),
    };
    context.read<AnalyticsService>().trackEvent(
          'onboarding_schedule_set',
          parameters: analyticsParams,
        );

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const EquipmentScreen(), // Navega para 1.9
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;

    // V3 (PONTO 6): Lógica de ativação do botão "Próximo"
    final bool canContinue;
    if (data.scheduleMode == 'days_of_week') {
      canContinue = data.scheduleDaysOfWeek.isNotEmpty;
    } else if (data.scheduleMode == 'times_per_week') {
      canContinue = data.scheduleTimesPerWeek != null;
    } else {
      canContinue = false;
    }

    return Scaffold(
      appBar: AppBar(
        // V3 (PONTO 2): "Etapa" removido
        title: null,
        // V3 (PONTO 3): Nova barra de progresso
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(8.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: PremiumProgressBar(progress: 5 / 13),
          ),
        ),
      ),
      // V3 (PONTO 15): Adiciona SingleChildScrollView
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              "Com que frequência você quer treinar?",
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // V3 (PONTO 6): Nova UX de seleção de modo
            PremiumSelectionCard(
              text: "Selecionar dias da semana",
              isSelected: data.scheduleMode == 'days_of_week',
              onTap: () {
                HapticService.lightImpact();
                provider.setScheduleMode('days_of_week');
              },
            ),
            const SizedBox(height: 16),
            PremiumSelectionCard(
              text: "Selecionar quantidade de vezes",
              isSelected: data.scheduleMode == 'times_per_week',
              onTap: () {
                HapticService.lightImpact();
                provider.setScheduleMode('times_per_week');
              },
            ),

            const SizedBox(height: 32),

            // V3 (PONTO 6): Anima a aparição das opções
            // Bloco 1: Dias da Semana
            AnimatedCrossFade(
              firstChild: _buildFixedScheduleTab(provider),
              secondChild: Container(), // Vazio
              crossFadeState: data.scheduleMode == 'days_of_week'
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),

            // Bloco 2: Quantidade de Vezes
            AnimatedCrossFade(
              firstChild: _buildSmartScheduleTab(provider),
              secondChild: Container(), // Vazio
              crossFadeState: data.scheduleMode == 'times_per_week'
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),

            const SizedBox(height: 40), // Espaço antes do botão

            // V3 (PONTO 8b/15): Botão dentro do scroll
            ElevatedButton(
              onPressed: canContinue ? () => _onNext(context) : null,
              child: const Text('Continuar'),
            ),
            const SizedBox(height: 40), // Espaço de fim de scroll
          ],
        ),
      ),
    );
  }

  /// V3 (PONTO 6): Tab 'Selecionar quantidade de vezes'
  Widget _buildSmartScheduleTab(OnboardingProvider provider) {
    final currentFrequency = provider.data.scheduleTimesPerWeek;

    // V3 (PONTO 5): Usa GridView para um layout mais premium
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _smartOptions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final key = _smartOptions.keys.elementAt(index);
        final text =
            _smartOptions.values.elementAt(index).split(' ').first; // "1", "2"
        final subtext = _smartOptions.values
            .elementAt(index)
            .split(' ')
            .sublist(1)
            .join(' '); // "vez por semana"

        final isSelected = currentFrequency == key;

        return _buildGridCard(
          text: text,
          subtext: subtext,
          isSelected: isSelected,
          onTap: () {
            HapticService.lightImpact();
            provider.setScheduleTimesPerWeek(key);
          },
        );
      },
    );
  }

  /// V3 (PONTO 6): Tab 'Selecionar dias da semana'
  Widget _buildFixedScheduleTab(OnboardingProvider provider) {
    final currentDays = provider.data.scheduleDaysOfWeek;

    // V3 (PONTO 5): Usa GridView aqui também
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1, // Mais "quadrado"
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _fixedOptions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final key = _fixedOptions.keys.elementAt(index);
        final text =
            _fixedOptions.values.elementAt(index).substring(0, 3); // "Seg"
        final subtext = _fixedOptions.values.elementAt(index); // "Segunda"

        final isSelected = currentDays.contains(key);

        return _buildGridCard(
          text: text,
          subtext: subtext,
          isSelected: isSelected,
          onTap: () {
            HapticService.lightImpact();
            provider.toggleScheduleDay(key);
          },
        );
      },
    );
  }

  /// V3 (PONTO 7): Widget de Card de Seleção para o Grid
  Widget _buildGridCard({
    required String text,
    required String subtext,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary // Fundo Dourado Sólido
              : theme.cardTheme.color, // Cor base do card
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : theme.colorScheme.surfaceContainer, // Borda inativa
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? colorScheme.onPrimary // Texto Preto/Escuro
                    : colorScheme.onSurface, // Texto padrão
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary.withOpacity(0.8)
                    : colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
