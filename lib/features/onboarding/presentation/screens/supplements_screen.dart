import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_diet_plan_screen.dart'; // Próxima tela (1.18)
// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: O caminho correto
import '../../application/onboarding_provider.dart';
// (Remove 'haptics.dart' V1)
// (Remove 'app_theme.dart' V1)

/// Tela 1.17: Fim da "Fase 2 - Dieta" (100% completo).
/// Refatorada para Fundação V3 (Tema, Haptics, Provider) e UI V3 (Cards).
class SupplementsScreen extends StatefulWidget {
  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen> {
  // --- AÇÕES V3 ---

  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('supplements');
    });
  }

  void _onNext(BuildContext context, bool interestInSupplements) {
    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Analytics (Salva o estado final do Provider)
    context.read<AnalyticsService>().trackEvent(
      'onboarding_supplements_set',
      parameters: {
        'interest': interestInSupplements,
      },
    );

    // LÓGICA V1 mantida: pushReplacement
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoadingDietPlanScreen(), // Navega para 1.18
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();

    // V3: O estado agora vem do Provider V3
    final bool? interestInSupplements = provider.data.interestInSupplements;
    final bool canContinue = interestInSupplements != null;

    return Scaffold(
      // 1. AppBar V3 (Padrão)
      // (Esta é a última barra de progresso, 13/13)
      appBar: const _OnboardingAppBar(progress: 13 / 13),
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
                    "Interesse em suplementação?",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // 5. Subtítulo (V3)
                  Text(
                    "O Procs AI pode oferecer sugestões educacionais (sem marcas ou dosagens) para otimizar seus resultados.",
                    // V3: Usa o Tema (Remove AppTheme.secondaryText V1)
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // 6. Botões de Seleção (UI V3 - Cards)
                  // (Descarta _buildSelectionButton V1)

                  // Opção 1: Sim
                  _buildSelectionCard(
                    text: "Sim, estou aberto(a) a sugestões",
                    isSelected: interestInSupplements == true,
                    onTap: () {
                      // V3: Haptics
                      HapticService.lightImpact();
                      // V3: Atualiza o Provider V3
                      provider.setInterestInSupplements(true);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Opção 2: Não
                  _buildSelectionCard(
                    text: "Não, prefiro focar 100% na alimentação",
                    isSelected: interestInSupplements == false,
                    onTap: () {
                      HapticService.lightImpact();
                      provider.setInterestInSupplements(false);
                    },
                  ),

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
          onPressed: canContinue
              ? () => _onNext(context, interestInSupplements)
              : null,
          child: const Text('Finalizar Coleta de Dados'),
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
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: fgColor,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
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
// (Padrão V3)
// ---
class _OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double progress;

  const _OnboardingAppBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading: const BackButton(),
      title: Text(
        // V3: Lógica de Progresso (13/13 = Completo)
        progress < 1.0
            ? "Etapa ${(progress * 13).round()} de 13"
            : "Coleta Concluída!",
        style: theme.appBarTheme.titleTextStyle,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.surfaceContainer,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}
