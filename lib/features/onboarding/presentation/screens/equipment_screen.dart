import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'focus_area_screen.dart'; // Próxima tela (1.10)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';

/// Tela 1.9: Onde o usuário informa onde treina (Lógica V1, UI V3).
/// Refatorada para usar a Fundação V3 (Tema, Haptics, Provider).
class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  // V3: O Controller ainda é local (Estado V1)
  late final TextEditingController _otherEquipmentController;

  // V3: Mapa de Lógica de Opções Primárias
  final Map<String, String> _locationOptions = {
    'academia': 'Academia',
    'casa_sem': 'Em casa sem equipamentos',
    'casa_com': 'Em casa com poucos equipamentos',
  };

  // V3: Mapa de Lógica de Sub-Opções (Checkboxes)
  final Map<String, String> _homeEquipmentOptions = {
    'halteres': 'Halteres',
    'elasticos': 'Elásticos',
    'barra': 'Barra (puxar) ou Halter (levantar)',
    'caneleiras': 'Caneleiras',
  };

  @override
  void initState() {
    super.initState();
    // V3: Inicializa o controller com o dado do provider (se existir)
    final initialOther = context.read<OnboardingProvider>().data.otherEquipment;
    _otherEquipmentController = TextEditingController(text: initialOther);

    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('equipment');
    });
  }

  @override
  void dispose() {
    _otherEquipmentController.dispose();
    super.dispose();
  }

  /// V3: Ação de 'Próximo'
  void _onNext() {
    final provider = context.read<OnboardingProvider>();

    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Salva o 'Outros' (o resto já está no provider)
    provider.setOtherEquipment(_otherEquipmentController.text.trim());

    // V3: Analytics
    final analyticsParams = {
      'location': provider.data.equipmentLocation ?? 'nenhum',
      'home_equipment': provider.data.homeEquipment.join(','),
      'other_equipment': _otherEquipmentController.text.trim(),
    };
    context.read<AnalyticsService>().trackEvent(
          'onboarding_equipment_set',
          parameters: analyticsParams,
        );

    // V3: Navegação
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const FocusAreaScreen(), // Navega para 1.10
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final provider = context.watch<OnboardingProvider>();

    // V3: Lógica V1 mantida
    final String? selectedLocation = provider.data.equipmentLocation;
    final bool canContinue = selectedLocation != null;
    final bool showSubSelection = selectedLocation == 'casa_com';

    return Scaffold(
      appBar: AppBar(
        // V3: Título do AppBar (Usa o Tema V3)
        title: Text(
          "Etapa 6 de 13",
          style: theme.appBarTheme.titleTextStyle,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 6 / 13,
            backgroundColor: theme.colorScheme.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // 4. Título (V3)
                  Text(
                    "Onde você prefere treinar?",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // 5. Parte 1: Seleção Primária (V3 UI)
                  ..._locationOptions.entries.map((entry) {
                    return _buildLocationCard(
                      key: entry.key,
                      text: entry.value,
                      isSelected: selectedLocation == entry.key,
                      onTap: () {
                        HapticService.lightImpact();
                        provider.setEquipmentLocation(entry.key);
                      },
                    );
                  }),

                  // 6. Parte 2: Sub-Seleção (Lógica V1, UI V3)
                  AnimatedOpacity(
                    opacity: showSubSelection ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Visibility(
                      visible: showSubSelection,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            "Quais equipamentos você tem?",
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Checkboxes (V3 UI)
                          ..._homeEquipmentOptions.entries.map((entry) {
                            return _buildCheckbox(
                              key: entry.key,
                              title: entry.value,
                              provider: provider,
                            );
                          }),

                          const SizedBox(height: 16),

                          // TextField "Outros" (V3 UI)
                          TextField(
                            controller: _otherEquipmentController,
                            decoration: const InputDecoration(
                              labelText: 'Outros (opcional)',
                            ),
                            style: textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 96), // Espaço para o botão
                ],
              ),
            ),
          ),
        ],
      ),
      // 7. Botão de Ação (Inferior Fixo - V3 UI)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          // V3: Estilo V3 (Branco Padrão)
          onPressed: canContinue ? _onNext : null,
          child: const Text('Continuar'),
        ),
      ),
    );
  }

  /// Helper V3: Constrói os cards de seleção de local
  Widget _buildLocationCard({
    required String key,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    // V3: Estilo V3 (Baseado no `schedule_screen`)
    final Color bgColor =
        isSelected ? const Color(0xFF303030) : theme.cardTheme.color!;

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

  /// Helper V3: Constrói os checkboxes da sub-seleção
  Widget _buildCheckbox({
    required String key,
    required String title,
    required OnboardingProvider provider,
  }) {
    final theme = Theme.of(context);
    final bool isSelected = provider.data.homeEquipment.contains(key);

    return CheckboxListTile(
      title: Text(title, style: theme.textTheme.bodyLarge),
      value: isSelected,
      onChanged: (bool? value) {
        HapticService.lightImpact();
        provider.toggleHomeEquipment(key);
      },
      // V3: Tema
      activeColor: theme.colorScheme.primary,
      checkColor: theme.colorScheme.onPrimary,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      tileColor: Colors.transparent,
    );
  }
}
