import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_location_screen.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/procs_back_button.dart';

class SupplementsScreen extends StatefulWidget {
  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen> {
  final Map<String, String> _supplementOptions = {
    'whey': 'Whey Protein',
    'creatina': 'Creatina',
    'pre_treino': 'Pré-treino',
    'multivitaminico': 'Multivitamínico',
    'hipercalorico': 'Hipercalórico',
  };

  late final TextEditingController _otherController;
  final FocusNode _otherFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final initialOther =
        context.read<OnboardingProvider>().data.otherSupplements;
    _otherController = TextEditingController(text: initialOther ?? '');

    // Listener to update UI when text changes (for validation button)
    _otherController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('supplements_selection');
    });
  }

  @override
  void dispose() {
    _otherController.dispose();
    _otherFocusNode.dispose();
    super.dispose();
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    HapticService.heavyImpact();

    final provider = context.read<OnboardingProvider>();
    final data = provider.data;

    // Save text field content if "outros" was selected
    if (data.selectedSupplements.contains('outros')) {
      provider.setOtherSupplements(_otherController.text.trim());
    } else {
      provider.setOtherSupplements(null);
    }

    context.read<AnalyticsService>().trackEvent(
      'onboarding_supplements_set',
      parameters: {
        'selected': data.selectedSupplements.toList().join(','),
        'other': _otherController.text,
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserLocationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;

    final bool showOtherTextField = data.selectedSupplements.contains('outros');

    // Validation: Must have at least one selection OR text is not empty if "outros" is selected.
    // If 'none' is selected, it's valid.
    // If list is not empty (and not just 'outros'), it's valid.
    // If 'outros' is selected, text must be > 0.
    final bool hasSelection = data.selectedSupplements.isNotEmpty;
    final bool isOtherValid =
        !showOtherTextField || _otherController.text.trim().isNotEmpty;
    final bool canContinue = hasSelection && isOtherValid;

    return Scaffold(
      appBar: null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed: canContinue ? _onNext : null,
          child: const Text('Continuar'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar (14/15)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: PremiumProgressBar(progress: 15 / 16),
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
                      "Você já faz uso de algum suplemento?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Selecione o que você já utiliza atualmente.",
                      style: textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Option: None
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PremiumSelectionCard(
                        text: "Não utilizo suplementação",
                        isSelected: data.selectedSupplements.contains('none'),
                        onTap: () {
                          HapticService.lightImpact();
                          provider.toggleSupplement('none');
                          _otherController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),

                    // Options List
                    ..._supplementOptions.entries.map((entry) {
                      final isSelected =
                          data.selectedSupplements.contains(entry.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PremiumSelectionCard(
                          text: entry.value,
                          isSelected: isSelected,
                          onTap: () {
                            HapticService.lightImpact();
                            provider.toggleSupplement(entry.key);
                          },
                        ),
                      );
                    }),

                    // Option: Others
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          PremiumSelectionCard(
                            text: "Outros",
                            isSelected: showOtherTextField,
                            onTap: () {
                              HapticService.lightImpact();
                              provider.toggleSupplement('outros');
                              if (!showOtherTextField) {
                                // Give time for UI expand then focus
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  _otherFocusNode.requestFocus();
                                });
                              }
                            },
                          ),

                          // Expanded Text Field
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding:
                                  const EdgeInsets.only(top: 12, bottom: 24),
                              child: TextField(
                                controller: _otherController,
                                focusNode: _otherFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Quais? (separados por vírgula)',
                                  hintText: "Ex: Cafeína, Beta-Alanina, ZMA...",
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.3)),
                                ),
                                style: textTheme.bodyLarge,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) =>
                                    FocusScope.of(context).unfocus(),
                              ),
                            ),
                            crossFadeState: showOtherTextField
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 64),
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
