import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'meal_routine_screen.dart'; // Próxima tela (1.15)
// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: O caminho correto
import '../../application/onboarding_provider.dart';
// (Remove 'haptics.dart' V1)
// (Remove 'app_theme.dart' V1)

/// Tela 1.14: Início da "Fase 2 - Dieta" (V3).
/// Refatorada para Fundação V3 (Tema, Haptics, Provider) e UI V3 (Cards).
class DietRestrictionsScreen extends StatefulWidget {
  const DietRestrictionsScreen({super.key});

  @override
  State<DietRestrictionsScreen> createState() => _DietRestrictionsScreenState();
}

class _DietRestrictionsScreenState extends State<DietRestrictionsScreen> {
  // V3: Lógica V1 (Chaves) mantida, mas agora como um Map V3
  final Map<String, String> _restrictionOptions = {
    'vegano': 'Vegano',
    'vegetariano': 'Vegetariano',
    'sem_gluten': 'Sem Glúten',
    'sem_lactose': 'Sem Lactose',
  };

  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('diet_restrictions');
    });
  }

  /// V3: Ação de 'Próximo'
  void _onNext() {
    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Analytics (Salva o estado final do Provider)
    // [CORREÇÃO] 1. Removido '?? {}' (dead_null_aware_expression)
    // A variável 'dietRestrictions' no seu model não pode ser nula.
    final restrictions =
        context.read<OnboardingProvider>().data.dietRestrictions;
    context.read<AnalyticsService>().trackEvent(
      'onboarding_diet_restrictions_set',
      parameters: {
        'restrictions': restrictions.join(','),
        'count': restrictions.length,
      },
    );

    // V3: Navegação (Lógica V1 mantida)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MealRoutineScreen(), // Navega para 1.15
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();

    // V3: Lê o Set<String> do Provider V3 (Imutável)
    // [CORREÇÃO] 2. Removido '?? {}' (dead_null_aware_expression)
    // Novamente, 'dietRestrictions' não pode ser nula.
    final selectedRestrictions = provider.data.dietRestrictions;

    // [CORREÇÃO] 4. Variável 'canContinue' removida (unused_local_variable)
    // Ela não era usada pois o botão está sempre ativo.
    // const bool canContinue = true;

    return Scaffold(
      // 1. AppBar V3 (Padrão)
      appBar: const _OnboardingAppBar(progress: 10 / 13),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // 4. Título (V3)
                  Text(
                    "Você tem alguma restrição alimentar?",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // 5. Subtítulo (V3)
                  Text(
                    "Isso nos ajuda a criar a dieta ideal. Pode marcar mais de uma.",
                    // V3: Usa o Tema (Remove AppTheme.secondaryText V1)
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // 6. Seleção Múltipla (UI V3 - Cards)
                  // (Descarta _buildCheckbox V1)
                  ..._restrictionOptions.entries.map((entry) {
                    final key = entry.key;
                    final text = entry.value;
                    final isSelected = selectedRestrictions.contains(key);

                    return _buildSelectionCard(
                      text: text,
                      isSelected: isSelected,
                      onTap: () {
                        // V3: Haptics
                        HapticService.lightImpact();
                        // V3: Atualiza o Provider V3 (Imutável)
                        provider.toggleDietRestriction(key);
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
          // Lógica V1 mantida: Sempre habilitado
          // [CORREÇÃO] 3. Removido 'canContinue ? ... : null' (dead_code)
          // Como 'canContinue' era 'const true', o 'null' nunca seria atingido.
          onPressed: _onNext,
          child: const Text('Continuar'),
        ),
      ),
    );
  }

  /// Helper V3: Constrói os cards de seleção (Padrão V3)
  Widget _buildSelectionCard({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    // V3: Estilo V3 (Padrão de 'schedule_screen')
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

// ---
// V3: Widget de AppBar Consistente
// (Baseado no que foi feito em 'cardio_screen.dart')
// ---
class _OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double progress;

  const _OnboardingAppBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      // V3: Usa o Tema (Remove BackButton(color: AppTheme.primaryText) V1)
      leading: const BackButton(),
      title: Text(
        "Etapa ${(progress * 13).round()} de 13",
        // V3: Usa o Tema (Semântico)
        style: theme.appBarTheme.titleTextStyle,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: LinearProgressIndicator(
          value: progress,
          // V3: Usa o Tema (Remove AppTheme.lightBackground V1)
          backgroundColor: theme.colorScheme.surfaceContainer,
          // V3: Usa o Tema (colorScheme.primary)
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}
