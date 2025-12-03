import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import 'objective_screen.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/procs_back_button.dart';

class VitalDataScreen extends StatefulWidget {
  const VitalDataScreen({super.key});

  @override
  State<VitalDataScreen> createState() => _VitalDataScreenState();
}

class _VitalDataScreenState extends State<VitalDataScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('vital_data_list');
    });
  }

  void _navigateToNext() {
    HapticService.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ObjectiveScreen()),
    );
  }

  // --- MODALS ---

  void _showGenderPicker() {
    HapticService.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _GenderPickerModal(),
    );
  }

  void _showValuePicker({
    required String title,
    required int min,
    required int max,
    required int initialValue,
    required String suffix,
    required Function(int) onSave,
  }) {
    HapticService.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ValuePickerModal(
        title: title,
        min: min,
        max: max,
        initialValue: initialValue,
        suffix: suffix,
        onSave: onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: PremiumProgressBar(progress: 0.1), // 1/5 aprox
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Fale um pouco sobre você",
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            // LIST
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _VitalDataItem(
                    label: "Gênero",
                    value: data.gender ?? "Selecione",
                    onTap: _showGenderPicker,
                  ),
                  const Divider(height: 1),
                  _VitalDataItem(
                    label: "Idade",
                    value: "${data.age ?? 25} anos",
                    onTap: () => _showValuePicker(
                      title: "Qual sua idade?",
                      min: 12,
                      max: 100,
                      initialValue: data.age ?? 25,
                      suffix: "",
                      onSave: provider.setAge,
                    ),
                  ),
                  const Divider(height: 1),
                  _VitalDataItem(
                    label: "Altura",
                    value: "${data.height ?? 170} cm",
                    onTap: () => _showValuePicker(
                      title: "Qual sua altura?",
                      min: 100,
                      max: 250,
                      initialValue: data.height ?? 170,
                      suffix: " cm",
                      onSave: provider.setHeight,
                    ),
                  ),
                  const Divider(height: 1),
                  _VitalDataItem(
                    label: "Peso",
                    value: "${data.currentWeight?.round() ?? 70} kg",
                    onTap: () => _showValuePicker(
                      title: "Qual seu peso?",
                      min: 30,
                      max: 200,
                      initialValue: data.currentWeight?.round() ?? 70,
                      suffix: " kg",
                      onSave: (val) =>
                          provider.setCurrentWeight(val.toDouble()),
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),

            // FOOTER BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _navigateToNext,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Continuar",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _VitalDataItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _VitalDataItem({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderPickerModal extends StatelessWidget {
  const _GenderPickerModal();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<OnboardingProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Selecione seu gênero",
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          PremiumSelectionCard(
            text: "Masculino",
            isSelected: provider.data.gender == "Masculino",
            icon: FontAwesomeIcons.mars,
            onTap: () {
              provider.setGender("Masculino");
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
          PremiumSelectionCard(
            text: "Feminino",
            isSelected: provider.data.gender == "Feminino",
            icon: FontAwesomeIcons.venus,
            onTap: () {
              provider.setGender("Feminino");
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ValuePickerModal extends StatefulWidget {
  final String title;
  final int min;
  final int max;
  final int initialValue;
  final String suffix;
  final Function(int) onSave;

  const _ValuePickerModal({
    required this.title,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.suffix,
    required this.onSave,
  });

  @override
  State<_ValuePickerModal> createState() => _ValuePickerModalState();
}

class _ValuePickerModalState extends State<_ValuePickerModal> {
  late FixedExtentScrollController _controller;
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _controller = FixedExtentScrollController(
      initialItem: widget.initialValue - widget.min,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: CupertinoPicker.builder(
              scrollController: _controller,
              itemExtent: 50,
              onSelectedItemChanged: (index) {
                HapticService.selectionClick();
                setState(() {
                  _selectedValue = widget.min + index;
                });
              },
              childCount: widget.max - widget.min + 1,
              itemBuilder: (context, index) {
                final value = widget.min + index;
                final isSelected = value == _selectedValue;
                return Center(
                  child: Text(
                    "$value${widget.suffix}",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_selectedValue);
                Navigator.pop(context);
              },
              child: const Text("Confirmar"),
            ),
          ),
        ],
      ),
    );
  }
}
