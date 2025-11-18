import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cardio_screen.dart'; // Próxima tela (1.12)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// V3 (PONTO 7): Importando o novo card premium
import '../widgets/premium_selection_card.dart';

/// Tela 1.11: Onde o usuário informa sobre lesões (Lógica V3).
/// Refatorada para SPRINT 2 (Layout de Scroll) e SPRINT 3 (Premium Card)
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('injuries');
    });
  }

  @override
  void dispose() {
    _injuryController.dispose();
    _injuryFocusNode.dispose(); // V3: Limpa o foco
    super.dispose();
  }

  // --- AÇÕES V3 ---

  void _onNext() {
    if (_hasInjury == null) return;
    HapticService.mediumImpact();

    // V3 (PONTO 8a): Se o teclado estiver aberto, feche-o
    if (_injuryFocusNode.hasFocus) {
      _injuryFocusNode.unfocus();
    }

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

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const CardioScreen(), // Navega para 1.12
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final bool canContinue = _hasInjury != null;
    final bool showSubSelection = _hasInjury == true;

    return Scaffold(
      appBar: AppBar(
        // V3 (PONTO 2): Texto "Etapa" removido
        // V3 (PONTO 3): Barra de progresso será um novo widget (Tarefa 2.5)
        title: null, // Removido
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            // Placeholder até Tarefa 2.5
            value: 8 / 13,
            backgroundColor: theme.colorScheme.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ),
      body:
          // V3 (PONTO 8b & 15): Adiciona SingleChildScrollView para
          // corrigir o overflow do teclado e o bug de zoom.
          SingleChildScrollView(
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

            // V3 (PONTO 7): Substituído pelo PremiumSelectionCard
            PremiumSelectionCard(
              text: 'Sim',
              isSelected: _hasInjury == true,
              onTap: () {
                HapticService.lightImpact();
                setState(() {
                  _hasInjury = true;
                });
              },
            ),
            const SizedBox(height: 16),
            PremiumSelectionCard(
              text: 'Não',
              isSelected: _hasInjury == false,
              onTap: () {
                HapticService.lightImpact();
                setState(() {
                  _hasInjury = false;
                });
                _injuryFocusNode
                    .unfocus(); // Fecha o teclado se "Não" for selecionado
              },
            ),

            // V3: Sub-Seleção (Textfield)
            AnimatedOpacity(
              opacity: showSubSelection ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              // V3: Otimização para só construir o TextField se for visível
              child: Visibility(
                visible: showSubSelection,
                maintainState: true, // Mantém o estado do controller
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      "Por favor, descreva sua(s) lesão(ões)",
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Quanto mais detalhes (o que, quando, limitações), melhor a IA poderá adaptar seu treino.",
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // V3 (PONTO 8a & 13): Corrigido
                    TextField(
                      controller: _injuryController,
                      focusNode: _injuryFocusNode, // V3: Controla o foco
                      decoration: const InputDecoration(
                        labelText: 'Descreva sua lesão aqui...',
                      ),
                      style: textTheme.bodyLarge,
                      maxLines: 5,
                      // V3 (PONTO 8a): Permite nova linha
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40), // Espaço antes do botão

            // V3 (PONTO 8b): Botão movido para dentro do Scroll
            ElevatedButton(
              onPressed: canContinue ? _onNext : null,
              child: const Text('Continuar'),
            ),
            const SizedBox(height: 40), // Espaço para fim do scroll
          ],
        ),
      ),
      // V3 (PONTO 8b): bottomNavigationBar removido
    );
  }
}
