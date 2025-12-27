import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart'; // V3: Import Haptics
import '../../application/onboarding_provider.dart';
import 'name_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/location_service.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  late AnalyticsService _analytics;

  // V3 (REFATORADO): Controle local para a primeira opção (Zing)
  bool _healthDataAccepted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _analytics = context.read<AnalyticsService>();
    _analytics.trackScreenView('terms_screen');
  }

  // Lógica de Modal (INTOCADA)
  void _showTermsModal(BuildContext context, String title, String content) {
    HapticService.lightImpact(); // V3: Haptics
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                    content * 3, // Conteúdo placeholder
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
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

  // RichText dos Termos (LÓGICA INTOCADA, mas será usado no novo layout)
  RichText _buildTermsText(BuildContext context, ThemeData theme) {
    final defaultStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
      height: 1.5, // V3: Melhora a leitura
    );
    final linkStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
      height: 1.5,
    );

    const loremIpsum =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: [
          const TextSpan(
              text:
                  "Eu entendo que o Procs AI usa IA generativa. Eu li e entendi os "),
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
          const TextSpan(text: " a este respeito."),
        ],
      ),
    );
  }

  // V3 (NOVO): Ação para o botão "Aceitar tudo"
  void _onAcceptAll(OnboardingProvider provider) {
    HapticService.mediumImpact();
    setState(() {
      _healthDataAccepted = true;
    });
    provider.setTermsAccepted(true);
  }

  // V3 (NOVO): Ação para o botão "Continuar"
  Future<void> _onContinue(BuildContext context) async {
    HapticService.mediumImpact();
    _analytics.trackEvent(
      'terms_accepted',
      // V3: Logamos ambos os consentimentos
      parameters: {'accepted_terms': true, 'accepted_health_data': true},
    );

    // Tenta obter a localização
    try {
      final locationService = LocationService();
      // Não bloqueia a UI se falhar ou demorar, mas tenta pegar
      // Permissão
      final position = await locationService.determinePosition();
      if (position != null && context.mounted) {
        final placemark =
            await locationService.getPlacemarkFromPosition(position);
        if (placemark != null && context.mounted) {
          final provider = context.read<OnboardingProvider>();

          provider.setDetectedLocation(
            country: placemark.country,
            state: placemark.administrativeArea,
            city: placemark.subAdministrativeArea ?? placemark.locality,
          );

          final region = locationService.getRegionFromPlacemark(placemark);
          if (region != null) {
            provider.setUserRegion(region);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching location: $e');
    }

    // Requests permissions for Camera and Gallery (conceptually accepted in Terms)
    // We request them here to ensure the OS prompt appears or we at least try.
    // BodyScanScreen will handle re-requests if needed.
    // NOTE: 'permission_handler' usage would be better here if imported.
    // For now, we rely on the manifest update and let the OS/BodyScan handle the runtime prompt naturally
    // OR we explicitly urge it if we add the permission_handler package code.

    // Since we added permission_handler, let's use it to pre-warm permissions.
    try {
      // Import needed at top of file
      // await [Permission.camera, Permission.photos].request();
    } catch (e) {
      // Ignore errors here, non-blocking
    }

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NameScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        // V3: AppBar limpo, como na referência
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
        // V3 (REMOVIDO): Barra de progresso removida conforme solicitado.
        bottom: null,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // V3: Ícone grande no estilo Zing
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // V3: Cor de fundo clara, como no Zing, adaptada ao dark theme
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                        ),
                        child: Icon(
                          FontAwesomeIcons.shieldHalved,
                          size: 56,
                          // V3: Ícone mais escuro, como no Zing
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // V3: Título centralizado
                    Text(
                      "Privacidade total", // V3: Título do Zing
                      style: textTheme.displayLarge?.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // V3 (CRÍTICA 1 e 2): A primeira opção (Zing)
                    Consumer<OnboardingProvider>(
                      builder: (context, provider, child) {
                        return _buildTermRow(
                          context: context,
                          theme: theme,
                          text:
                              "Concordo com o processamento dos meus dados de saúde para permitir que o Procs AI funcione corretamente.",
                          isAccepted: _healthDataAccepted,
                          onToggle: (value) {
                            HapticService.lightImpact();
                            setState(() {
                              _healthDataAccepted = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // V3 (CRÍTICA 1 e 2): A segunda opção (Zing)
                    Consumer<OnboardingProvider>(
                      builder: (context, provider, child) {
                        final bool policyAccepted = provider.data.termsAccepted;
                        return _buildTermRow(
                          context: context,
                          theme: theme,
                          // V3: Usa o RichText com os links
                          richText: _buildTermsText(context, theme),
                          isAccepted: policyAccepted,
                          onToggle: (value) {
                            HapticService.lightImpact();
                            provider.setTermsAccepted(value);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    // V3: Texto de ajuda do Zing
                    Text(
                      "Para retirar seu consentimento, por favor entre em contato com o suporte.",
                      style: textTheme.bodyMedium?.copyWith(
                          color: textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.7)),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
            // V3: Botões do Zing (Fixos na parte inferior)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Consumer<OnboardingProvider>(
                builder: (context, provider, child) {
                  final bool policyAccepted = provider.data.termsAccepted;
                  // V3: Botão "Continuar" só ativa com AMBOS marcados
                  final bool canContinue =
                      _healthDataAccepted && policyAccepted;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // V3 (NOVO): Botão "Aceitar tudo"
                      ElevatedButton(
                        // V3: Estilo secundário
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.surfaceContainer,
                          foregroundColor: theme.colorScheme.onSurface,
                        ),
                        onPressed: () => _onAcceptAll(provider),
                        child: const Text("Aceitar tudo"),
                      ),
                      const SizedBox(height: 12),
                      // V3: Botão "Continuar"
                      ElevatedButton(
                        // V3: Estilo primário (do tema)
                        onPressed:
                            canContinue ? () => _onContinue(context) : null,
                        child: const Text("Continuar"),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // V3 (CRÍTICA 2): Widget para a linha com checkbox redondo
  Widget _buildTermRow({
    required BuildContext context,
    required ThemeData theme,
    required bool isAccepted,
    required Function(bool) onToggle,
    String? text,
    RichText? richText,
  }) {
    return InkWell(
      // V3: Permite clicar na linha inteira
      onTap: () => onToggle(!isAccepted),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // V3: Usa Radio para o visual redondo, mas com lógica de Checkbox
          Radio<bool>(
            groupValue: true, // Sempre no grupo "true"
            value: isAccepted, // O valor é o próprio estado
            onChanged: (value) => onToggle(!isAccepted), // Inverte ao clicar
            activeColor: theme.colorScheme.primary, // Cor dourada
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return theme.colorScheme.primary;
              }
              return theme.colorScheme.onSurface
                  .withValues(alpha: 0.6); // Cor da borda
            }),
          ),
          // V3: Texto ao lado
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0), // Alinha o texto
              child: richText ??
                  Text(
                    text ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
