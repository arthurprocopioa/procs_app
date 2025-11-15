import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // 1. IMPORT V3 (Lottie)
import 'package:provider/provider.dart';

// 2. IMPORTS V3 (Fundação)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import 'summary_screen.dart'; // Próxima tela (1.19)

/// Tela 1.18: Pausa (Loading) V3.1
/// (V3.1: Refatorada para Lottie.network() para corrigir o crash V3)
class LoadingDietPlanScreen extends StatefulWidget {
  const LoadingDietPlanScreen({super.key});

  @override
  State<LoadingDietPlanScreen> createState() => _LoadingDietPlanScreenState();
}

class _LoadingDietPlanScreenState extends State<LoadingDietPlanScreen> {
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
          .trackScreenView('loading_diet_plan');
    });
    _startFakeLoading();
  }

  Future<void> _startFakeLoading() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      HapticService.heavyImpact();
    }
  }

  void _onNext() {
    HapticService.lightImpact();
    context.read<AnalyticsService>().trackEvent(
      'loading_diet_plan_continue',
      parameters: {'phase_start': 'summary'},
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SummaryScreen(), // 1.19
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
          "Calculando suas metas de nutrição...",
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "Analisando suas preferências e restrições para criar suas variações...",
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
          "Seu plano de nutrição está pronto!",
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: _onNext,
          child: const Text('Ver Resumo do Plano'),
        ),
      ],
    );
  }
}
