import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// REFACTOR: Agora aponta para a tela de Condições de Saúde (9/17)
import 'health_conditions_screen.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_selection_card.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/procs_back_button.dart';

/// Tela 1.11: Onde o usuário informa sobre lesões (Lógica V3).
/// REFACTOR: Navegação atualizada para HealthConditionsScreen.
class InjuriesScreen extends StatefulWidget {
  const InjuriesScreen({super.key});

  @override
  State<InjuriesScreen> createState() => _InjuriesScreenState();
}

class _InjuriesScreenState extends State<InjuriesScreen> {
  // --- ESTADO LOCAL (V3) ---
  bool? _hasInjury;
  late final TextEditingController _injuryController;

  // V3 (PONTO 8a/13): Foco para o teclado
  final FocusNode _injuryFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final providerData = context.read<OnboardingProvider>().data;
    _hasInjury = providerData.hasInjury;
    _injuryController = TextEditingController(text: providerData.injuryDetails);

    // Adiciona listener para atualizar o botão quando o texto mudar
    _injuryController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('injuries');
    });
  }

  @override
  void dispose() {
    _injuryController.dispose();
    _injuryFocusNode.dispose();
    super.dispose();
  }

  // --- AÇÕES V3 ---

  void _onNext() {
    if (_hasInjury == null) return;
    HapticService.mediumImpact();

    // CORREÇÃO DO BUG: Remove o foco de forma segura
    FocusScope.of(context).unfocus();

    final provider = context.read<OnboardingProvider>();
    provider.setInjuryData(
      hasInjury: _hasInjury!,
      details: _hasInjury == true ? _injuryController.text.trim() : null,
    );

    context.read<AnalyticsService>().trackEvent(
      'onboarding_injury_set',
      parameters: {
        'has_injury': _hasInjury!,
        'details_length':
            _hasInjury == true ? _injuryController.text.trim().length : 0,
      },
    );

    // REFACTOR: Navega para a tela de Condições de Saúde (Passo 9/17)
    // (Anteriormente ia para CardioScreen)
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const HealthConditionsScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Ouve as mudanças do provider
    context.watch<OnboardingProvider>();

    // Validação: Se tiver lesão, precisa ter texto. Se não tiver, pode seguir.
    final bool canContinue = _hasInjury != null &&
        (!_hasInjury! || _injuryController.text.trim().isNotEmpty);
    final bool showSubSelection = _hasInjury == true;

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
                    child: PremiumProgressBar(progress: 8 / 17),
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
                      "Você tem algum histórico de lesão?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // NÍVEL 1: Seleção Principal
                    PremiumSelectionCard(
                      text: 'Não possuo lesões',
                      isSelected: _hasInjury == false,
                      onTap: () {
                        HapticService.lightImpact();
                        setState(() {
                          _hasInjury = false;
                          _injuryController.clear();
                        });
                        FocusScope.of(context).unfocus();
                        _onNext(); // Auto-advance
                      },
                    ),
                    const SizedBox(height: 12),
                    PremiumSelectionCard(
                      text: 'Possuo lesões',
                      isSelected: _hasInjury == true,
                      onTap: () {
                        HapticService.lightImpact();
                        setState(() {
                          _hasInjury = true;
                        });
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _injuryFocusNode.requestFocus();
                        });
                      },
                    ),

                    // NÍVEL 2: Descrição (Condicional)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: showSubSelection
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                Text(
                                  "Por favor, descreva sua(s) lesão(ões)",
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Quanto mais detalhes (o que, quando, limitações), melhor a IA poderá adaptar seu treino.",
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _injuryController,
                                  focusNode: _injuryFocusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Descreva sua lesão aqui...',
                                    hintText:
                                        "Seja específico. Ex: 'Tenho hérnia de disco na lombar' ou 'Operei o menisco do joelho direito há 1 ano'.",
                                    hintMaxLines: 3,
                                  ),
                                  style: textTheme.bodyLarge,
                                  maxLines: 3,
                                  textInputAction: TextInputAction.done,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
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
}
