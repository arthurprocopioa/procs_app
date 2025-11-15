import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For InputFormatter
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // V3: Import V3

// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: O caminho correto (Substitui 'utils/haptics.dart' V1)
import '../../application/onboarding_provider.dart';
import 'checkout_screen.dart'; // Próxima tela (1.24)
// (Remove 'app_theme.dart' V1)

/// Tela 1.23: Coleta de WhatsApp (Funil de Fechamento V3).
/// Refatorada para Fundação V3 (Tema, Haptics, Provider, Analytics).
class WhatsappScreen extends StatefulWidget {
  const WhatsappScreen({super.key});

  @override
  State<WhatsappScreen> createState() => _WhatsappScreenState();
}

class _WhatsappScreenState extends State<WhatsappScreen> {
  late final TextEditingController _phoneController;
  bool _canContinue = false;
  final int _minPhoneLength = 10; // Lógica V1 mantida

  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('whatsapp');
    });

    // V3: Inicializa com dados do Provider (se o usuário voltar)
    final initialPhone = context.read<OnboardingProvider>().data.phoneNumber;
    _phoneController = TextEditingController(text: initialPhone);

    _canContinue = (initialPhone?.length ?? 0) >= _minPhoneLength;

    // Lógica V1 mantida
    _phoneController.addListener(() {
      final bool isLengthValid =
          _phoneController.text.length >= _minPhoneLength;
      if (isLengthValid != _canContinue) {
        setState(() => _canContinue = isLengthValid);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // --- AÇÕES V3 ---

  void _onSave() {
    if (!_canContinue) return;

    // V3: Haptics (Mapeamento V1 -> V3)
    // (V1 era 'light', V3 'onSave' é 'medium')
    HapticService.mediumImpact();

    final String phoneNumber = _phoneController.text.trim();

    // V3: Implementa o TODO (Salva no Provider V3)
    context.read<OnboardingProvider>().setPhoneNumber(phoneNumber);

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_whatsapp_saved',
      parameters: {'phone_length': phoneNumber.length},
    );

    _navigateToNext();
  }

  void _onSkip() {
    // V3: Haptics
    HapticService.lightImpact();

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent('onboarding_whatsapp_skipped');

    // V3: Salva o "skip" (como nulo) no Provider
    context.read<OnboardingProvider>().setPhoneNumber(null);

    _navigateToNext();
  }

  /// Lógica V1 mantida (pushReplacement)
  void _navigateToNext() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CheckoutScreen()), // 1.24
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
      // 1. AppBar V3 (Usa o Tema V3)
      appBar: AppBar(
        // V3: Remove cores '@Deprecated'
        // (O Tema V3 'appBarTheme' cuida da cor do BackButton)
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          // Lógica V1 de Layout (spaceBetween) mantida
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Conteúdo Superior ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // V3: ÍCONE (Substitui 'chat_bubble' V1)
                  Icon(
                    FontAwesomeIcons.whatsapp, // V3: Ícone correto
                    color: colorScheme.primary, // V3: Dourado (Tema)
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  // V3: Título (Usa o Tema V3)
                  Text(
                    "Garanta seu plano no WhatsApp",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // V3: Subtítulo (Usa o Tema V3)
                  Text(
                    "Seu plano expira em 7 dias se não for ativado. Para garantir que você não perca o acesso, informe seu WhatsApp. Enviaremos o link de acesso por lá.",
                    // V3: TEMA (Substitui AppTheme.secondaryText V1)
                    style: textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // V3: TextField (Usa o Tema V3 'inputDecorationTheme')
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Seu número de WhatsApp',
                      prefixText: '+55 ',
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),

              // --- Botões Inferiores ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // V3: Botão Primário (Usa o Tema V3)
                  ElevatedButton(
                    onPressed: _canContinue ? _onSave : null,
                    child: const Text('Salvar e ir para o Checkout'),
                  ),
                  const SizedBox(height: 12),
                  // V3: Botão Secundário (Usa o Tema V3)
                  TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      "Pular esta etapa",
                      // V3: TEMA (Substitui AppTheme.secondaryText V1)
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
