import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: O caminho correto (Substitui 'utils/haptics.dart' V1)
import 'manifesto_screen.dart'; // Próxima tela (1.22)
// (Remove 'app_theme.dart' V1)

/// Tela 1.21: Reforço psicológico (V3).
/// Refatorada para Fundação V3 (Tema, Haptics, Analytics) e UI V3 (Row).
class CommitmentScreen extends StatefulWidget {
  const CommitmentScreen({super.key});

  @override
  State<CommitmentScreen> createState() => _CommitmentScreenState();
}

class _CommitmentScreenState extends State<CommitmentScreen> {
  // --- ESTADO LOCAL V1 (Lógica mantida) ---
  bool _isCommitted = false;

  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('commitment');
    });
  }

  // --- AÇÕES V3 ---

  void _onNext() {
    // Lógica V1 mantida
    if (!_isCommitted) return;

    // V3: Haptics (Mapeamento V1 -> V3)
    HapticService.mediumImpact(); // (Era 'light', mas 'onNext' é 'medium')

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent('onboarding_commitment_made');

    // V3: CORREÇÃO DE LÓGICA (pushReplacement)
    // (Descarta o 'push' V1)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ManifestoScreen(), // Navega para 1.22
      ),
    );
  }

  /// Helper V3: Atualiza o estado do checkbox
  void _onCommitmentChanged(bool? value) {
    setState(() {
      _isCommitted = value ?? false;
    });
    // V3: Haptics
    HapticService.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    // ---
    // TEMA V3
    // ---
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Lógica V1 mantida
    final bool canContinue = _isCommitted;

    return Scaffold(
      // 1. AppBar V3 (Usa o Tema V3)
      appBar: AppBar(
        // V3: Remove cores '@Deprecated'
        // (O Tema V3 'appBarTheme' cuida da cor do BackButton)
        leading: Navigator.canPop(context) ? const BackButton() : null,
      ),
      // 2. Barra de Progresso: NÃO HÁ (Correto)
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 4. Ícone (V3)
              Icon(
                Icons.verified_user_rounded, // V1 (Correto)
                color: colorScheme.primary, // V3: Dourado (Tema)
                size: 64,
              ),
              const SizedBox(height: 24),

              // 5. Título (V3)
              Text(
                "Um último passo.",
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 6. Copy (V3)
              Text(
                "Planos de IA são poderosos, mas o progresso real exige consistência. Este é um sistema para quem leva a sério. Comprometa-se com seu progresso.",
                // V3: TEMA (Substitui AppTheme.secondaryText V1)
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 7. Input (UI V3 - Padrão "Row")
              // (Descarta _buildCommitmentCheckbox V1)
              _buildCommitmentRow(theme, textTheme),

              const SizedBox(height: 24),

              // 8. Botão de Ação (V3)
              ElevatedButton(
                onPressed: canContinue ? _onNext : null,
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper V3: Constrói o Checkbox + Row (Padrão V3 da 'terms_screen')
  Widget _buildCommitmentRow(ThemeData theme, TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: _isCommitted,
          onChanged: _onCommitmentChanged,
          // V3: TEMA (Substitui cores '@Deprecated' V1)
          activeColor: theme.colorScheme.primary,
          checkColor: theme.colorScheme.onPrimary,
        ),
        Expanded(
          child: Text(
            "Eu me comprometo com meu progresso.",
            // V3: TEMA (Substitui AppTheme.primaryText V1)
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
