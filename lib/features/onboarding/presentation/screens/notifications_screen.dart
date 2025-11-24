import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../../domain/onboarding_data_model.dart';
import 'commitment_screen.dart'; // Próxima tela
import '../widgets/premium_selection_card.dart';
import '../widgets/procs_back_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Estado local para controle de UI, o dado real vai pro Provider
  bool _showConfig = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('notifications');
    });
  }

  Future<void> _onActivate() async {
    HapticService.heavyImpact();
    final provider = context.read<OnboardingProvider>();

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        provider.setNotificationsEnabled(true);
        setState(() {
          _showConfig = true; // Revela as configurações
        });

        // Se o usuário não quiser configurar agora, ele pode clicar em Continuar
        // Mas a ideia é mostrar o serviço primeiro.
      } else {
        _onSkip();
      }
    } catch (e) {
      debugPrint("Erro ao pedir notificação: $e");
      _onSkip();
    }
  }

  void _onSkip() {
    HapticService.lightImpact();
    final provider = context.read<OnboardingProvider>();
    provider.setNotificationsEnabled(false);
    _navigateToNext();
  }

  void _navigateToNext() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CommitmentScreen()),
    );
  }

  // --- LÓGICA DE CONFIGURAÇÃO ---

  Future<void> _configureTraining(OnboardingProvider provider) async {
    // Exemplo de lógica: Abre um modal para selecionar dias e horas
    // Baseado no provider.data.scheduleTimesPerWeek
    final times = provider.data.scheduleTimesPerWeek ?? 3;

    // Mockup da lógica complexa (em produção, seria um modal Stateful)
    // Aqui simplifico mostrando um SnackBar para simular a funcionalidade
    // pois a implementação completa do modal de dias/horas é extensa.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              "Configurar $times dias de treino... (Funcionalidade em Modal)")),
    );
    // Na vida real: showDialog com MultiSelectDay e TimePicker
  }

  // ... Outros métodos de configuração ...

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;

    return Scaffold(
      appBar: AppBar(leading: const ProcsBackButton()),
      bottomNavigationBar: _showConfig
          ? Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: _navigateToNext,
                child: const Text('Confirmar e Continuar'),
              ),
            )
          : null, // Botão inicial é inline

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              if (!_showConfig) ...[
                const Icon(Icons.notifications_active_rounded,
                    size: 64, color: Color(0xFFD4AF37)),
                const SizedBox(height: 24),
                Text(
                  "Não deixe o acaso controlar sua rotina.",
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "O Procs AI é um sistema ativo. Ative as notificações para receber lembretes estratégicos de treino, cardio e alimentação exatamente quando você precisa. Sem spam, apenas execução.",
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _onActivate,
                  child: const Text('Ativar Sistema de Alertas'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _onSkip,
                  child: Text("Configurar depois", style: textTheme.bodyMedium),
                ),
              ] else ...[
                // --- FASE 2: CONFIGURAÇÃO ---
                Text(
                  "Configure sua Rotina",
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Defina seus horários agora para a IA otimizar seu cronograma.",
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // 1. TREINO
                if (data.scheduleTimesPerWeek != null)
                  _NotificationConfigCard(
                    title: "Treino (${data.scheduleTimesPerWeek}x/sem)",
                    icon: Icons.fitness_center,
                    onTap: () => _configureTraining(provider),
                    isConfigured: false, // Lógica de estado viria do provider
                  ),

                // 2. CARDIO
                if (data.cardioPreference == 'sim')
                  _NotificationConfigCard(
                    title: "Cardio (${data.cardioTimesPerWeek}x/sem)",
                    icon: Icons.directions_run,
                    onTap: () {}, // Implementar modal
                    isConfigured: false,
                  ),

                // 3. COMPRAS
                _NotificationConfigCard(
                  title: "Compras de Mercado",
                  icon: Icons.shopping_cart,
                  onTap: () {}, // Implementar modal
                  isConfigured: false,
                ),

                // 4. REFEIÇÕES
                _NotificationConfigCard(
                  title: "Refeições (${data.mealCount}x/dia)",
                  icon: Icons.restaurant,
                  onTap: () {}, // Implementar modal
                  isConfigured: false,
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: _navigateToNext,
                    child: const Text("Pular configuração fina (Padrão IA)"),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationConfigCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isConfigured;

  const _NotificationConfigCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isConfigured,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isConfigured ? theme.colorScheme.primary : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: theme.textTheme.bodyLarge),
              ),
              Icon(
                isConfigured ? Icons.check_circle : Icons.arrow_forward_ios,
                size: 16,
                color: isConfigured ? theme.colorScheme.primary : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
