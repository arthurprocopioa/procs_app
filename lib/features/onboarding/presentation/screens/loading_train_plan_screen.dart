import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import 'diet_restrictions_screen.dart';

/// Tela 1.13: Pausa (Loading) V3.1
/// (V3.1: Refatorada para Lottie.network() para corrigir o crash V3)
class LoadingTrainPlanScreen extends StatefulWidget {
  const LoadingTrainPlanScreen({super.key});

  @override
  State<LoadingTrainPlanScreen> createState() => _LoadingTrainPlanScreenState();
}

class _LoadingTrainPlanScreenState extends State<LoadingTrainPlanScreen> {
  bool _isLoading = true;

  // V3.1: URLs V3 (Substituem os assets V3.0)
  final String _lottieLoadingUrl =
      "https://lottie.host/1b98b961-d07c-440f-8336-05681e8c00ad/aWJm8tDOaO.json";
  final String _lottieSuccessUrl =
      "https://lottie.host/b0c3d23a-c816-419b-a16f-16c80c2f8a4f/N8NQnwnsN6.json";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('loading_train_plan');
    });
    _startFakeLoading();
  }

  /// Simula o processamento da IA
  Future<void> _startFakeLoading() async {
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      HapticService.heavyImpact();
    }
  }

  /// Navega para a Fase 2 (Dieta)
  void _onNext() {
    HapticService.lightImpact();

    context.read<AnalyticsService>().trackEvent(
      'loading_train_plan_continue',
      parameters: {'phase_start': 'diet'},
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            const DietRestrictionsScreen(), // Navega para 1.14
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              // V3.1: CORREÇÃO (Lottie.network)
              child: _isLoading
                  ? _buildLoadingState(theme, _lottieLoadingUrl)
                  : _buildSuccessState(theme, _lottieSuccessUrl),
            ),
          ),
        ),
      ),
    );
  }

  /// Estado 1: Loading (V3.1 com Lottie.network)
  Widget _buildLoadingState(ThemeData theme, String url) {
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // V3.1: LOTTIE.NETWORK (Substitui Lottie.asset V3.0)
        Lottie.network(
          url,
          height: 150,
        ),
        const SizedBox(height: 24),

        Text(
          "Gerando seu plano de treino...",
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "Nossa IA está analisando suas respostas para criar o plano perfeito...",
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Estado 2: Sucesso (V3.1 com Lottie.network)
  Widget _buildSuccessState(ThemeData theme, String url) {
    return Column(
      key: const ValueKey('success'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // V3.1: LOTTIE.NETWORK (Substitui Lottie.asset V3.0)
        Lottie.network(
          url,
          height: 120,
          repeat: false, // Só toca uma vez
        ),
        const SizedBox(height: 16),

        Text(
          "Seu plano de treino está pronto!",
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        _buildSocialProof(theme),

        const SizedBox(height: 48),

        ElevatedButton(
          onPressed: _onNext,
          child: const Text('Ver Fase 2: Dieta'),
        ),
      ],
    );
  }

  /// Helper V3: Prova Social (Tematizada)
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
