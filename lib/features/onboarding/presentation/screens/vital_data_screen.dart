import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import 'objective_screen.dart';

class VitalDataScreen extends StatefulWidget {
  const VitalDataScreen({super.key});

  @override
  State<VitalDataScreen> createState() => _VitalDataScreenState();
}

class _VitalDataScreenState extends State<VitalDataScreen> {
  late AnalyticsService _analytics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analytics = context.read<AnalyticsService>();
      _analytics.trackScreenView('vital_data_screen');
    });
  }

  bool get _isFormComplete {
    final data = context.read<OnboardingProvider>().data;
    return data.gender != null &&
        data.age != null &&
        data.height != null &&
        data.currentWeight != null;
  }

  // ---
  // LÓGICA DO MODAL (INALTERADA)
  // ---

  Future<void> _showPickerModal(
    BuildContext context, {
    required String title,
    required Widget Function(ValueNotifier<bool>) pickerBuilder,
    required bool isInitiallyEnabled,
  }) async {
    await HapticService.lightImpact();
    final theme = Theme.of(context);

    final ValueNotifier<bool> isButtonEnabled =
        ValueNotifier<bool>(isInitiallyEnabled);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: theme.textTheme.headlineSmall),
                    ValueListenableBuilder<bool>(
                      valueListenable: isButtonEnabled,
                      builder: (context, enabled, child) {
                        return GestureDetector(
                          onTap: enabled
                              ? () {
                                  HapticService.lightImpact();
                                  Navigator.of(context).pop();
                                }
                              : null,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: enabled
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.3),
                              fontWeight: FontWeight.w600,
                            ),
                            child: const Text("Selecionar"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: pickerBuilder(isButtonEnabled),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---
  // PICKERS (OMITIDOS PARA BREVIDADE, MAS ESTÃO NO ARQUIVO)
  // ---

  Widget _buildGenderPicker(
      OnboardingProvider provider, ValueNotifier<bool> notifier) {
    final genders = {
      'male': 'Masculino',
      'female': 'Feminino',
      'other': 'Outro'
    };
    final genderKeys = genders.keys.toList();
    final initialIndex = provider.data.gender == null
        ? 0
        : genderKeys
            .indexOf(provider.data.gender!)
            .clamp(0, genders.length - 1);

    return CupertinoPicker(
      itemExtent: 40.0,
      scrollController: FixedExtentScrollController(initialItem: initialIndex),
      onSelectedItemChanged: (index) {
        HapticService.lightImpact();
        provider.setGender(genderKeys[index]);
        notifier.value = true;
      },
      children: genders.values.map((g) => Center(child: Text(g))).toList(),
    );
  }

  Widget _buildAgePicker(
      OnboardingProvider provider, ValueNotifier<bool> notifier) {
    final ages = List.generate(83, (i) => i + 18);
    final initialIndex = provider.data.age == null
        ? 12
        : ages.indexOf(provider.data.age!).clamp(0, ages.length - 1);

    return CupertinoPicker(
      itemExtent: 40.0,
      scrollController: FixedExtentScrollController(initialItem: initialIndex),
      onSelectedItemChanged: (index) {
        HapticService.lightImpact();
        provider.setAge(ages[index]);
        notifier.value = true;
      },
      children: ages.map((a) => Center(child: Text(a.toString()))).toList(),
    );
  }

  Widget _buildHeightPicker(
      OnboardingProvider provider, ValueNotifier<bool> notifier) {
    final heights = List.generate(81, (i) => i + 140);
    final initialIndex = provider.data.height == null
        ? 30
        : heights.indexOf(provider.data.height!).clamp(0, heights.length - 1);

    return CupertinoPicker(
      itemExtent: 40.0,
      scrollController: FixedExtentScrollController(initialItem: initialIndex),
      onSelectedItemChanged: (index) {
        HapticService.lightImpact();
        provider.setHeight(heights[index]);
        notifier.value = true;
      },
      children: heights.map((h) => Center(child: Text("$h cm"))).toList(),
    );
  }

  Widget _buildWeightPicker(
      OnboardingProvider provider, ValueNotifier<bool> notifier) {
    final weights = List.generate(221, (i) => 40.0 + (i * 0.5));
    final selectedWeight = provider.data.currentWeight;
    final initialIndex = selectedWeight == null
        ? 60
        : weights
            .indexWhere((w) => (w - selectedWeight).abs() < 0.1)
            .clamp(0, weights.length - 1);

    return CupertinoPicker(
      itemExtent: 40.0,
      scrollController: FixedExtentScrollController(initialItem: initialIndex),
      onSelectedItemChanged: (index) {
        HapticService.lightImpact();
        provider.setCurrentWeight(weights[index]);
        notifier.value = true;
      },
      children: weights
          .map((w) => Center(child: Text("${w.toStringAsFixed(1)} kg")))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;
    final bool isFormComplete = _isFormComplete;

    return Scaffold(
      // Removida a AppBar para controle total
      body: SafeArea(
        child: Column(
          children: [
            // 1. BARRA DE PROGRESSO E BOTÃO DE VOLTAR (FIXO NO TOPO)
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
                    child: PremiumProgressBar(progress: 1 / 13),
                  ),
                ],
              ),
            ),

            // 2. CONTEÚDO ROLÁVEL (OCUPA TODO O ESPAÇO RESTANTE)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        "Fale um pouco sobre você",
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 32),

                      // Linhas de dados
                      _VitalDataRow(
                        label: "Gênero",
                        value: data.gender == null
                            ? "Selecione"
                            : ({
                                  'male': 'Masculino',
                                  'female': 'Feminino',
                                  'other': 'Outro'
                                }[data.gender] ??
                                "Selecione"),
                        onTap: () => _showPickerModal(
                          context,
                          title: "Gênero",
                          isInitiallyEnabled: data.gender != null,
                          pickerBuilder: (notifier) =>
                              _buildGenderPicker(provider, notifier),
                        ),
                      ),
                      _VitalDataRow(
                        label: "Idade",
                        value:
                            data.age == null ? "Selecione" : "${data.age} anos",
                        onTap: () => _showPickerModal(
                          context,
                          title: "Idade",
                          isInitiallyEnabled: data.age != null,
                          pickerBuilder: (notifier) =>
                              _buildAgePicker(provider, notifier),
                        ),
                      ),
                      _VitalDataRow(
                        label: "Altura",
                        value: data.height == null
                            ? "Selecione"
                            : "${data.height} cm",
                        onTap: () => _showPickerModal(
                          context,
                          title: "Altura",
                          isInitiallyEnabled: data.height != null,
                          pickerBuilder: (notifier) =>
                              _buildHeightPicker(provider, notifier),
                        ),
                      ),
                      _VitalDataRow(
                        label: "Peso",
                        value: data.currentWeight == null
                            ? "Selecione"
                            : "${data.currentWeight?.toStringAsFixed(1)} kg",
                        onTap: () => _showPickerModal(
                          context,
                          title: "Peso",
                          isInitiallyEnabled: data.currentWeight != null,
                          pickerBuilder: (notifier) =>
                              _buildWeightPicker(provider, notifier),
                        ),
                      ),

                      // AJUSTE CRÍTICO: ADICIONAMOS UM ESPAÇAMENTO MÍNIMO
                      // PARA FORÇAR O SCROLLVIEW A EMPURRAR O CONTEÚDO PARA CIMA
                      // QUANDO O CONTEÚDO É MENOR QUE A TELA.
                      // O MediaQuery.of(context).size.height * 0.4 é um chute seguro
                      // para deixar o botão no rodapé.
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4),
                    ],
                  ),
                ),
              ),
            ),

            // 3. BOTÃO FIXO NO RODAPÉ (FORA DO SCROLLVIEW)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isFormComplete
                      ? () {
                          HapticService.mediumImpact();
                          _analytics.trackEvent(
                            'onboarding_vitals_complete',
                            parameters: {
                              'gender': data.gender,
                              'age': data.age,
                              'height': data.height,
                              'weight': data.currentWeight,
                            },
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ObjectiveScreen(),
                            ),
                          );
                        }
                      : null,
                  child: const Text("Continuar"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Helper para as linhas de dados (Omitido, inalterado)
class _VitalDataRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _VitalDataRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.textTheme.bodyMedium?.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.surfaceContainer,
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodyLarge),
              Row(
                children: [
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    FontAwesomeIcons.chevronRight,
                    size: 14,
                    color: secondaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
