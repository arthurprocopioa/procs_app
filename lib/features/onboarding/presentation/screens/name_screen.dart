import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../application/onboarding_provider.dart';
import 'reception_message_screen.dart';
// V3: Import do HapticService
import '../../../../core/services/haptic_service.dart';

/// V3.1.14 (Handoff V3.1.13): Nova Tela 1.2.1
/// Captura o nome do usuário.
class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _controller = TextEditingController();
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    // Handoff V3.1.14: Validação em tempo real (V3.1.14)
    _controller.addListener(() {
      final bool canContinue = _controller.text.trim().isNotEmpty;
      if (canContinue != _canContinue) {
        setState(() {
          _canContinue = canContinue;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (!_canContinue) return;
    // V3: Haptics
    HapticService.mediumImpact();

    // Handoff V3.1.14: Salva o nome na "Memória RAM" V3 (Provider V3.1.14)
    final name = _controller.text.trim();
    context.read<OnboardingProvider>().setName(name);

    // Handoff V3.1.13: Navega para a 'reception_message.dart'
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReceptionMessageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: theme.colorScheme.onSurface),
      ),
      // V3 (REFATORADO): A remoção do bottomNavigationBar
      // exige que o body seja scrollable para evitar overflow do teclado.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                "Como devo chamá-lo?",
                // Handoff V3.1.14: Usa o estilo V3 do app_theme
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                // Handoff V3.1.14: Usa o estilo V3 do app_theme
                decoration: const InputDecoration(
                  hintText: "Digite seu nome",
                ),
                // Handoff V3.1.14: Ação de "próximo" no teclado
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _onNext(),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),

              // V3 (REFATORADO): Botão movido para cá
              const SizedBox(height: 32),
              ElevatedButton(
                // V3: Estilo preservado (Botão Preto)
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                onPressed: _canContinue ? _onNext : null,
                child: const Text("Continuar"),
              ),
              // V3: Adiciona um padding inferior para o scroll
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
      // V3 (REFATORADO): bottomNavigationBar removido
    );
  }
}
