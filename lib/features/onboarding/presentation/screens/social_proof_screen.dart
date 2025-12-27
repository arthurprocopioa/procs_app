import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import 'checkout_screen.dart';
// import '../../../../core/widgets/gravity_background.dart';

class SocialProofScreen extends StatefulWidget {
  const SocialProofScreen({super.key});

  @override
  State<SocialProofScreen> createState() => _SocialProofScreenState();
}

class _SocialProofScreenState extends State<SocialProofScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('social_proof');
    });
  }

  void _onNext() {
    HapticService.mediumImpact();
    context.read<AnalyticsService>().trackEvent('social_proof_accepted');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),

                    // Header
                    Text(
                      "Resultados Reais",
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade().moveY(begin: 20),

                    const SizedBox(height: 8),

                    Text(
                      "Junte-se a quem já transformou o corpo e a mente com o Procs AI.",
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 200.ms).moveY(begin: 20),

                    const SizedBox(height: 40),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStat(theme, "4.9", "Avaliação\nMédia"),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.white24,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        _buildStat(theme, "10k+", "Vidas\nImpactadas"),
                      ],
                    ).animate().fade(delay: 400.ms),

                    const SizedBox(height: 40),

                    // Reviews List
                    _buildReviewCard(
                      context,
                      name: "Ricardo M.",
                      role: "Perdeu 12kg em 3 meses",
                      text:
                          "Eu já tinha tentado de tudo. O que fez a diferença foi a IA ajustando minha dieta toda semana. Surreal.",
                      rating: 5,
                      delay: 600,
                    ),
                    const SizedBox(height: 16),
                    _buildReviewCard(
                      context,
                      name: "Fernanda S.",
                      role: "Ganhou 4kg de massa",
                      text:
                          "O treino muda conforme eu evoluo. Nunca estagnei desde que comecei. Vale cada centavo.",
                      rating: 5,
                      delay: 700,
                    ),
                    const SizedBox(height: 16),
                    _buildReviewCard(
                      context,
                      name: "André L.",
                      role: "Mais energia e foco",
                      text:
                          "Não é só sobre estética. Minha produtividade no trabalho dobrou depois que regulei meu sono e treino com o app.",
                      rating: 5,
                      delay: 800,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Trust Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_outlined,
                          color: Color(0xFFD4AF37), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Garantia de satisfação de 7 dias",
                        style: textTheme.bodySmall
                            ?.copyWith(color: const Color(0xFFD4AF37)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "QUERO FAZER PARTE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: 1000.ms).moveY(begin: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: const Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReviewCard(
    BuildContext context, {
    required String name,
    required String role,
    required String text,
    required int rating,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white10,
                child: Text(
                  name[0],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFD4AF37),
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fade(delay: delay.ms).moveX(begin: 20);
  }
}
