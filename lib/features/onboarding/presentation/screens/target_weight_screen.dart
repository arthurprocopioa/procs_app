import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// [CORREÇÃO] 1. Removido 'package:flutter/cupertino.dart' (unnecessary_import)
// import 'package:flutter/cupertino.dart';
// V3: CORREÇÃO (Adiciona o import do ícone V3)
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: O caminho correto (Substitui 'utils/haptics.dart' V1)
import '../../application/onboarding_provider.dart';
import 'experience_screen.dart'; // Próxima tela (1.7)
// (Remove 'app_theme.dart' V1)

/// Tela 1.6: Onde o usuário define seu peso-alvo.
/// V3 FINAL (Corrigido): Usa 'currentWeight' (V3) e 'setTargetWeight' (V3).
class TargetWeightScreen extends StatefulWidget {
  const TargetWeightScreen({super.key});

  @override
  State<TargetWeightScreen> createState() => _TargetWeightScreenState();
}

class _TargetWeightScreenState extends State<TargetWeightScreen> {
  // V3: Estado local para o "Ruler Picker"
  late final PageController _pageController;
  late double _currentTargetWeight; // Peso-alvo (local)
  late final double _currentWeight; // Peso atual (fixo)

  // V3: Lógica V1 mantida
  final double _minWeight = 40.0;
  final double _maxWeight = 150.0;
  final double _step = 0.5; // (Era 0.1, mas 0.5 é mais usável)
  late final int _itemCount;

  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('target_weight');
    });

    // ---
    // V3: CORREÇÃO (O Bug que você achou)
    // (Substitui 'data.weight' V1 por 'data.currentWeight' V3)
    // ---
    final provider = context.read<OnboardingProvider>();
    // 1. Pega o Peso Atual (V3)
    _currentWeight = provider.data.currentWeight ?? 70.0;
    // 2. Pega o Peso-Alvo (V3) (Se já existir)
    _currentTargetWeight = provider.data.targetWeight ?? _currentWeight;

    // V3: Configura o "Ruler Picker"
    _itemCount = ((_maxWeight - _minWeight) / _step).round() + 1;
    final int initialPage =
        ((_currentTargetWeight - _minWeight) / _step).round();

    _pageController = PageController(
      initialPage: initialPage.clamp(0, _itemCount - 1),
      viewportFraction: 0.2, // Mostra 5 números
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---
  // AÇÕES V3
  // ---

  void _onNext() {
    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Implementa o TODO (Salva no Provider V3)
    final provider = context.read<OnboardingProvider>();
    // V3: O setter V3 (Correto)
    provider.setTargetWeight(_currentTargetWeight);

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_target_weight_set',
      parameters: {
        'targetWeight': _currentTargetWeight,
        // V3: CORREÇÃO (O Bug que você achou)
        'currentWeight': _currentWeight, // (Pega a variável V3)
        'objective': provider.data.objective,
      },
    );

    // V3: Navegação
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ExperienceScreen(), // Navega para 1.7
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ---
    // TEMA V3
    // ---
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();

    // [CORREÇÃO] 3. Variável 'canContinue' removida (unused_local_variable)
    // Ela não era usada pois o botão está sempre ativo.
    // const bool canContinue = true;

    return Scaffold(
      // 1. AppBar V3 (Padrão)
      appBar: const _OnboardingAppBar(progress: 3 / 13),
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
                    "Qual é o seu peso-alvo?",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // 5. Subtítulo (V3)
                  Text(
                    "Ajuste a régua para definir sua meta.",
                    style: textTheme.bodyMedium, // V3: TEMA
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // 6. Input V3 (Ruler Picker)
                  // (Descarta _Slider V1)
                  _buildWeightRuler(theme),

                  const SizedBox(height: 24),

                  // 7. V3: Cartão de Feedback (da Referência V3)
                  _DynamicFeedbackCard(
                    objective: provider.data.objective,
                    // V3: CORREÇÃO (O Bug que você achou)
                    currentWeight: _currentWeight, // (Usa a variável V3)
                    targetWeight: _currentTargetWeight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // 8. Botão de Ação (Inferior Fixo - V3 UI)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          // [CORREÇÃO] 2. Removido 'canContinue ? ... : null' (dead_code)
          onPressed: _onNext,
          child: const Text('Continuar'),
        ),
      ),
    );
  }

  /// Helper V3: Constrói o "Ruler Picker" (Padrão V3)
  Widget _buildWeightRuler(ThemeData theme) {
    return SizedBox(
      height: 100, // Altura fixa para o ruler
      child: Stack(
        alignment: Alignment.center,
        children: [
          // O PageView com os números
          PageView.builder(
            controller: _pageController,
            itemCount: _itemCount,
            onPageChanged: (int pageIndex) {
              final double weightValue = (pageIndex * _step) + _minWeight;
              if (_currentTargetWeight != weightValue) {
                // V3: Haptics
                HapticService.lightImpact();
                setState(() {
                  _currentTargetWeight = weightValue;
                });
              }
            },
            itemBuilder: (context, index) {
              final double weightValue = (index * _step) + _minWeight;
              final bool isSelected =
                  (_currentTargetWeight - weightValue).abs() < (_step / 2);

              // V3: Estilo do Tema
              final style = isSelected
                  ? theme.textTheme.headlineMedium
                  : theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.textTheme.bodyMedium?.color);

              // Mostra apenas valores inteiros (70, 71)
              final bool isFullKg = (weightValue % 1 == 0);

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isFullKg ? weightValue.toInt().toString() : '',
                      style: style,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: isFullKg ? 2 : 1,
                      height: isFullKg ? 40 : 25,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ],
                ),
              );
            },
          ),

          // O indicador central (V3: Dourado)
          Positioned(
            bottom: 0,
            child: Container(
              width: 3,
              height: 50, // Mais alto que os outros
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // O feedback visual do peso selecionado
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${_currentTargetWeight.toStringAsFixed(1)} kg",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// V3: Widget de Feedback Dinâmico (Lógica V3)
class _DynamicFeedbackCard extends StatelessWidget {
  final String? objective;
  final double? currentWeight;
  final double targetWeight;

  const _DynamicFeedbackCard({
    this.objective,
    this.currentWeight,
    required this.targetWeight,
  });

  // V3: Lógica de Feedback
  String _getFeedbackMessage() {
    if (objective == null || currentWeight == null) {
      return "Defina seus objetivos para receber feedback.";
    }

    final double diff = targetWeight - currentWeight!;

    if (objective == 'ganhar_musculo') {
      if (diff <= 0) {
        return "Seu objetivo é ganhar músculo, mas seu peso-alvo é menor ou igual ao seu peso atual. Ajuste sua meta.";
      }
      if (diff > 5) {
        return "Meta desafiadora! Ganhar ${diff.toStringAsFixed(1)} kg de músculo levará tempo e consistência.";
      }
      return "Excelente. Focar em ${diff.toStringAsFixed(1)} kg de ganho é uma ótima meta inicial.";
    }

    if (objective == 'perder_gordura') {
      if (diff >= 0) {
        return "Seu objetivo é perder gordura, mas seu peso-alvo é maior ou igual ao seu peso atual. Ajuste sua meta.";
      }
      if (diff < -7) {
        return "Meta desafiadora! Perder ${diff.abs().toStringAsFixed(1)} kg exigirá disciplina na dieta e no cardio.";
      }
      return "Excelente. Focar em ${diff.abs().toStringAsFixed(1)} kg de perda é uma ótima meta inicial.";
    }

    if (objective == 'manter_saude') {
      if (diff.abs() > 2) {
        return "Seu objetivo é manter, mas seu peso-alvo está ${diff.abs().toStringAsFixed(1)} kg diferente do seu peso atual.";
      }
      return "Perfeito. Manter o peso atual é um ótimo objetivo para focar na saúde e performance.";
    }

    return "Feedback aparecerá aqui.";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = _getFeedbackMessage();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.brain, // V3: Ícone da IA
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Feedback da IA",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
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
