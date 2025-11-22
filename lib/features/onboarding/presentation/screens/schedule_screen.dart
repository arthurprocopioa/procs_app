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
/// Refatorada para o novo padrão de UX (Barra no topo, Botão no rodapé)
/// e novo design dos cards de seleção de dias/frequência.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // V3: Mapa para os dias da semana (Full text para o Card)
  final Map<String, String> _fixedOptions = {
    'monday': 'Segunda-feira',
    'tuesday': 'Terça-feira',
    'wednesday': 'Quarta-feira',
    'thursday': 'Quinta-feira',
    'friday': 'Sexta-feira',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  // V3: Mapa para a frequência (usado na sub-seleção)
  final Map<int, String> _smartOptions = {
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
      // 1. AppBar removido
      appBar: null,

      // 2. Botão de Continuação fixado no rodapé
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed: canContinue ? () => _onNext(context) : null,
          child: const Text('Continuar'),
        ),
      ),

      // 3. Body para a barra de navegação customizada e conteúdo
      body: SafeArea(
        child: Column(
          children: [
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 5/13)
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
                    child: PremiumProgressBar(progress: 5 / 17),
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
                    // NOVA COPY
                    Text(
                      "Com que frequência você vai treinar?",
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Você pode escolher os dias da semana ou quantos treinos você fará na semana.",
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Seleção do Modo: Reutiliza o PremiumSelectionCard
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
                    // Bloco 1: Dias da Semana (NOVA UX - CARDS SEM CHECKBOX)
                    AnimatedCrossFade(
                      firstChild: _buildFixedScheduleCards(provider),
                      secondChild: Container(), // Vazio
                      crossFadeState: data.scheduleMode == 'days_of_week'
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 300),
                    ),

                    // Bloco 2: Quantidade de Vezes (UX CARDS DE SELEÇÃO ÚNICA)
                    AnimatedCrossFade(
                      firstChild: _buildSmartScheduleCards(provider),
                      secondChild: Container(), // Vazio
                      crossFadeState: data.scheduleMode == 'times_per_week'
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 300),
                    ),

                    const SizedBox(height: 40), // Espaço para o rodapé
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// V3 (NOVO UX): Cards de Seleção Múltipla (Dias da Semana)
  Widget _buildFixedScheduleCards(OnboardingProvider provider) {
    final currentDays = provider.data.scheduleDaysOfWeek;
    final theme = Theme.of(context);

    // Usamos Column de Cards, não Grid, para melhor leitura do texto completo
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _fixedOptions.entries.map((entry) {
        final key = entry.key;
        final text = entry.value;
        final isSelected = currentDays.contains(key);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: _DaySelectionCard(
            // Novo widget customizado para seleção múltipla
            text: text,
            isSelected: isSelected,
            onTap: () {
              HapticService.lightImpact();
              provider.toggleScheduleDay(key);
            },
          ),
        );
      }).toList(),
    );
  }

  /// V3 (UX CARDS): Cards de Seleção Única para Quantidade de Treinos
  Widget _buildSmartScheduleCards(OnboardingProvider provider) {
    final currentFrequency = provider.data.scheduleTimesPerWeek;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _smartOptions.entries.map((entry) {
        final key = entry.key;
        final text = entry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          // Usamos o PremiumSelectionCard que já temos (seleção única)
          child: PremiumSelectionCard(
            text: text,
            isSelected: currentFrequency == key,
            onTap: () {
              HapticService.lightImpact();
              provider.setScheduleTimesPerWeek(key);
            },
          ),
        );
      }).toList(),
    );
  }
}

/// NOVO WIDGET: Card de Seleção Múltipla sem Ícone
/// Usado para selecionar os dias da semana (Day Selection)
class _DaySelectionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _DaySelectionCard({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          // Fundo Dourado sutil ou Fundo do Card
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // Borda Dourada ou Borda Inativa
            color: isSelected
                ? colorScheme.primary
                : theme.colorScheme.surfaceContainer,
            width: isSelected ? 2.0 : 1.0,
          ),
          // Sombra Premium
          boxShadow: isSelected
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
            fontWeight: FontWeight.w600,
            // Texto Dourado ou Texto Padrão
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
