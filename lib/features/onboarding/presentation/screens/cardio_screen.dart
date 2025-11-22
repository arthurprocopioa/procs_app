import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importa a nova tela de tempo de treino
// CORRIGIDO: Garantindo que o caminho e o nome estejam corretos.
import 'training_time_screen.dart';
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
// Para acessar o enum FeedbackState
import '../widgets/ai_feedback_card.dart';

/// V3 (PONTO 9): Tela de Cardio
/// Refatorada para o novo padrão de UX (Barra no topo, Botão no rodapé)
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

  // Foco para fechar o teclado do campo "Outros" de forma segura
  final FocusNode _otherCardioFocusNode = FocusNode();

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
    _otherCardioFocusNode.dispose();
    super.dispose();
  }

  // ---
  // AÇÕES V3
  // ---
  void _onNext() {
    HapticService.mediumImpact();
    final provider = context.read<OnboardingProvider>();
    final data = provider.data;

    // Fecha o teclado antes de navegar (segurança contra bugs)
    FocusScope.of(context).unfocus();

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

    try {
      // Navega para a nova tela de Tempo de Treino (Passo 10/15)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TrainingTimeScreen(),
        ),
      );
    } catch (e) {
      // Loga o erro de navegação para depuração
      debugPrint('ERRO CRÍTICO DE NAVEGAÇÃO NA CARDIO SCREEN: $e');
      // Você deve ver esta mensagem no console se o problema persistir.
    }
  }

  // V3 (PONTO 9): Lógica de ativação do botão "Continuar"
  bool _getCanContinue(OnboardingProvider provider) {
    final data = provider.data;
    final preference = data.cardioPreference;

    if (preference == null) return false;

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
      // 1. AppBar removido
      appBar: null,

      // 2. Botão de Continuação fixado no rodapé
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
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 9/15)
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
                    // Progress bar: 9/15
                    child: PremiumProgressBar(progress: 9 / 17),
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
                    // V3 (PONTO 9a): Novo título
                    Text(
                      "Você deseja adicionar cardio ao seu treino? (Caminhada, corrida, bicicleta, etc)",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // --- V3 (PONTO 9): PASSO 1: Preferência ---
                    _buildStep1Preference(context, provider),
                    const SizedBox(height: 24),

                    // --- V3 (PONTO 9c): Feedback da IA (VISÍVEL SEMPRE) ---
                    _buildStep1AiFeedback(context),
                    const SizedBox(height: 16),

                    // --- V3 (PONTO 9a.I): PASSO 2: Tipo de Cardio ---
                    _buildStep2CardioType(context, provider),

                    // --- V3 (PONTO 9a.II): PASSO 3: Agenda do Cardio ---
                    _buildStep3CardioSchedule(context, provider),

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
            _otherCardioFocusNode.unfocus(); // Fecha teclado se estiver aberto
          },
        ),
        const SizedBox(height: 16),
        PremiumSelectionCard(
          text: "Não, obrigado",
          isSelected: provider.data.cardioPreference == 'nao',
          onTap: () {
            HapticService.lightImpact();
            provider.setCardioPreference('nao');
            _otherCardioFocusNode.unfocus();
          },
        ),
        const SizedBox(height: 16),
        PremiumSelectionCard(
          text: "Deixar o Procs AI decidir por mim",
          isSelected: provider.data.cardioPreference == 'ia_decide',
          onTap: () {
            HapticService.lightImpact();
            provider.setCardioPreference('ia_decide');
            _otherCardioFocusNode.unfocus();
          },
        ),
      ],
    );
  }

  // V3 (PONTO 9c): Widget para o Feedback da IA (AGORA É SEMPRE VISÍVEL)
  Widget _buildStep1AiFeedback(BuildContext context) {
    // V3: Copy que você pediu
    const String feedbackMessage =
        "Deixe o Procs AI decidir. Nossa IA analisará seu objetivo (ex: 'Ganhar Músculo') e seu progresso para determinar se o cardio é ideal para você, ajustando a frequência e intensidade para otimizar seus resultados sem prejudicar sua recuperação.";

    // CORREÇÃO: Removido o AnimatedOpacity/Visibility
    return AiFeedbackCard(
      title: "Decisão da IA",
      message: feedbackMessage,
      state: FeedbackState
          .neutral, // Neutro (agora com brilho) para ser sempre visível e informativo
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
                            focusNode:
                                _otherCardioFocusNode, // Adicionado FocusNode
                            decoration: const InputDecoration(
                              labelText: 'Qual outro cardio?',
                            ),
                            // CORREÇÃO: Ação para OK/Concluir
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              _otherCardioFocusNode.unfocus();
                            },
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

            // Usa o PremiumSelectionCard de seleção múltipla (como na ScheduleScreen)
            return _CardioDaySelectionCard(
              text: text,
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
        child: Column(
          // Usando Column para melhor UX do PremiumSelectionCard
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _cardioScheduleTimes.entries.map((entry) {
            final key = entry.key;
            final text = entry.value;
            final isSelected = data.cardioTimesPerWeek == key;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: PremiumSelectionCard(
                text: text,
                isSelected: isSelected,
                onTap: () {
                  HapticService.lightImpact();
                  provider.setCardioTimesPerWeek(key);
                },
              ),
            );
          }).toList(),
        ),
      );
    }

    // Vazio se 'on_days' ou null
    return const SizedBox.shrink();
  }
}

/// NOVO WIDGET: Card de Seleção Múltipla para Cardio (dias da semana)
/// Reutiliza a lógica minimalista de seleção que você aprovou (borda amarela).
class _CardioDaySelectionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _CardioDaySelectionCard({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : theme.colorScheme.surfaceContainer,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.15),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
