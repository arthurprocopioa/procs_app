import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import 'checkout_screen.dart';

class WhatsappScreen extends StatefulWidget {
  const WhatsappScreen({super.key});

  @override
  State<WhatsappScreen> createState() => _WhatsappScreenState();
}

class _WhatsappScreenState extends State<WhatsappScreen> {
  late final TextEditingController _phoneController;
  bool _canContinue = false;
  final int _minPhoneLength = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('whatsapp');
    });

    final initialPhone = context.read<OnboardingProvider>().data.phoneNumber;
    _phoneController = TextEditingController(text: initialPhone);

    _canContinue = (initialPhone?.length ?? 0) >= _minPhoneLength;

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

  void _onSave() {
    if (!_canContinue) return;
    HapticService.mediumImpact();
    final String phoneNumber = _phoneController.text.trim();
    context.read<OnboardingProvider>().setPhoneNumber(phoneNumber);
    context.read<AnalyticsService>().trackEvent(
      'onboarding_whatsapp_saved',
      parameters: {'phone_length': phoneNumber.length},
    );
    _navigateToNext();
  }

  void _onSkip() {
    HapticService.lightImpact();
    context.read<AnalyticsService>().trackEvent('onboarding_whatsapp_skipped');
    context.read<OnboardingProvider>().setPhoneNumber(null);
    _navigateToNext();
  }

  void _navigateToNext() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      // CORREÇÃO OVERFLOW: SingleChildScrollView
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Espaço superior fixo em vez de Spacer
              const SizedBox(height: 32),

              Icon(
                FontAwesomeIcons.whatsapp,
                color: colorScheme.primary,
                size: 64,
              ),
              const SizedBox(height: 24),

              Text(
                "Garanta seu plano no WhatsApp",
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                "Seu plano expira em 7 dias se não for ativado. Para garantir que você não perca o acesso, informe seu WhatsApp. Enviaremos o link de acesso por lá.",
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Seu número de WhatsApp',
                  prefixText: '+55 ',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              // Espaço flexível ou fixo grande
              const SizedBox(height: 40),

              // Botões
              ElevatedButton(
                onPressed: _canContinue ? _onSave : null,
                child: const Text('Salvar e ir para o Checkout'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _onSkip,
                child: Text(
                  "Pular esta etapa",
                  style: textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 32), // Espaço final
            ],
          ),
        ),
      ),
    );
  }
}
