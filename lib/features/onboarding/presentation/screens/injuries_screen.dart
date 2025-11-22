import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cardio_screen.dart'; // Próxima tela (1.12)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// V3 (PONTO 7): Importando o novo card premium
import '../widgets/premium_selection_card.dart';
// V3 (NOVOS IMPORTS): Widgets reutilizáveis
import '../widgets/premium_progress_bar.dart';

/// Tela 1.11: Onde o usuário informa sobre lesões (Lógica V3).
/// Refatorada para o novo padrão de UX (Barra no topo, Botão no rodapé)
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
    _injuryFocusNode.dispose();
    super.dispose();
  }

  // --- AÇÕES V3 ---

  void _onNext() {
    if (_hasInjury == null) return;
    HapticService.mediumImpact();

    // CORREÇÃO DO BUG: Remove o foco de forma segura, como na tela anterior.
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

    // Próxima tela (Note que esta é a nova etapa 10, devido às 2 novas telas)
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const CardioScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Ouve as mudanças do provider para reavaliar o botão (embora não seja
    // estritamente necessário aqui, é boa prática para o layout).
    context.watch<OnboardingProvider>();

    final bool canContinue = _hasInjury != null;
    final bool showSubSelection = _hasInjury == true;

    return Scaffold(
      // 1. AppBar removido
      appBar: null,

      // 2. Botão de Ação (Inferior Fixo - V3 UI)
      // CORREÇÃO do Bug: Movido para o bottomNavigationBar para NUNCA sumir
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed: canContinue ? _onNext : null,
          child: const Text('Continuar'),
        ),
      ),

      // 3. Body para a barra de navegação customizada e conteúdo
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 8/15)
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
                    // Nova barra de progresso (8/15)
                    child: PremiumProgressBar(progress: 8 / 17),
                  ),
                ],
              ),
            ),

            // CONTEÚDO ROLÁVEL
            Expanded(
              // V3 (PONTO 8b & 15): Adiciona SingleChildScrollView para
              // corrigir o overflow do teclado e o bug de zoom.
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

                    // V3 (PONTO 7): Card para "Sim" (Design Dourado)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PremiumSelectionCard(
                        text: 'Sim',
                        isSelected: _hasInjury == true,
                        onTap: () {
                          HapticService.lightImpact();
                          setState(() {
                            _hasInjury = true;
                          });
                          // Move o foco para o campo de texto
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _injuryFocusNode.requestFocus();
                          });
                        },
                      ),
                    ),

                    // V3 (PONTO 7): Card para "Não" (Design Dourado)
                    PremiumSelectionCard(
                      text: 'Não',
                      isSelected: _hasInjury == false,
                      onTap: () {
                        HapticService.lightImpact();
                        setState(() {
                          _hasInjury = false;
                        });
                        // Fecha o teclado se "Não" for selecionado
                        FocusScope.of(context).unfocus();
                      },
                    ),

                    // V3: Sub-Seleção (Textfield)
                    AnimatedOpacity(
                      opacity: showSubSelection ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
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
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),

                            // V3 (PONTO 8a & 13): Corrigido
                            TextField(
                              controller: _injuryController,
                              focusNode:
                                  _injuryFocusNode, // V3: Controla o foco
                              decoration: const InputDecoration(
                                labelText: 'Descreva sua lesão aqui...',
                              ),
                              style: textTheme.bodyLarge,
                              maxLines: 5,
                              // CORREÇÃO DO BUG: Muda a ação do teclado para DONE (OK/Concluir)
                              // Se o usuário clicar em "Concluir" no teclado,
                              // ele fecha, mas não navega (o botão Continuar fixo faz isso).
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), // Espaço para o botão fixo
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
