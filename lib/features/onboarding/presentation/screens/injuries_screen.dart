import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cardio_screen.dart'; // Próxima tela (1.12)
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';

/// Tela 1.11: Onde o usuário informa sobre lesões (Lógica V3).
/// Refatorada para usar a Fundação V3 e a lógica de "Data Ouro" (Texto Extenso).
class InjuriesScreen extends StatefulWidget {
  const InjuriesScreen({super.key});

  @override
  State<InjuriesScreen> createState() => _InjuriesScreenState();
}

class _InjuriesScreenState extends State<InjuriesScreen> {
  // --- ESTADO LOCAL (V3) ---

  // 1. Controla a seleção primária (Sim/Não)
  // (Mantém a lógica V1 de estado local para UI)
  bool? _hasInjury;

  // 2. Controla o TextField "Data Ouro" (V3)
  late final TextEditingController _injuryController;

  @override
  void initState() {
    super.initState();
    // V3: Inicializa o estado local com os dados do Provider
    final providerData = context.read<OnboardingProvider>().data;
    _hasInjury = providerData.hasInjury;
    _injuryController = TextEditingController(text: providerData.injuryDetails);

    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('injuries');
    });
  }

  @override
  void dispose() {
    _injuryController.dispose();
    super.dispose();
  }

  // --- AÇÕES V3 ---

  void _onNext() {
    // Lógica V1 mantida: Só avança se a seleção primária estiver feita
    if (_hasInjury == null) return;

    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Implementa o TODO (Salva o "Data Ouro")
    final provider = context.read<OnboardingProvider>();
    provider.setInjuryData(
      hasInjury: _hasInjury!,
      details: _hasInjury == true ? _injuryController.text.trim() : null,
    );

    // V3: Analytics
    context.read<AnalyticsService>().trackEvent(
      'onboarding_injury_set',
      parameters: {
        'has_injury': _hasInjury!,
        'details_length':
            _hasInjury == true ? _injuryController.text.trim().length : 0,
      },
    );

    // V3: Navegação
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const CardioScreen(), // Navega para 1.12
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Lógica V1 mantida
    final bool canContinue = _hasInjury != null;
    final bool showSubSelection = _hasInjury == true;

    return Scaffold(
      appBar: AppBar(
        // V3: Título do AppBar (Usa o Tema V3)
        title: Text(
          "Etapa 8 de 13",
          style: theme.appBarTheme.titleTextStyle,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 8 / 13,
            backgroundColor: theme.colorScheme.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // 4. Título (V3)
                  Text(
                    "Você tem algum histórico de lesão?",
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // 5. Parte 1: Seleção Primária (Sim/Não)
                  // (Refatorado para o padrão V3 de UI 'Cards')
                  _buildInjuryOptionCard('Sim', true),
                  const SizedBox(height: 16),
                  _buildInjuryOptionCard('Não', false),

                  // 6. Parte 2: Sub-Seleção (Lógica V3 - "Data Ouro")
                  AnimatedOpacity(
                    opacity: showSubSelection ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Visibility(
                      visible: showSubSelection,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          // Subtítulo V3
                          Text(
                            "Por favor, descreva sua(s) lesão(ões)",
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Quanto mais detalhes (o que, quando, limitações), melhor a IA poderá adaptar seu treino.",
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),

                          // TextField V3 (Data Ouro)
                          TextField(
                            controller: _injuryController,
                            decoration: const InputDecoration(
                              labelText: 'Descreva sua lesão aqui...',
                              // V3: Usa o Tema
                            ),
                            style: textTheme.bodyLarge,
                            maxLines: 5, // Permite mais texto
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 96), // Espaço para o botão
                ],
              ),
            ),
          ),
        ],
      ),
      // 7. Botão de Ação (Inferior Fixo - V3 UI)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: ElevatedButton(
          onPressed: canContinue ? _onNext : null,
          child: const Text('Continuar'),
        ),
      ),
    );
  }

  /// Helper V3: Constrói os cards de seleção (Sim/Não)
  Widget _buildInjuryOptionCard(String text, bool value) {
    final theme = Theme.of(context);
    final bool isSelected = _hasInjury == value;

    // V3: Estilo V3 (Baseado no `schedule_screen`)
    final Color bgColor =
        isSelected ? const Color(0xFF303030) : theme.cardTheme.color!;

    final Color fgColor =
        isSelected ? Colors.white : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: () {
          // V3: Haptics
          HapticService.lightImpact();
          setState(() {
            _hasInjury = value;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: fgColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
