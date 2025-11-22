import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'focus_area_screen.dart'; // Próxima tela (1.10)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// V3 (NOVOS IMPORTS): Widgets reutilizáveis
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart'; // Para a seleção principal

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
  final FocusNode _otherFocusNode = FocusNode(); // Para controle do teclado

  // V3: Mapa de Lógica de Opções Primárias
  final Map<String, String> _locationOptions = {
    'academia': 'Academia',
    'casa_sem': 'Em casa sem equipamentos',
    'casa_com': 'Em casa com poucos equipamentos',
  };

  // V3: Mapa de Lógica de Sub-Opções (Equipamentos)
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
    _otherFocusNode.dispose();
    super.dispose();
  }

  /// V3: Ação de 'Próximo'
  void _onNext() {
    final provider = context.read<OnboardingProvider>();

    // V3: Haptics
    HapticService.mediumImpact();

    // CORREÇÃO DO BUG: Usa FocusScope.of(context).unfocus() para remover o foco
    // de qualquer campo de forma segura, em vez de depender de _otherFocusNode.unfocus()
    // que falha se o widget não estiver na árvore.
    FocusScope.of(context).unfocus();

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
    // Ouve as mudanças do provider para reconstruir o botão "Continuar"
    final provider = context.watch<OnboardingProvider>();

    // V3: Lógica V1 mantida
    final String? selectedLocation = provider.data.equipmentLocation;
    // canContinue é true se o local de treino foi selecionado
    final bool canContinue = selectedLocation != null;
    final bool showSubSelection = selectedLocation == 'casa_com';

    return Scaffold(
      // 1. AppBar removido
      appBar: null,

      // 2. Botão de Ação (Inferior Fixo - V3 UI)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          // canContinue é avaliado pelo watch acima
          onPressed: canContinue ? _onNext : null,
          child: const Text('Continuar'),
        ),
      ),

      // 3. Body para a barra de navegação customizada e conteúdo
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 6/13)
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
                    // Progress bar real (6/13)
                    child: PremiumProgressBar(progress: 6 / 17),
                  ),
                ],
              ),
            ),

            // CONTEÚDO ROLÁVEL
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
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // 5. Parte 1: Seleção Primária (V3 UI - Usando PremiumSelectionCard)
                    ..._locationOptions.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: PremiumSelectionCard(
                          text: entry.value,
                          isSelected: selectedLocation == entry.key,
                          onTap: () {
                            HapticService.lightImpact();
                            provider.setEquipmentLocation(entry.key);
                            // Limpa o foco com a mudança de modo
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      );
                    }),

                    // 6. Parte 2: Sub-Seleção (Lógica V1, UI V3 - Cards Dourados)
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

                            // Cards de Seleção Múltipla para Equipamentos
                            ..._homeEquipmentOptions.entries.map((entry) {
                              return _buildEquipmentCard(
                                key: entry.key,
                                text: entry.value,
                                provider: provider,
                              );
                            }),

                            const SizedBox(height: 24),

                            // TextField "Outros" (V3 UI)
                            TextField(
                              controller: _otherEquipmentController,
                              focusNode: _otherFocusNode, // Usando o FocusNode
                              decoration: const InputDecoration(
                                labelText: 'Outros (opcional)',
                              ),
                              style: textTheme.bodyLarge,
                              // CORREÇÃO DO BUG: Muda a ação do teclado para DONE (OK/Concluir)
                              textInputAction: TextInputAction.done,
                              // Ação para fechar o teclado ao pressionar DONE
                              onSubmitted: (_) {
                                // Não precisamos mais chamar _otherFocusNode.unfocus() aqui,
                                // pois o TextInputAction.done já faz isso, e o FocusScope.of(context).unfocus()
                                // também é chamado no _onNext.
                              },
                              onChanged: (_) {
                                // Manter apenas para salvar o valor no controller
                              },
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

  /// NOVO WIDGET: Card de Seleção Múltipla para Equipamentos (Sem Checkbox aparente)
  Widget _buildEquipmentCard({
    required String key,
    required String text,
    required OnboardingProvider provider,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isSelected = provider.data.homeEquipment.contains(key);

    // Design idêntico ao _DaySelectionCard da ScheduleScreen
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          HapticService.lightImpact();
          provider.toggleHomeEquipment(key);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            // Fundo Dourado sutil ou Fundo do Card
            color: isSelected
                ? colorScheme.primary.withOpacity(0.1)
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              // Borda Dourada ou Borda Inativa
              color: isSelected
                  ? colorScheme.primary
                  : theme.colorScheme.surfaceContainer,
              width: isSelected ? 2.0 : 1.0,
            ),
            // Sombra Premium
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.15),
                      blurRadius: 12.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              // Texto Dourado ou Texto Padrão
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
