import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_train_plan_screen.dart'; // Próxima tela (1.13)
// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: O caminho correto
import '../../application/onboarding_provider.dart';
// (Remove 'haptics.dart' V1)

/// Tela 1.12: Onde o usuário informa sobre cardio (Lógica V1, UI V3).
/// Esta é a última tela da Fase 1 (Treino).
class CardioScreen extends StatefulWidget {
  const CardioScreen({super.key});

  @override
  State<CardioScreen> createState() => _CardioScreenState();
}

class _CardioScreenState extends State<CardioScreen> {
  // ---
  // ESTADO LOCAL V3
  // (Mantém a lógica V1, mas usa 'keys' V3)
  // ---
  String? _primaryCardioOption;
  String? _subCardioPreference;

  // Lógica V3: Mapeia 'keys' para 'labels'
  final Map<String, String> _primaryOptions = {
    'sim': 'Sim',
    'nao': 'Não',
    'ia_decide': 'Deixar o Procs AI decidir pra mim',
  };

  final Map<String, String> _subOptions = {
    'on_days': 'Nos dias de treino',
    'off_days': 'Em dias separados',
  };

  @override
  void initState() {
    super.initState();
    // V3: Inicializa o estado local com os dados do Provider (se existirem)
    final providerData = context.read<OnboardingProvider>().data;
    _primaryCardioOption = providerData.cardioPreference;
    _subCardioPreference = providerData.cardioSchedule;

    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('cardio');
    });
  }

  // ---
  // AÇÕES V3
  // ---

  void _onNext() {
    // Lógica V1 mantida
    if (!(_getCanContinue())) return;

    // V3: Haptics (Substitui V1)
    HapticService.mediumImpact();

    // V3: Implementa o TODO
    final provider = context.read<OnboardingProvider>();
    provider.setCardioData(
      preference: _primaryCardioOption!,
      schedule: _subCardioPreference,
    );

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_cardio_set',
      parameters: {
        'preference': _primaryCardioOption!,
        'schedule': _subCardioPreference ?? 'n/a',
      },
    );

    // V3: Navegação
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            const LoadingTrainPlanScreen(), // Navega para 1.13
      ),
    );
  }

  // Lógica V1 mantida
  bool _getCanContinue() {
    if (_primaryCardioOption == null) return false;
    if (_primaryCardioOption == 'sim') {
      return _subCardioPreference != null;
    }
    return true; // ('Não' ou 'IA' podem avançar)
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final bool canContinue = _getCanContinue();
    final bool showSubSelection = _primaryCardioOption == 'sim';

    return Scaffold(
      // 1. AppBar V3 (Padrão)
      appBar: const _OnboardingAppBar(progress: 9 / 13),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // 2. Título (V3)
                  Text(
                    "Você deseja adicionar cardio?",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // 3. Parte 1: Seleção Primária (UI V3)
                  // (Descarta _buildPrimaryButton V1)
                  ..._primaryOptions.entries.map((entry) {
                    final key = entry.key;
                    final text = entry.value;
                    return _buildSelectionCard(
                      text: text,
                      isSelected: _primaryCardioOption == key,
                      onTap: () {
                        // V3: Haptics
                        HapticService.lightImpact();
                        setState(() {
                          _primaryCardioOption = key;
                          _subCardioPreference = null; // Reseta a sub-seleção
                        });
                      },
                    );
                  }),

                  // 4. Parte 2: Sub-Seleção (Lógica V1, UI V3)
                  AnimatedOpacity(
                    opacity: showSubSelection ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Visibility(
                      visible: showSubSelection,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          // Subtítulo V3
                          Text(
                            "Como prefere fazer?",
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // (Descarta _buildSubButton V1)
                          ..._subOptions.entries.map((entry) {
                            final key = entry.key;
                            final text = entry.value;
                            return _buildSelectionCard(
                              text: text,
                              isSelected: _subCardioPreference == key,
                              onTap: () {
                                HapticService.lightImpact();
                                setState(() {
                                  _subCardioPreference = key;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 96), // Espaço para o botão
                ],
              ),
            ),
          ),
        ],
      ),
      // 5. Botão de Ação (Inferior Fixo - V3 UI)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed: canContinue ? _onNext : null,
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
              // Expande o texto para quebrar linha se for muito longo
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
              const SizedBox(width: 16),
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
// (Baseado no que foi feito em 'focus_area_screen.dart')
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
        "Etapa ${(progress * 13).round()} de 13",
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
