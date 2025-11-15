import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../application/onboarding_provider.dart';
import 'reception_message_screen.dart';

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
    HapticFeedback.mediumImpact();

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

    // Handoff V3.1.14 (FIX): O 'bottomNavigationBar' (V3.1.14)
    // garante que o botão "flutue" acima do teclado,
    // como você solicitou no Handoff V3.1.13.
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: theme.colorScheme.onSurface),
      ),
      body: Padding(
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
          ],
        ),
      ),
      // ---
      // V3.1.14 (ARQUITETURA V3.1.13): O "Botão Flutuante"
      // Handoff V3.1.13: "o botão deve ficar acima [do teclado]"
      // ---
      bottomNavigationBar: Padding(
        // V3.1.14: Garante que o padding da UI e do teclado
        // (viewInsets) sejam respeitados.
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: ElevatedButton(
          // Handoff V3.1.14: Usa o estilo V3 (Branco),
          // mas o Handoff V3.1.13 (imagem) pedia Preto.
          // Vamos usar o estilo V3 (Branco) por padrão
          // e refatorar V3.1.15 se você (CPTO V3.1.14) odiar.
          //
          // ATUALIZAÇÃO V3.1.14: A imagem Handoff V3.1.13 (`image_a54f44.png`)
          // mostra o botão PRETO (`surfaceVariant`). Vamos honrar o Handoff V3.1.13.
          style: ElevatedButton.styleFrom(
            // [CORREÇÃO] 1. 'surfaceVariant' depreciado
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            foregroundColor: theme.colorScheme.onSurface,
          ),
          onPressed: _canContinue ? _onNext : null,
          child: const Text("Esse sou eu!"),
        ),
      ),
    );
  }
}
