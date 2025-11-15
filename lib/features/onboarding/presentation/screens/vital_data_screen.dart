import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: O caminho correto (Substitui 'services.dart' V1)
import '../../application/onboarding_provider.dart';
// (Remove 'app_theme.dart' V1)
import 'objective_screen.dart';

/// Tela 1.3: Dados Vitais (V3 - FINAL CORRIGIDO)
/// Refatorada para usar o Data Model V3 (currentWeight) e Haptics V3.
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

  // ---
  // V3: CORREÇÃO (O Bug que você achou)
  // (Substitui 'data.weight' V1 por 'data.currentWeight' V3)
  // ---
  bool get _isFormComplete {
    final data = context.read<OnboardingProvider>().data;
    return data.gender != null &&
        data.age != null &&
        data.height != null &&
        data.currentWeight != null; // <-- V3: CORRIGIDO
  }

  Future<void> _showPickerModal(
    BuildContext context, {
    required String title,
    required Widget picker,
  }) async {
    // V3: Haptics
    await HapticService.lightImpact(); // <-- V3: CORRIGIDO
    final theme = Theme.of(context);

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
                    GestureDetector(
                      onTap: () {
                        // V3: Haptics
                        HapticService.lightImpact(); // <-- V3: CORRIGIDO
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Terminado",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: picker),
            ],
          ),
        );
      },
    );
  }

  // ---
  // V3: Pickers (Refatorados para Haptics V3 e 'currentWeight' V3)
  // ---

  Widget _buildGenderPicker(BuildContext context, OnboardingProvider provider) {
    // V3: Lógica V1 mantida, mas usa chaves V3
    final genders = {
      'male': 'Masculino',
      'female': 'Feminino',
      'other': 'Outro'
    };
    final genderKeys = genders.keys.toList();

    final selectedIndex = provider.data.gender == null
        ? 0
        : genderKeys
            .indexOf(provider.data.gender!)
            .clamp(0, genders.length - 1);

    return CupertinoPicker(
      itemExtent: 40.0,
      scrollController: FixedExtentScrollController(initialItem: selectedIndex),
      onSelectedItemChanged: (index) {
        // V3: Haptics
        HapticService.lightImpact(); // <-- V3: CORRIGIDO
        provider.setGender(genderKeys[index]);
      },
      children: genders.values.map((g) => Center(child: Text(g))).toList(),
    );
  }

  Widget _buildAgePicker(BuildContext context, OnboardingProvider provider) {
    final ages = List.generate(83, (i) => i + 18); // 18-100
    final selectedIndex = provider.data.age == null
        ? 12 // 30 anos
        : ages.indexOf(provider.data.age!).clamp(0, ages.length - 1);

    return CupertinoPicker(
      itemExtent: 40.0,
      scrollController: FixedExtentScrollController(initialItem: selectedIndex),
      onSelectedItemChanged: (index) {
        // V3: Haptics
        HapticService.lightImpact(); // <-- V3: CORRIGIDO
        provider.setAge(ages[index]);
      },
      children: ages.map((a) => Center(child: Text(a.toString()))).toList(),
    );
  }

  Widget _buildHeightPicker(BuildContext context, OnboardingProvider provider) {
    final heights = List.generate(81, (i) => i + 140); // 140-220
    final selectedIndex = provider.data.height == null
        ? 30 // 170 cm
        : heights.indexOf(provider.data.height!).clamp(0, heights.length - 1);

    return CupertinoPicker(
      itemExtent: 40.0,
      scrollController: FixedExtentScrollController(initialItem: selectedIndex),
      onSelectedItemChanged: (index) {
        // V3: Haptics
        HapticService.lightImpact(); // <-- V3: CORRIGIDO
        provider.setHeight(heights[index]);
      },
      children: heights.map((h) => Center(child: Text("$h cm"))).toList(),
    );
  }

  Widget _buildWeightPicker(BuildContext context, OnboardingProvider provider) {
    final weights = List.generate(221, (i) => 40.0 + (i * 0.5));
    // V3: CORREÇÃO (O Bug que você achou)
    final selectedWeight = provider.data.currentWeight; // <-- V3: CORRIGIDO

    final selectedIndex = selectedWeight == null
        ? 60 // 70.0 kg
        : weights
            .indexWhere((w) => (w - selectedWeight).abs() < 0.1)
            .clamp(0, weights.length - 1);

    return CupertinoPicker(
      itemExtent: 40.0,
      scrollController: FixedExtentScrollController(initialItem: selectedIndex),
      onSelectedItemChanged: (index) {
        // V3: Haptics
        HapticService.lightImpact(); // <-- V3: CORRIGIDO
        // V3: CORREÇÃO (Chama o setter V3)
        provider.setCurrentWeight(weights[index]); // <-- V3: CORRIGIDO
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

    // V3: CORREÇÃO (Usa o getter V3)
    final bool isFormComplete = _isFormComplete;

    return Scaffold(
      appBar: AppBar(
        // V3: TEMA (Usa o Tema V3)
        title: Text("Etapa 1 de 13", style: theme.appBarTheme.titleTextStyle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 1 / 13,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surfaceContainer,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fale um pouco sobre você",
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            _VitalDataRow(
              label: "Gênero",
              // V3: TEMA (Usa o formatter V3 que criamos na summary_screen)
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
                picker: _buildGenderPicker(context, provider),
              ),
            ),
            _VitalDataRow(
              label: "Idade",
              value: data.age == null ? "Selecione" : "${data.age} anos",
              onTap: () => _showPickerModal(
                context,
                title: "Idade",
                picker: _buildAgePicker(context, provider),
              ),
            ),
            _VitalDataRow(
              label: "Altura",
              value: data.height == null ? "Selecione" : "${data.height} cm",
              onTap: () => _showPickerModal(
                context,
                title: "Altura",
                picker: _buildHeightPicker(context, provider),
              ),
            ),
            _VitalDataRow(
              label: "Peso",
              // V3: CORREÇÃO (O Bug que você achou)
              value: data.currentWeight == null
                  ? "Selecione"
                  : "${data.currentWeight?.toStringAsFixed(1)} kg",
              onTap: () => _showPickerModal(
                context,
                title: "Peso",
                picker: _buildWeightPicker(context, provider),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormComplete
                    ? () {
                        // V3: Haptics
                        HapticService.mediumImpact(); // <-- V3: CORRIGIDO
                        _analytics.trackEvent(
                          'onboarding_vitals_complete',
                          parameters: {
                            'gender': data.gender,
                            'age': data.age,
                            'height': data.height,
                            'weight': data.currentWeight, // <-- V3: CORRIGIDO
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
          ],
        ),
      ),
    );
  }
}

/// V3: Widget de Row (Refatorado para Tema V3)
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
                    // V3: TEMA (Substitui AppTheme.secondaryText V1)
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          theme.textTheme.bodyMedium?.color, // V3: Cinza (Tema)
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    FontAwesomeIcons.chevronRight,
                    size: 14,
                    // V3: TEMA (Substitui AppTheme.secondaryText V1)
                    color:
                        theme.textTheme.bodyMedium?.color, // V3: Cinza (Tema)
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
