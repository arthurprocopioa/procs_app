import 'dart:async'; // Importado para usar o Timer
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import 'diet_restrictions_screen.dart'; // Próxima fase (12/15)

/// Tela 1.13: Pausa (Loading) V3.1 - Agora é o Passo 11/15
/// (Refatorada para animação de frases e tempo fixo de 6 segundos)
class LoadingTrainPlanScreen extends StatefulWidget {
  const LoadingTrainPlanScreen({super.key});

  @override
  State<LoadingTrainPlanScreen> createState() => _LoadingTrainPlanScreenState();
}

class _LoadingTrainPlanScreenState extends State<LoadingTrainPlanScreen> {
  // --- CONSTANTES DE TEMPO E MENSAGENS ---
  static const int _loadingDurationSeconds = 6;
  final List<String> _loadingMessages = [
    "Processando seus dados",
    "Avaliando possibilidades",
    "Montando a melhor ficha de treino para você",
  ];
  // ----------------------------------------

  bool _isLoading = true;
  String _currentMessage = "Processando seus dados";
  int _messageIndex = 0;
  Timer? _messageTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('loading_train_plan');
    });
    _startLoadingSequence();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  /// Inicia a sequência de carregamento (mensagens + tempo total)
  void _startLoadingSequence() {
    // 1. Configura o Timer para alternar as mensagens a cada 2 segundos
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;

      setState(() {
        _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
        _currentMessage = _loadingMessages[_messageIndex];
      });
    });

    // 2. Configura o Timer para a navegação após 6 segundos
    _navigationTimer =
        Timer(const Duration(seconds: _loadingDurationSeconds), () {
      if (!mounted) return;

      // Para os timers
      _messageTimer?.cancel();

      setState(() {
        _isLoading = false;
      });
      HapticService.heavyImpact();
    });
  }

  /// Navega para a Fase 2 (Dieta)
  void _onNext() {
    HapticService.lightImpact();

    context.read<AnalyticsService>().trackEvent(
      'loading_train_plan_continue',
      parameters: {'phase_start': 'diet'},
    );

    // Navega para a Dieta, que agora é 12/15
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            const DietRestrictionsScreen(), // Navega para 12/15
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Esta tela não tem AppBar/Barra de Progresso (confirmado pelo Procópio)
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // 2. Botão Fixo no Rodapé
      bottomNavigationBar: _isLoading
          ? null // Não mostra o botão durante o loading
          : Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: _onNext,
                child: const Text('Seguir para próxima fase'),
              ),
            ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            // Usa AnimatedSwitcher para transicionar entre Loading e Sucesso
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLoading
                  ? _buildLoadingState(theme)
                  : _buildSuccessState(theme),
            ),
          ),
        ),
      ),
    );
  }

  /// Estado 1: Loading (Com indicador e frases alternantes)
  Widget _buildLoadingState(ThemeData theme) {
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ÍCONE DE CARREGAMENTO (Nossas cores, dourado)
        Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              backgroundColor: theme.colorScheme.surfaceContainer,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // MENSAGEM ALTERNANTE
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _currentMessage,
            key: ValueKey<String>(
                _currentMessage), // Chave para animar a transição
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Não feche o aplicativo...",
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Estado 2: Sucesso (Com Prova Social)
  Widget _buildSuccessState(ThemeData theme) {
    return Column(
      key: const ValueKey('success'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ÍCONE DE SUCESSO (V3: Check Dourado)
        Center(
          child: Icon(
            Icons.check_circle_rounded,
            color: theme.colorScheme.primary,
            size: 80,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          "Seu plano de treino está pronto!",
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // PROVA SOCIAL (Mantida)
        _buildSocialProof(theme),

        const SizedBox(height: 48),

        // O botão 'Continuar' está agora no bottomNavigationBar
      ],
    );
  }

  /// Helper V3: Prova Social (Mantida)
  Widget _buildSocialProof(ThemeData theme) {
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
            Icons.verified_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "\"O Procs AI me fez treinar 30 dias seguidos pela primeira vez.\"",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 4),
                Text(
                  "- Usuário Beta",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
