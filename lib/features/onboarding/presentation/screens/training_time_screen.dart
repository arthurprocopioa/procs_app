import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'loading_train_plan_screen.dart'; // Próxima tela (11/15)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/premium_selection_card.dart';

/// NOVA TELA (Passo 10/15): Pergunta sobre o tempo de treino disponível.
/// REFACTOR: Opção 'personalizado' removida.
class TrainingTimeScreen extends StatefulWidget {
  const TrainingTimeScreen({super.key});

  @override
  State<TrainingTimeScreen> createState() => _TrainingTimeScreenState();
}

class _TrainingTimeScreenState extends State<TrainingTimeScreen> {
  // Opções de tempo de treino (Opção 'personalizado' removida)
  final Map<String, String> _timeOptions = {
    '30min': '30 minutos',
    '45min': '45 minutos',
    '60min': '60 minutos',
    '+60min': '+ 60 minutos',
  };

  // Controllers e FocusNodes removidos por serem desnecessários

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('training_time');
    });
    // Corrigido: Se a opção for 'personalizado' no provider, ela é resetada para null
    final provider = context.read<OnboardingProvider>();
    if (provider.data.trainingTime == 'personalizado') {
      provider.setTrainingTime(null);
    }
  }

  // Dispose simplificado
  @override
  void dispose() {
    super.dispose();
  }

  void _onNext() {
    final provider = context.read<OnboardingProvider>();
    final selectedTimeKey = provider.data.trainingTime;

    // Agora só verificamos se a opção não é nula
    if (selectedTimeKey == null) return;

    HapticService.mediumImpact();
    // FocusScope.of(context).unfocus() é desnecessário aqui, mas inofensivo

    context.read<AnalyticsService>().trackEvent(
      'onboarding_training_time_set',
      parameters: {'time': selectedTimeKey},
    );

    // Navega para a tela de Loading do Plano de Treino (Passo 11/15)
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LoadingTrainPlanScreen(),
    ));
  }

  // Lógica para setar o tempo (Seleção Única)
  void _onSelectTime(OnboardingProvider provider, String key) {
    HapticService.lightImpact();
    provider.setTrainingTime(key);
    // Não há mais FocusNode para gerenciar. Limpeza máxima!
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final selectedTimeKey = provider.data.trainingTime;

    // Lógica simplificada: canContinue é true se algo foi selecionado
    final bool canContinue = selectedTimeKey != null;

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
            // BARRA DE PROGRESSO E BOTÃO DE VOLTAR (Passo 10/15)
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
                    child: PremiumProgressBar(progress: 10 / 17),
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
                      "Quanto tempo você tem disponível para treinar por sessão?",
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Seleção das opções de tempo (Cards Premium)
                    // A lógica do TextField animado é totalmente removida.
                    ..._timeOptions.entries.map((entry) {
                      final key = entry.key;
                      final text = entry.value;
                      final isSelected = selectedTimeKey == key;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: PremiumSelectionCard(
                          text: text,
                          isSelected: isSelected,
                          onTap: () => _onSelectTime(provider, key),
                        ),
                      );
                    }).toList(),

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
}
