import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ---
// IMPORTS V3 (Fundação e Novos Widgets)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import 'experience_screen.dart'; // Próxima tela
import '../widgets/premium_progress_bar.dart'; // V3 (PONTO 3)
// V3 (CORREÇÃO): Importa o widget de feedback centralizado
import '../widgets/ai_feedback_card.dart';
import '../widgets/procs_back_button.dart';

/// Tela 1.6: Onde o usuário define seu peso-alvo.
/// V3 (SPRINT 2/3): Refatorada para nova UX de régua e feedback.
class TargetWeightScreen extends StatefulWidget {
  const TargetWeightScreen({super.key});

  @override
  State<TargetWeightScreen> createState() => _TargetWeightScreenState();
}

class _TargetWeightScreenState extends State<TargetWeightScreen> {
  // V3: Estado local para o "Ruler Picker"
  late final PageController _pageController;
  late int _currentTargetWeight; // Peso-alvo (local)
  late final int _currentWeight; // Peso atual (fixo)

  // V3 (PONTO 4 - Régua): Apenas valores cheios
  final int _minWeight = 40;
  final int _maxWeight = 150;
  late final int _itemCount;

  // Corrigido: Para usar o contexto do State e não o do Widget
  late final OnboardingProvider _provider;

  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('target_weight');
    });

    // V3 (CORRIGIDO): Usa os dados corretos do provider
    _provider = context.read<OnboardingProvider>();
    // Arredonda para o inteiro mais próximo
    _currentWeight = _provider.data.currentWeight?.round() ?? 70;
    _currentTargetWeight =
        _provider.data.targetWeight?.round() ?? _currentWeight;

    // V3 (PONTO 4 - Régua): Lógica de inteiros
    _itemCount = (_maxWeight - _minWeight) + 1; // Ex: 150 - 40 + 1 = 111 itens
    final int initialPage =
        (_currentTargetWeight - _minWeight).clamp(0, _itemCount - 1);

    _pageController = PageController(
      initialPage: initialPage,
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
    HapticService.mediumImpact();
    // Usando a variável de estado para acessar o provider
    final provider = _provider;

    // Salva o peso-alvo (como double, conforme o model)
    provider.setTargetWeight(_currentTargetWeight.toDouble());

    // Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_target_weight_set',
      parameters: {
        'targetWeight': _currentTargetWeight,
        'currentWeight': _currentWeight,
        'objective': provider.data.objective,
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ExperienceScreen(), // Próxima tela
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();

    // V3 (PONTO 4 - Feedback): Determina o estado do feedback
    final feedbackState = _getFeedbackState(
      objective: provider.data.objective,
      currentWeight: _currentWeight,
      targetWeight: _currentTargetWeight,
    );

    return Scaffold(
      // 1. AppBar removido para controle total da barra de navegação
      appBar: null,

      // 2. Botão de Continuação fixado no rodapé
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed: _onNext,
          child: const Text('Continuar'),
        ),
      ),

      // 3. Body para o conteúdo e barra de progresso customizada
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: PremiumProgressBar(progress: 3 / 16),
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
                    Text(
                      "Qual é o seu peso-alvo?",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Ajuste a régua para definir sua meta.",
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // V3 (PONTO 4 - Régua): Ruler Picker com valores cheios
                    _buildWeightRuler(theme),

                    const SizedBox(height: 24),

                    // V3 (PONTO 4 - Feedback): Cartão de Feedback Dinâmico
                    AiFeedbackCard(
                      message: _getFeedbackMessage(
                          objective: provider.data.objective,
                          currentWeight: _currentWeight,
                          targetWeight: _currentTargetWeight,
                          state: feedbackState),
                      state: feedbackState, // Passa o estado da cor
                    ),

                    // O espaço que antes era ocupado pelo botão:
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

  /// V3 (PONTO 4 - Régua): Constrói o "Ruler Picker" com inteiros
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
              final int weightValue = pageIndex + _minWeight;
              if (_currentTargetWeight != weightValue) {
                HapticService.lightImpact();
                setState(() {
                  _currentTargetWeight = weightValue;
                });
              }
            },
            itemBuilder: (context, index) {
              final int weightValue = index + _minWeight;
              final bool isSelected = (_currentTargetWeight == weightValue);

              // Mostra apenas números a cada 5kg para limpar a UI
              final bool isMajorTick = (weightValue % 5 == 0);

              final style = isSelected
                  ? theme.textTheme.headlineMedium
                  : theme.textTheme.bodyLarge?.copyWith(
                      color: isMajorTick
                          ? theme.textTheme.bodyMedium?.color
                          : Colors.transparent, // Esconde números "menores"
                    );

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weightValue.toString(), // Sempre mostra o número
                      style: style,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: isMajorTick ? 2 : 1,
                      height: isMajorTick ? 40 : 25,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              );
            },
          ),

          // O indicador central (Dourado)
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

          // O feedback visual do peso selecionado (Ex: "70 kg")
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$_currentTargetWeight kg", // V3: Apenas valor cheio
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

/// V3 (PONTO 4 - Feedback): Lógica para determinar o estado da cor
/// (Movido para fora da classe para ser acessível pelo helper de mensagem)
FeedbackState _getFeedbackState({
  required String? objective,
  required int currentWeight,
  required int targetWeight,
}) {
  if (objective == null) return FeedbackState.neutral;

  final int diff = targetWeight - currentWeight;

  if (objective == 'ganhar_musculo') {
    if (diff <= 0) return FeedbackState.error; // Erro
    if (diff > 10) return FeedbackState.warning; // Aviso (difícil)
    return FeedbackState.success; // Sucesso
  }

  if (objective == 'perder_gordura') {
    if (diff >= 0) return FeedbackState.error; // Erro
    if (diff < -15) return FeedbackState.warning; // Aviso (difícil)
    return FeedbackState.success; // Sucesso
  }

  if (objective == 'manter_saude') {
    if (diff.abs() > 3) return FeedbackState.warning; // Aviso
    return FeedbackState.success; // Sucesso
  }

  return FeedbackState.neutral;
}

/// V3 (PONTO 4): Lógica de Mensagem
/// (Movido para fora da classe)
String _getFeedbackMessage({
  required String? objective,
  required int currentWeight,
  required int targetWeight,
  required FeedbackState state,
}) {
  if (objective == null) {
    return "Defina seu objetivo e peso-alvo para receber feedback.";
  }

  final int diff = targetWeight - currentWeight;

  switch (state) {
    case FeedbackState.error:
      if (objective == 'ganhar_musculo') {
        return "Meta inválida: Seu objetivo é ganhar músculo, mas seu peso-alvo é menor ou igual ao seu peso atual.";
      }
      if (objective == 'perder_gordura') {
        return "Meta inválida: Seu objetivo é perder gordura, mas seu peso-alvo é maior ou igual ao seu peso atual.";
      }
      break;
    case FeedbackState.warning:
      if (objective == 'ganhar_musculo') {
        return "Meta desafiadora: Ganhar ${diff.abs()} kg de músculo levará tempo e consistência.";
      }
      if (objective == 'perder_gordura') {
        return "Meta desafiadora: Perder ${diff.abs()} kg exigirá disciplina na dieta e no cardio.";
      }
      if (objective == 'manter_saude') {
        return "Ajuste de meta: Seu objetivo é manter, mas seu peso-alvo está ${diff.abs()} kg diferente do seu peso atual.";
      }
      break;
    case FeedbackState.success:
      if (objective == 'ganhar_musculo') {
        return "Excelente meta: Focar em ${diff.abs()} kg de ganho é um ótimo ponto de partida.";
      }
      if (objective == 'perder_gordura') {
        return "Excelente meta: Focar em ${diff.abs()} kg de perda é um objetivo realista.";
      }
      if (objective == 'manter_saude') {
        return "Perfeito. Manter o peso atual é um ótimo objetivo para focar na saúde e performance.";
      }
      break;
    default:
      break;
  }
  return "Feedback da IA aparecerá aqui.";
}
