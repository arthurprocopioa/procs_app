import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: O caminho correto (Substitui 'utils/haptics.dart' V1)
import 'commitment_screen.dart'; // Próxima tela (1.21)
// (Remove 'app_theme.dart' V1)

/// Tela 1.20: Conversão para Notificações (Gamification).
/// Refatorada para Fundação V3 (Tema, Haptics, Analytics).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // --- AÇÕES V3 ---

  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('notifications');
    });
  }

  /// Ação V3: Pede a permissão de notificação (FCM)
  // [CORREÇÃO] 1. Removido 'BuildContext context' dos parâmetros
  Future<void> _onActivate() async {
    // [CORREÇÃO] 2. 'context.read' agora usa o 'context' do State (que é seguro)
    final analytics = context.read<AnalyticsService>();
    bool permissionGranted = false;

    try {
      // Lógica V1 mantida (está 100% correta)
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      if (!mounted) return;

      if (permissionGranted) {
        // [CORREÇÃO] O linter apontava para este bloco (linha 75 no log original)
        // A lógica está correta, o problema era o parâmetro 'context' na função.
        await analytics.trackEvent('notifications_permission_activated');
        // V3: Haptics (Mapeamento de Evento-Chave)
        // (Substitui Haptics.success() V1)
        HapticService.heavyImpact();
      } else {
        await analytics.logEvent('notifications_permission_denied');
        // V3: Haptics (Mapeamento de Erro/Aviso)
        // (Substitui Haptics.error() V1)
        HapticService.mediumImpact();
      }
    } catch (e) {
      if (mounted) {
        await analytics.logEvent('notifications_permission_error');
        // V3: Haptics (Mapeamento de Erro/Aviso)
        HapticService.mediumImpact();
      }
      debugPrint("Erro ao pedir permissão de FCM: $e");
    }

    if (!mounted) return;
    // [CORREÇÃO] 3. Chama a função _navigateToNext sem 'context'
    _navigateToNext();
  }

  /// Ação V3: Pula a permissão
  // [CORREÇÃO] 4. Removido 'BuildContext context' dos parâmetros
  void _onSkip() {
    // [CORREÇÃO] 5. 'context.read' agora usa o 'context' do State
    final analytics = context.read<AnalyticsService>();
    analytics.logEvent('notifications_permission_skipped');
    // V3: Haptics
    HapticService.lightImpact();
    // [CORREÇÃO] 6. Chama a função _navigateToNext sem 'context'
    _navigateToNext();
  }

  /// Helper V1 (Lógica mantida: pushReplacement)
  // [CORREÇÃO] 7. Removido 'BuildContext context' dos parâmetros
  void _navigateToNext() {
    // [CORREÇÃO] 8. 'Navigator.of(context)' agora usa o 'context' do State
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const CommitmentScreen(), // Navega para 1.21
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // V3: Ícone (Usa o Tema V3)
              Icon(
                Icons.notifications_active_rounded,
                color: colorScheme.primary, // V3: Dourado (Tema)
                size: 64,
              ),
              const SizedBox(height: 24),
              // V3: Título (Usa o Tema V3)
              Text(
                "Não quebre a sua corrente!",
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // V3: Subtítulo (Usa o Tema V3)
              Text(
                "O Procs AI funciona como um jogo. Para te lembrar das suas 'Missões Diárias', enviar seus pontos e avisar quando seu ranking subir, precisamos enviar notificações.",
                // V3: TEMA (Substitui AppTheme.secondaryText V1)
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              // V3: Botão Primário (Usa o Tema V3)
              ElevatedButton(
                // [CORREÇÃO] 9. Alterado para referência de método
                onPressed: _onActivate,
                child: const Text('Ativar Notificações'),
              ),
              const SizedBox(height: 12),
              // V3: Botão Secundário (Usa o Tema V3)
              TextButton(
                // [CORREÇÃO] 10. Alterado para referência de método
                onPressed: _onSkip,
                child: Text(
                  "Pular por enquanto",
                  // V3: TEMA (Substiti AppTheme.secondaryText V1)
                  style: textTheme.bodyMedium?.copyWith(
                    color: textTheme.bodyMedium?.color, // V3: Cinza (Tema)
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
