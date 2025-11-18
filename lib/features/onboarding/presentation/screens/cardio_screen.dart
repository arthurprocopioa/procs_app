import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'loading_train_plan_screen.dart'; // Próxima tela (1.13)
// ---
// IMPORTS V3 (Fundação e Novos Widgets)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';
// V3 (CORREÇÃO): Importa o widget de feedback centralizado
import '../widgets/ai_feedback_card.dart';

/// V3 (PONTO 9): Tela de Cardio
/// Refatorada para a nova UX de 3 etapas (Preferência -> Tipo -> Agenda)
/// e para usar o Data Model e Provider do Sprint 1.
class CardioScreen extends StatefulWidget {
  const CardioScreen({super.key});

  @override
  State<CardioScreen> createState() => _CardioScreenState();
}

class _CardioScreenState extends State<CardioScreen> {
  // V3 (PONTO 9a.I): Controller para o TextField "Outros"
  late final TextEditingController _otherCardioController;

  // V3 (PONTO 9a.II): Opções de agenda (igual à tela de agenda)
  final Map<String, String> _cardioScheduleDays = {
    'sunday': 'Dom',
    'monday': 'Seg',
    'tuesday': 'Ter',
    'wednesday': 'Qua',
    'thursday': 'Qui',
    'friday': 'Sex',
    'saturday': 'Sáb',
  };
  final Map<int, String> _cardioScheduleTimes = {
    1: '1x',
    2: '2x',
    3: '3x',
    4: '4x',
    5: '5x',
    6: '6x',
    7: '7x',
  };

  @override
  void initState() {
    super.initState();
    final providerData = context.read<OnboardingProvider>().data;
    _otherCardioController =
        TextEditingController(text: providerData.cardioOtherDetail);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('cardio');
    });
  }

  @override
  void dispose() {
    _otherCardioController.dispose();
    super.dispose();
  }

  // ---
  // AÇÕES V3
  // ---
  void _onNext() {
    HapticService.mediumImpact();
    final provider = context.read<OnboardingProvider>();
    final data = provider.data;

    // V3 (PONTO 9a.I): Salva o "Outros" se estiver selecionado
    if (data.cardioType == 'outros') {
      provider.setCardioType('outros',
          otherDetail: _otherCardioController.text.trim());
    }

    // Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_cardio_set',
      parameters: {
        'preference': data.cardioPreference,
        'type': data.cardioType,
        'schedule_mode': data.cardioScheduleMode,
        'schedule_days': data.cardioDaysOfWeek.join(','),
        'schedule_times': data.cardioTimesPerWeek,
      },
    );

    // Navega para a próxima tela
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoadingTrainPlanScreen(), // 1.13
      ),
    );
  }

  // V3 (PONTO 9): Lógica de ativação do botão "Continuar"
  bool _getCanContinue(OnboardingProvider provider) {
    final data = provider.data;
    final preference = data.cardioPreference;

    if (preference == 'nao' || preference == 'ia_decide') {
      return true;
    }

    if (preference == 'sim') {
      // Precisa do Tipo
      if (data.cardioType == null) return false;
      // Se "Outros", precisa de texto
      if (data.cardioType == 'outros' &&
          _otherCardioController.text.trim().isEmpty) {
        return false;
      }
      // Precisa do Modo de Agenda
      final scheduleMode = data.cardioScheduleMode;
      if (scheduleMode == null) return false;
      // Valida a sub-agenda
      if (scheduleMode == 'on_days') return true;
      if (scheduleMode == 'days_of_week' && data.cardioDaysOfWeek.isNotEmpty) {
        return true;
      }
      if (scheduleMode == 'times_per_week' && data.cardioTimesPerWeek != null) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;

    final bool canContinue = _getCanContinue(provider);

    return Scaffold(
      appBar: AppBar(
        // V3 (PONTO 2): "Etapa" removido
        title: null,
        // V3 (PONTO 3): Nova barra de progresso
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(8.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: PremiumProgressBar(progress: 9 / 13),
          ),
        ),
      ),
      // V3 (PONTO 15): Adiciona SingleChildScrollView
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            // V3 (PONTO 9a): Novo título
            Text(
              "Você deseja adicionar cardio ao seu treino? (Caminhada, corrida, bicicleta, etc)",
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // --- V3 (PONTO 9): PASSO 1: Preferência ---
            _buildStep1Preference(context, provider),

            // --- V3 (PONTO 9c): Feedback da IA ---
            _buildStep1AiFeedback(context, data.cardioPreference),

            // --- V3 (PONTO 9a.I): PASSO 2: Tipo de Cardio ---
            _buildStep2CardioType(context, provider),

            // --- V3 (PONTO 9a.II): PASSO 3: Agenda do Cardio ---
            _buildStep3CardioSchedule(context, provider),

            const SizedBox(height: 40),
            // V3 (PONTO 15): Botão dentro do scroll
            ElevatedButton(
              onPressed: canContinue ? _onNext : null,
              child: const Text('Continuar'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // V3 (PONTO 9): Widget para o PASSO 1 (Preferência)
  Widget _buildStep1Preference(
      BuildContext context, OnboardingProvider provider) {
    return Column(
      children: [
        PremiumSelectionCard(
          text: "Sim, quero adicionar",
          isSelected: provider.data.cardioPreference == 'sim',
          onTap: () {
            HapticService.lightImpact();
            provider.setCardioPreference('sim');
          },
        ),
        const SizedBox(height: 16),
        PremiumSelectionCard(
          text: "Não, obrigado",
          isSelected: provider.data.cardioPreference == 'nao',
          onTap: () {
            HapticService.lightImpact();
            provider.setCardioPreference('nao');
          },
        ),
        const SizedBox(height: 16),
        PremiumSelectionCard(
          text: "Deixar o Procs AI decidir por mim",
          isSelected: provider.data.cardioPreference == 'ia_decide',
          onTap: () {
            HapticService.lightImpact();
            provider.setCardioPreference('ia_decide');
          },
        ),
      ],
    );
  }

  // V3 (PONTO 9c): Widget para o Feedback da IA
  Widget _buildStep1AiFeedback(BuildContext context, String? preference) {
    // V3: Copy que você pediu
    const String feedbackMessage =
        "Deixe o Procs AI decidir. Nossa IA analisará seu objetivo (ex: 'Ganhar Músculo') e seu progresso para determinar se o cardio é ideal para você, ajustando a frequência e intensidade para otimizar seus resultados sem prejudicar sua recuperação.";

    return AnimatedOpacity(
      opacity: preference == 'ia_decide' ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Visibility(
        visible: preference == 'ia_decide',
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0),
          // V3 (CORREÇÃO): Usa o novo AiFeedbackCard importado
          child: AiFeedbackCard(
            title: "Decisão da IA",
            message: feedbackMessage,
            state: FeedbackState.success, // Sempre 'success' (dourado)
          ),
        ),
      ),
    );
  }

  // V3 (PONTO 9a.I): Widget para o PASSO 2 (Tipo de Cardio)
  Widget _buildStep2CardioType(
      BuildContext context, OnboardingProvider provider) {
    final theme = Theme.of(context);
    final data = provider.data;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: (data.cardioPreference == 'sim')
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Qual cardio você prefere?",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                PremiumSelectionCard(
                  text: "Corrida / Caminhada",
                  isSelected: data.cardioType == 'corrida',
                  onTap: () {
                    HapticService.lightImpact();
                    provider.setCardioType('corrida');
                  },
                ),
                const SizedBox(height: 12),
                PremiumSelectionCard(
                  text: "Ciclismo (Bike)",
                  isSelected: data.cardioType == 'ciclismo',
                  onTap: () {
                    HapticService.lightImpact();
                    provider.setCardioType('ciclismo');
                  },
                ),
                const SizedBox(height: 12),
                PremiumSelectionCard(
                  text: "Natação",
                  isSelected: data.cardioType == 'natacao',
                  onTap: () {
                    HapticService.lightImpact();
                    provider.setCardioType('natacao');
                  },
                ),
                const SizedBox(height: 12),
                PremiumSelectionCard(
                  text: "Outros",
                  isSelected: data.cardioType == 'outros',
                  onTap: () {
                    HapticService.lightImpact();
                    provider.setCardioType('outros');
                  },
                ),
                // V3 (PONTO 9a.I / PONTO 13): TextField "Outros"
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: (data.cardioType == 'outros')
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextField(
                            controller: _otherCardioController,
                            decoration: const InputDecoration(
                              labelText: 'Qual outro cardio?',
                            ),
                            // V3 (PONTO 13): "OK"
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _onNext(),
                            onChanged: (text) {
                              // V3: Atualiza o provider "ao vivo"
                              provider.setCardioType('outros',
                                  otherDetail: text);
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  // V3 (PONTO 9a.II): Widget para o PASSO 3 (Agenda do Cardio)
  Widget _buildStep3CardioSchedule(
      BuildContext context, OnboardingProvider provider) {
    final theme = Theme.of(context);
    final data = provider.data;

    // Só mostra o Passo 3 se o Passo 1 ("sim") e o Passo 2 (tipo) estiverem feitos
    final bool showStep3 = (data.cardioPreference == 'sim' &&
        data.cardioType != null &&
        (data.cardioType != 'outros' ||
            _otherCardioController.text.trim().isNotEmpty));

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: showStep3
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Quando você prefere fazer cardio?",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                PremiumSelectionCard(
                  text: "No mesmo dia do treino",
                  isSelected: data.cardioScheduleMode == 'on_days',
                  onTap: () {
                    HapticService.lightImpact();
                    provider.setCardioScheduleMode('on_days');
                  },
                ),
                const SizedBox(height: 12),
                PremiumSelectionCard(
                  text: "Selecionar dias da semana",
                  isSelected: data.cardioScheduleMode == 'days_of_week',
                  onTap: () {
                    HapticService.lightImpact();
                    provider.setCardioScheduleMode('days_of_week');
                  },
                ),
                const SizedBox(height: 12),
                PremiumSelectionCard(
                  text: "Selecionar quantidade de vezes",
                  isSelected: data.cardioScheduleMode == 'times_per_week',
                  onTap: () {
                    HapticService.lightImpact();
                    provider.setCardioScheduleMode('times_per_week');
                  },
                ),

                // V3 (PONTO 9a.II): Sub-seleção (igual à tela de agenda)
                _buildCardioSubSchedule(context, provider),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  // V3 (PONTO 9a.II): Widget para a *sub-seleção* da agenda de cardio
  Widget _buildCardioSubSchedule(
      BuildContext context, OnboardingProvider provider) {
    final data = provider.data;

    // Bloco 1: Dias da Semana
    if (data.cardioScheduleMode == 'days_of_week') {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 colunas para caber
            childAspectRatio: 1.2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _cardioScheduleDays.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final key = _cardioScheduleDays.keys.elementAt(index);
            final text = _cardioScheduleDays.values.elementAt(index);
            final isSelected = data.cardioDaysOfWeek.contains(key);

            // V3 (PONTO 7): Reutiliza o `PremiumSelectionCard`
            return PremiumSelectionCard(
              text: text,
              textAlign: TextAlign.center, // Centraliza no grid
              isSelected: isSelected,
              onTap: () {
                HapticService.lightImpact();
                provider.toggleCardioDay(key);
              },
            );
          },
        ),
      );
    }

    // Bloco 2: Quantidade de Vezes
    if (data.cardioScheduleMode == 'times_per_week') {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 colunas
            childAspectRatio: 1.2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _cardioScheduleTimes.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final key = _cardioScheduleTimes.keys.elementAt(index);
            final text = _cardioScheduleTimes.values.elementAt(index);
            final isSelected = data.cardioTimesPerWeek == key;

            return PremiumSelectionCard(
              text: text,
              textAlign: TextAlign.center,
              isSelected: isSelected,
              onTap: () {
                HapticService.lightImpact();
                provider.setCardioTimesPerWeek(key);
              },
            );
          },
        ),
      );
    }

    // Vazio se 'on_days' ou null
    return const SizedBox.shrink();
  }
}
