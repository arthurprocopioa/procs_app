import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/onboarding_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../widgets/premium_progress_bar.dart';
import '../widgets/procs_back_button.dart';
import 'objective_screen.dart';

class CurrentPhysiqueScreen extends StatefulWidget {
  const CurrentPhysiqueScreen({super.key});

  @override
  State<CurrentPhysiqueScreen> createState() => _CurrentPhysiqueScreenState();
}

class _CurrentPhysiqueScreenState extends State<CurrentPhysiqueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('current_physique');
    });
  }

  void _onNext(BuildContext context, String physique) {
    HapticService.mediumImpact();
    context.read<OnboardingProvider>().setCurrentPhysique(physique);
    context.read<AnalyticsService>().trackEvent(
      'onboarding_physique_selected',
      parameters: {'physique': physique},
    );

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ObjectiveScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<OnboardingProvider>();
    final currentPhysique = provider.data.currentPhysique;

    // Definição das opções
    final List<Map<String, dynamic>> options = [
      {
        'id': 'magro',
        'title': 'Magro',
        'subtitle': 'Dificuldade para ganhar peso.',
        'image': 'assets/images/physiques/skinny.png',
      },
      {
        'id': 'falso_magro',
        'title': 'Falso Magro',
        'subtitle': 'Parece magro, mas tem barriga.',
        'image': 'assets/images/physiques/skinny_fat.png',
      },
      {
        'id': 'sobrepeso',
        'title': 'Sobrepeso',
        'subtitle': 'Acima do peso, quer secar.',
        'image': 'assets/images/physiques/overweight.png',
      },
      {
        'id': 'atletico',
        'title': 'Atlético',
        'subtitle': 'Já tem massa muscular aparente.',
        'image': 'assets/images/physiques/athletic.png',
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const ProcsBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: PremiumProgressBar(progress: 2 / 17),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  Text(
                    "Como você descreveria seu corpo atual?",
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Grid de Opções
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          0.65, // Mais alto para parecer "portrait"
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final opt = options[index];
                      final isSelected = currentPhysique == opt['id'];

                      return _PhysiqueCard(
                        title: opt['title'],
                        subtitle: opt['subtitle'],
                        imagePath: opt['image'],
                        isSelected: isSelected,
                        onTap: () => _onNext(context, opt['id']),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhysiqueCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _PhysiqueCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Borda ativa se selecionado, senão transparente (ou muito sutil)
    final borderColor =
        isSelected ? theme.colorScheme.primary : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Arredondamento maior
          border: Border.all(color: borderColor, width: isSelected ? 3 : 0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2)
                ]
              : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand, // Ocupa todo o espaço
          children: [
            // 1. Imagem de Fundo (Full Cover)
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Container(color: Colors.grey[900]),
            ),

            // 2. Gradiente Preto na parte inferior (para legibilidade)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120, // Altura do gradiente
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Texto sobreposto (Título e Subtítulo)
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 10, // Fonte menor e mais leve
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 4. Overlay de Seleção (Opcional)
            if (isSelected)
              Container(
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
          ],
        ),
      ),
    );
  }
}
