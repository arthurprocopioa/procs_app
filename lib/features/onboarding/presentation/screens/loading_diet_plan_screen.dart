import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import 'summary_screen.dart'; // Próxima fase final

/// NOVA TELA: Loading para a Dieta (NÃO CONTA COMO ETAPA DO ONBOARDING).
class LoadingDietPlanScreen extends StatefulWidget {
  const LoadingDietPlanScreen({super.key});

  @override
  State<LoadingDietPlanScreen> createState() => _LoadingDietPlanScreenState();
}

class _LoadingDietPlanScreenState extends State<LoadingDietPlanScreen> {
  // --- CONSTANTES DE TEMPO E MENSAGENS ---
  static const int _loadingDurationSeconds = 6;
  final List<String> _loadingMessages = [
    "Analisando suas restrições e preferências",
    "Calculando o balanço calórico ideal para sua meta",
    "Gerando seu plano alimentar premium",
  ];
  // ----------------------------------------

  bool _isLoading = true;
  String _currentMessage = "Analisando suas restrições e preferências";
  int _messageIndex = 0;
  Timer? _messageTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('loading_diet_plan');
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

      _messageTimer?.cancel();

      setState(() {
        _isLoading = false;
      });
      HapticService.heavyImpact();
    });
  }

  /// Navega para o Resumo
  void _onNext() {
    HapticService.lightImpact();

    context.read<AnalyticsService>().trackEvent(
      'loading_diet_plan_complete',
      parameters: {'phase_start': 'summary'},
    );

    // Navega para a tela final de Resumo/Checkout
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SummaryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // NÃO TEMOS BARRA DE PROGRESSO NESTA TELA
      appBar: null,
      backgroundColor: theme.scaffoldBackgroundColor,

      // Botão Fixo no Rodapé (só aparece no sucesso)
      bottomNavigationBar: _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: _onNext,
                child: const Text('Seguir para o resumo'), // Texto mais direto
              ),
            ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
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

  /// Estado 1: Loading
  Widget _buildLoadingState(ThemeData theme) {
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _currentMessage,
            key: ValueKey<String>(_currentMessage),
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
          "Seu plano de dieta está pronto!",
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // PROVA SOCIAL (Mantida)
        _buildSocialProof(theme),

        const SizedBox(height: 48),
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
                  "\"O Procs AI me ajudou a comer de forma inteligente sem restrições loucas.\"",
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
