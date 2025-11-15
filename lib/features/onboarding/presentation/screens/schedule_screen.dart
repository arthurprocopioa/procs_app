import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'equipment_screen.dart'; // Próxima tela (1.9)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';

// Enum local para controlar o estado do Toggle V3
enum _ScheduleMode { smart, fixed }

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Estado V3: Controla o toggle localmente
  _ScheduleMode _selectedMode = _ScheduleMode.smart;

  // Mapa V3: Opções para o modo 'Smart'
  final Map<int?, String> _smartOptions = {
    1: '1 treino/semana',
    2: '2 treinos/semana',
    3: '3_treinos/semana', // (Visto na Ref)
    4: '4 treinos/semana',
    5: '5 treinos/semana',
    6: '6 treinos/semana',
    7: 'Todos os dias', // (Visto na Ref)
  };

  // Mapa V3: Opções para o modo 'Fixed'
  final Map<String, String> _fixedOptions = {
    'sunday': 'Domingo',
    'monday': 'Segunda-Feira',
    'tuesday': 'Terça-Feira',
    'wednesday': 'Quarta-Feira',
    'thursday': 'Quinta-Feira',
    'friday': 'Sexta-Feira',
    'saturday': 'Sábado',
  };

  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('schedule');
    });
  }

  /// V3: Navega para a próxima tela
  void _onNext(BuildContext context) {
    final provider = context.read<OnboardingProvider>();

    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Analytics (Salva o modo e a seleção)
    final analyticsParams = {
      'mode': provider.data.schedulingMode,
      'smart_frequency': provider.data.smartFrequency?.toString(),
      'fixed_days': provider.data.fixedDays.join(','),
    };
    context.read<AnalyticsService>().trackEvent(
          'onboarding_schedule_set',
          parameters: analyticsParams,
        );

    // V3: Navegação
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const EquipmentScreen(), // Navega para 1.9
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final provider = context.watch<OnboardingProvider>();

    // V3: Lógica de ativação do botão "Próximo"
    final bool isSmartSelected = provider.data.schedulingMode == 'smart' &&
        provider.data.smartFrequency != null;
    final bool isFixedSelected = provider.data.schedulingMode == 'fixed' &&
        provider.data.fixedDays.isNotEmpty;
    final bool canContinue = isSmartSelected || isFixedSelected;

    return Scaffold(
      appBar: AppBar(
        // V3: Título do AppBar (Usa o Tema V3)
        title: Text(
          "Etapa 5 de 13",
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: Column(
        children: [
          // V3: Barra de Progresso (Usa o Tema V3)
          LinearProgressIndicator(
            value: 5 / 13,
            backgroundColor: theme.colorScheme.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // V3: Título (Usa o Tema V3)
                  Text(
                    "Com que frequência você quer treinar?",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // V3: Toggle (Referência)
                  _buildScheduleToggle(theme, provider),

                  const SizedBox(height: 16),

                  // V3: Subtítulo (Muda baseado no Toggle)
                  Text(
                    _selectedMode == _ScheduleMode.smart
                        ? "Adaptarei dinamicamente sua agenda de acordo com sua atividade e preferências."
                        : "Você pode escolher os dias da semana específicos que deseja trabalhar.",
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // V3: Conteúdo (Muda baseado no Toggle)
                  if (_selectedMode == _ScheduleMode.smart)
                    _buildSmartScheduleTab(provider)
                  else
                    _buildFixedScheduleTab(provider),

                  const SizedBox(height: 96), // Espaço para o botão
                ],
              ),
            ),
          ),
        ],
      ),
      // V3: Botão Ancorado
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          // V3: Estilo V3 (Referência)
          style: ElevatedButton.styleFrom(
            backgroundColor: canContinue
                ? const Color(0xFF303030)
                : theme.colorScheme.surfaceContainer,
            foregroundColor:
                canContinue ? Colors.white : theme.textTheme.bodyMedium?.color,
          ),
          onPressed: canContinue ? () => _onNext(context) : null,
          child: const Text('Próximo'),
        ),
      ),
    );
  }

  /// V3: Widget do Toggle ('Inteligente' / 'Fixo')
  Widget _buildScheduleToggle(ThemeData theme, OnboardingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ToggleButtons(
        isSelected: [
          _selectedMode == _ScheduleMode.smart,
          _selectedMode == _ScheduleMode.fixed,
        ],
        onPressed: (index) {
          HapticService.lightImpact();
          setState(() {
            _selectedMode =
                index == 0 ? _ScheduleMode.smart : _ScheduleMode.fixed;
          });
          // V3: Salva no Provider
          provider.setSchedulingMode(
              _selectedMode == _ScheduleMode.smart ? 'smart' : 'fixed');
        },
        // V3: Estilização do Toggle (Premium)
        color: theme.textTheme.bodyMedium?.color, // Cor Inativa
        selectedColor: theme.colorScheme.onSurface, // Cor Ativa
        fillColor: theme.cardTheme.color, // Fundo Ativo
        splashColor: theme.colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        borderWidth: 0,
        selectedBorderColor: Colors.transparent,
        borderColor: Colors.transparent,
        constraints: BoxConstraints.expand(
            width: (MediaQuery.of(context).size.width / 2) - 36, // 50/50
            height: 48),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('AGENDA INTELIGENTE'),
              const SizedBox(width: 4),
              Text('✨', style: theme.textTheme.bodySmall), // Ícone V3
            ],
          ),
          const Text('HORÁRIO FIXO'),
        ],
      ),
    );
  }

  /// V3: Tab 'Agenda Inteligente'
  Widget _buildSmartScheduleTab(OnboardingProvider provider) {
    final currentFrequency = provider.data.smartFrequency;

    return Column(
      children: _smartOptions.entries.map((entry) {
        final key = entry.key;
        final text = entry.value;
        final isSelected = currentFrequency == key;

        return _buildSelectionCard(
          text: text,
          isSelected: isSelected,
          onTap: () {
            HapticService.lightImpact();
            provider.setSmartFrequency(key);
          },
        );
      }).toList(),
    );
  }

  /// V3: Tab 'Horário Fixo'
  Widget _buildFixedScheduleTab(OnboardingProvider provider) {
    final currentDays = provider.data.fixedDays;

    return Column(
      children: _fixedOptions.entries.map((entry) {
        final key = entry.key;
        final text = entry.value;
        final isSelected = currentDays.contains(key);

        return _buildSelectionCard(
          text: text,
          isSelected: isSelected,
          onTap: () {
            HapticService.lightImpact();
            provider.toggleFixedDay(key);
          },
        );
      }).toList(),
    );
  }

  /// V3: Widget de Card de Seleção (Reutilizado)
  Widget _buildSelectionCard({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    // V3: Estilo 'Ativo' (Preto) ou 'Inativo' (Cinza)
    final Color bgColor = isSelected
        ? const Color(0xFF303030) // Fundo Preto (Visto na Ref)
        : theme.cardTheme.color!; // Fundo Cinza (Tema V3)

    final Color fgColor =
        isSelected ? Colors.white : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: fgColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
