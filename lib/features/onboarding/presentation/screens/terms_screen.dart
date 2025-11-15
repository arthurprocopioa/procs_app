import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/services/analytics_service.dart';
import '../../application/onboarding_provider.dart';
import 'name_screen.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  late AnalyticsService _analytics;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _analytics = context.read<AnalyticsService>();
    _analytics.trackScreenView('terms_screen');
  }

  void _showTermsModal(BuildContext context, String title, String content) {
    // Feedback tátil usando API Flutter
    HapticFeedback.lightImpact();

    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12.0),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(title, style: theme.textTheme.headlineMedium),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Text(
                    content * 3,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTermsText(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    );
    final linkStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );

    const loremIpsum =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: [
          const TextSpan(text: "Eu li e aceito os "),
          TextSpan(
            text: "Termos de Uso",
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _showTermsModal(context, "Termos de Uso", loremIpsum);
              },
          ),
          const TextSpan(text: " e a "),
          TextSpan(
            text: "Política de Privacidade",
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _showTermsModal(context, "Política de Privacidade", loremIpsum);
              },
          ),
          const TextSpan(text: "."),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.shieldHalved,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                "Nossa Política de Privacidade",
                style: textTheme.displayLarge?.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Consumer<OnboardingProvider>(
                builder: (context, provider, child) {
                  final bool termsAccepted = provider.data.termsAccepted;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: termsAccepted,
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
                            HapticFeedback.lightImpact();
                            provider.setTermsAccepted(newValue);
                          }
                        },
                        activeColor: theme.colorScheme.primary,
                        checkColor: theme.colorScheme.onSurface,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: _buildTermsText(context),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              Consumer<OnboardingProvider>(
                builder: (context, provider, child) {
                  final bool termsAccepted = provider.data.termsAccepted;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: termsAccepted
                          ? () {
                              HapticFeedback.mediumImpact();
                              _analytics.trackEvent(
                                'terms_accepted',
                                parameters: {'accepted': true},
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const NameScreen(),
                                ),
                              );
                            }
                          : null,
                      child: const Text("Continuar"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
