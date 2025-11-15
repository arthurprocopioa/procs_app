import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'injuries_screen.dart'; // Próxima tela (1.11)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';

/// Tela 1.10: Onde o usuário informa áreas de foco (Opcional).
/// Refatorada para Lógica V3 (desmembrada) e UI V3 (Cards).
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

    // Lógica V1 mantida: Esta tela é opcional, o botão está sempre ativo.
    // const bool canContinue = true; // [CORREÇÃO] Variável agora é desnecessária

    return Scaffold(
      appBar: AppBar(
        // V3: Título do AppBar (Usa o Tema V3)
        title: Text(
          "Etapa 7 de 13",
          style: theme.appBarTheme.titleTextStyle,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 7 / 13,
            backgroundColor: theme.colorScheme.surfaceContainer,
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      ),
      body: Column(
        children: [
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

                  // 6. Seleção Múltipla (UI V3 - Cards)
                  // (Descarta 100% o _buildCheckbox V1)
                  ..._focusOptions.entries.map((entry) {
                    final key = entry.key;
                    final text = entry.value;
                    final isSelected = selectedAreas.contains(key);

                    return _buildFocusCard(
                      text: text,
                      isSelected: isSelected,
                      onTap: () {
                        HapticService.lightImpact();
                        provider.toggleFocusArea(key);
                      },
                    );
                  }),

                  const SizedBox(height: 96), // Espaço para o botão
                ],
              ),
            ),
          ),
        ],
      ),
      // 7. Botão de Ação (Inferior Fixo - V3 UI)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          // V3: Estilo V3 (Branco Padrão, sempre ativo)
          // [CORREÇÃO] 1. Removido 'canContinue ? ... : null' (dead_code)
          onPressed: _onNext,
          child: const Text('Continuar'),
        ),
      ),
    );
  }

  /// Helper V3: Constrói os cards de seleção (Padrão V3)
  Widget _buildFocusCard({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    // V3: Estilo V3 (Baseado no `schedule_screen`)
    final Color bgColor =
        isSelected ? const Color(0xFF303030) : theme.cardTheme.color!;

    final Color fgColor =
        isSelected ? Colors.white : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: fgColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
