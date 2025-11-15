import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: O caminho correto (Substitui 'utils/haptics.dart' V1)
import 'whatsapp_screen.dart'; // Próxima tela (1.23)
// (Remove 'app_theme.dart' V1)

/// Tela 1.22: O "Manifesto" do Procs AI (V3).
/// Refatorada para Fundação V3 e Lógica de Navegação V3 (pushReplacement).
class ManifestoScreen extends StatefulWidget {
  const ManifestoScreen({super.key});

  @override
  State<ManifestoScreen> createState() => _ManifestoScreenState();
}

class _ManifestoScreenState extends State<ManifestoScreen> {
  // --- AÇÕES V3 ---

  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('manifesto');
    });

    // V3: Haptics (Lógica V1 mantida, Padrão V3 correto)
    // (Evento-Chave: O Manifesto)
    HapticService.heavyImpact();
  }

  void _onNext() {
    // V3: Haptics (Mapeamento V1 -> V3)
    // (V1 era 'light', V3 'onNext' é 'medium')
    HapticService.mediumImpact();

    // V3: Analytics
    context
        .read<AnalyticsService>()
        .trackEvent('onboarding_manifesto_accepted');

    // V3: CORREÇÃO DE LÓGICA (pushReplacement)
    // (Descarta o 'push' V1. O usuário não deve voltar para cá.)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const WhatsappScreen(), // Navega para 1.23
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // V1: Sem AppBar (Correto)
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // 4. Ícone (V3)
              Icon(
                Icons.insights_rounded, // V1 (Correto)
                color: colorScheme.primary, // V3: Dourado (Tema)
                size: 64,
              ),
              const SizedBox(height: 24),

              // 5. Título (V3)
              Text(
                "Você não precisa de um personal.",
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // 6. Subtítulo (V3)
              Text(
                "Você precisa de um sistema.",
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary, // V3: Dourado (Tema)
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 7. Copy (V3)
              Text(
                "Um personal trainer apenas te dá a ficha. O Procs AI te dá um sistema de IA que te força a executá-la através de competição, recompensas e prova social. Deixe nossa IA pensar. Seu trabalho é não quebrar a corrente.",
                // V3: TEMA (Substitui AppTheme.secondaryText V1)
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // 8. Botão de Ação (V3)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: _onNext,
                  // V3: TEMA (Usa o Tema V3 Padrão)
                  child: const Text(
                    'Eu entendi. Estou pronto para o sistema.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
