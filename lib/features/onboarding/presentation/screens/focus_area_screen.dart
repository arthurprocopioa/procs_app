import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'injuries_screen.dart'; // Próxima tela (1.11)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
// V3 (NOVOS IMPORTS): Widgets reutilizáveis
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';

/// Tela 1.10: Onde o usuário informa áreas de foco (Opcional).
/// Refatorada para Lógica V3 (desmembrada), UI V3 (Cards Premium)
/// e novo padrão de navegação.
class FocusAreaScreen extends StatefulWidget {
  const FocusAreaScreen({super.key});

  @override
  State<FocusAreaScreen> createState() => _FocusAreaScreenState();
}

class _FocusAreaScreenState extends State<FocusAreaScreen> {
  // V3: Lógica V3 (Baseada na Referência V3, ignora a Lógica V1)
  final Map<String, String> _focusOptions = {
    'full_body': 'Corpo Inteiro', // V3 (Lógica 'Inteligente')
    'shoulders': 'Ombros',
    'arms': 'Braços',
    'back': 'Costas',
    'chest': 'Peito',
    'abs': 'Abdômen', // V3 (Barriga)
    'glutes': 'Glúteos', // V3 (Nádegas)
    'legs': 'Pernas',
  };

  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('focus_area');
    });
  }

  /// V3: Ação de 'Próximo'
  void _onNext() {
    final provider = context.read<OnboardingProvider>();

    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Analytics
    final analyticsParams = {
      'focus_areas': provider.data.focusAreas.join(','),
    };
    context.read<AnalyticsService>().trackEvent(
          'onboarding_focus_area_set',
          parameters: analyticsParams,
        );

    // V3: Navegação
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const InjuriesScreen(), // Navega para 1.11
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final selectedAreas = provider.data.focusAreas;

    return Scaffold(
      // 1. AppBar removido
      appBar: null,

      // 2. Botão de Ação (Inferior Fixo - V3 UI)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          // Lógica V1 mantida: sempre ativo
          onPressed: _onNext,
          child: const Text('Continuar'),
        ),
      ),

      // 3. Body para a barra de navegação customizada e conteúdo
      body: SafeArea(
        child: Column(
          children: [
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 7/13)
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
                    // Progress bar real (7/13)
                    child: PremiumProgressBar(progress: 7 / 17),
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
                    // 4. Título (V3 - Baseado na Referência)
                    Text(
                      "Em quais áreas seu treinamento deve se concentrar?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // 5. Subtítulo (V1)
                    Text(
                      "Isto é opcional. Selecione 'Corpo Inteiro' ou áreas específicas.",
                      style: textTheme.bodyMedium, // V3 (Tema)
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // 6. Seleção Múltipla (UI V3 - Cards Premium)
                    ..._focusOptions.entries.map((entry) {
                      final key = entry.key;
                      final text = entry.value;
                      final isSelected = selectedAreas.contains(key);

                      // --- MUDANÇA CRÍTICA AQUI ---
                      // Substituído o _buildFocusCard por um Card de Seleção Múltipla.
                      // Como o PremiumSelectionCard original é de seleção ÚNICA (radio),
                      // usamos um Card de Seleção Múltipla sem ícone (_DaySelectionCard)
                      // que já fizemos na tela anterior, mas renomeado para maior clareza aqui.
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: _FocusSelectionCard(
                          text: text,
                          isSelected: isSelected,
                          onTap: () {
                            HapticService.lightImpact();
                            provider.toggleFocusArea(key);
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 96), // Espaço para o botão
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

/// NOVO WIDGET: Card de Seleção Múltipla sem Ícone
/// Reutiliza a lógica minimalista de seleção que você aprovou (borda amarela).
class _FocusSelectionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _FocusSelectionCard({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

// ---
// O _buildFocusCard original foi removido por ser visualmente inconsistente.
// ---
