import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'focus_area_screen.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart'; // O Card Oficial
import '../widgets/procs_back_button.dart';

/// Tela 1.9: Onde você prefere treinar.
/// REFACTOR FINAL: Limpeza de widget duplicado para usar o PremiumSelectionCard.
class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  late final TextEditingController _otherEquipmentController;
  final FocusNode _otherFocusNode = FocusNode();

  final Map<String, String> _locationOptions = {
    'academia': 'Academia',
    'casa_sem': 'Em casa sem equipamentos',
    'casa_com': 'Em casa com poucos equipamentos',
  };

  final Map<String, String> _homeEquipmentOptions = {
    'halteres': 'Halteres',
    'elasticos': 'Elásticos',
    'barra': 'Barra (puxar) ou Halter (levantar)',
    'caneleiras': 'Caneleiras',
  };

  @override
  void initState() {
    super.initState();
    final initialOther = context.read<OnboardingProvider>().data.otherEquipment;
    _otherEquipmentController = TextEditingController(text: initialOther);

    _otherEquipmentController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('equipment');
    });
  }

  @override
  void dispose() {
    _otherEquipmentController.dispose();
    _otherFocusNode.dispose();
    super.dispose();
  }

  void _onNext() {
    final provider = context.read<OnboardingProvider>();
    HapticService.mediumImpact();
    FocusScope.of(context).unfocus();

    provider.setOtherEquipment(_otherEquipmentController.text.trim());

    final analyticsParams = {
      'location': provider.data.equipmentLocation ?? 'nenhum',
      'home_equipment': provider.data.homeEquipment.join(','),
      'other_equipment': _otherEquipmentController.text.trim(),
    };
    context.read<AnalyticsService>().trackEvent(
          'onboarding_equipment_set',
          parameters: analyticsParams,
        );

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const FocusAreaScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();

    final String? selectedLocation = provider.data.equipmentLocation;
    final bool showSubSelection = selectedLocation == 'casa_com';

    // Validação:
    // 1. Deve ter uma localização selecionada.
    // 2. Se for "casa_com", deve ter pelo menos um equipamento OU texto em "Outros".
    final bool canContinue = selectedLocation != null &&
        (!showSubSelection ||
            provider.data.homeEquipment.isNotEmpty ||
            _otherEquipmentController.text.trim().isNotEmpty);

    return Scaffold(
      appBar: null,
      bottomNavigationBar: showSubSelection
          ? Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: canContinue ? _onNext : null,
                child: const Text('Continuar'),
              ),
            )
          : null,
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
                    child: PremiumProgressBar(progress: 6 / 17),
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
                      "Onde você prefere treinar?",
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ..._locationOptions.entries.map((entry) {
                      final isSelected = selectedLocation == entry.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: PremiumSelectionCard(
                          text: entry.value,
                          isSelected: isSelected,
                          onTap: () {
                            HapticService.lightImpact();
                            if (isSelected) {
                              // Toggle: Desmarca se já estiver selecionado
                              provider.setEquipmentLocation(null);
                            } else {
                              provider.setEquipmentLocation(entry.key);
                              // Auto-advance se não for "casa_com"
                              if (entry.key != 'casa_com') {
                                _onNext();
                              }
                            }
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      );
                    }),
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
                            ..._homeEquipmentOptions.entries.map((entry) {
                              // AQUI: Usando PremiumSelectionCard para a sub-seleção
                              final isSelected = provider.data.homeEquipment
                                  .contains(entry.key);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: PremiumSelectionCard(
                                  text: entry.value,
                                  isSelected: isSelected,
                                  onTap: () {
                                    HapticService.lightImpact();
                                    provider.toggleHomeEquipment(entry.key);
                                  },
                                ),
                              );
                            }),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _otherEquipmentController,
                              focusNode: _otherFocusNode,
                              decoration: const InputDecoration(
                                labelText: 'Outros (opcional)',
                              ),
                              style: textTheme.bodyLarge,
                              textInputAction: TextInputAction.done,
                            ),
                          ],
                        ),
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
  // Widget interno _buildEquipmentCard removido.
}
