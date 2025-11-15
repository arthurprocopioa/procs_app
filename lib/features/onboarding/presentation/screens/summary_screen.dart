import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notifications_screen.dart'; // 1. CORREÇÃO V3 (Navega para 1.20)

// ---
// IMPORTS V3 (Fundação)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../../domain/onboarding_data_model.dart';

// ---
// IMPORTS V3 (Telas de Edição)
// ---
import 'vital_data_screen.dart'; // Para Idade, Peso, Gênero
import 'objective_screen.dart'; // Para Objetivo
import 'experience_screen.dart'; // Para Nível Físico
// Para Cardio
import 'injuries_screen.dart'; // Para Lesões
// Para Meta de Peso
import 'schedule_screen.dart'; // Para Frequência
import 'equipment_screen.dart'; // Para Local

/// Tela 1.19: O "Hub de Revisão" V3 (Lógica V3).
/// (Descarta 100% o V1 Estático)
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  void initState() {
    super.initState();
    // V3: Analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('summary');
    });
  }

  /// V3: Helper de Navegação (Lógica de Edição)
  void _navigateTo(BuildContext context, Widget screen) {
    // V3: Haptics
    HapticService.lightImpact();

    // V3: Analytics (Qual item o usuário quer editar?)
    context.read<AnalyticsService>().trackEvent(
      'summary_edit_tap',
      parameters: {'edit_screen': screen.runtimeType.toString()},
    );

    // V3: Navega (push), permitindo que o usuário volte (pop)
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// V3: Helper de Navegação FINAL
  void _onNext(BuildContext context) {
    // V3: Haptics
    HapticService.mediumImpact();

    // V3: Analytics
    context
        .read<AnalyticsService>()
        .trackEvent('summary_continue_to_notifications');

    // 2. CORREÇÃO V3 (Navega para 1.20)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  // ---
  // V3: Helpers de Formatação (Para "Data Gold" da IA)
  // ---
  String _formatObjective(String? key) {
    const map = {
      'perder_gordura': 'Perder Gordura',
      'manter_saude': 'Manter/Saúde',
      'ganhar_musculo': 'Ganhar Músculo'
    };
    return map[key] ?? 'N/D';
  }

  String _formatExperience(String? key) {
    const map = {
      'iniciante': 'Iniciante',
      'intermediario': 'Intermediário',
      'avancado': 'Avançado'
    };
    return map[key] ?? 'N/D';
  }

  String _formatGender(String? key) {
    const map = {'male': 'Masculino', 'female': 'Feminino', 'other': 'Outro'};
    return map[key] ?? 'N/D';
  }

  String _formatEquipment(String? key) {
    const map = {
      'academia': 'Academia',
      'casa_sem': 'Casa (sem equip.)',
      'casa_com': 'Casa (com equip.)'
    };
    return map[key] ?? 'N/D';
  }

  String _formatSchedule(OnboardingDataModel data) {
    if (data.schedulingMode == 'fixed') {
      return "${data.fixedDays.length} dias (Fixo)";
    }
    return "${data.smartFrequency ?? 'N/D'} dias (Smart)";
  }

  String _formatInjury(bool hasInjury) {
    return hasInjury ? 'Sim (Detalhado)' : 'Sem lesões';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // V3: Lógica 1 (Dados Reais)
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final data = provider.data;
        final name = data.name ?? "Viajante";

        return Scaffold(
          // 1. AppBar V3 (Sem progresso, V1 mantido)
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Navigator.canPop(context) ? const BackButton() : null,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 2. Header V3 (Baseado na Referência V3)
                      _Header(name: name),

                      // 3. O "Hub" V3 (Lógica 2: Edição)
                      _SummaryCard(
                        data: data,
                        onNavigate: _navigateTo,
                        // Passa os formatters V3
                        formatObjective: _formatObjective,
                        formatExperience: _formatExperience,
                        formatGender: _formatGender,
                        formatEquipment: _formatEquipment,
                        formatSchedule: _formatSchedule,
                        formatInjury: _formatInjury,
                      ),

                      // 4. Seção "Personalizado" (UI V3 da Referência)
                      _PersonalizedSection(theme: theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 3. CORREÇÃO V3 (Layout V3 Padrão)
          // (Botão no Bottom, não na imagem)
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: ElevatedButton(
              onPressed: () => _onNext(context),
              child: const Text('Confirmar e Continuar'),
            ),
          ),
        );
      },
    );
  }
}

// ---
// V3: Widgets Helpers (Criados do Zero)
// ---

/// V3: O Título (Ex: "Arthur, seu plano está pronto!")
class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        "$name, seu plano está pronto!",
        // V3: Tema
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}

/// V3: O Card "É tudo sobre você" (O Hub Interativo)
class _SummaryCard extends StatelessWidget {
  final OnboardingDataModel data;
  final Function(BuildContext, Widget) onNavigate;
  // Formatters
  final String Function(String?) formatObjective;
  final String Function(String?) formatExperience;
  final String Function(String?) formatGender;
  final String Function(String?) formatEquipment;
  final String Function(OnboardingDataModel) formatSchedule;
  final String Function(bool) formatInjury;

  const _SummaryCard({
    required this.data,
    required this.onNavigate,
    required this.formatObjective,
    required this.formatExperience,
    required this.formatGender,
    required this.formatEquipment,
    required this.formatSchedule,
    required this.formatInjury,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
      // V3: Tema (Usa o CardTheme V3)
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20), // V3: Mais arredondado
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "É tudo sobre você",
            // V3: Tema
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // V3: Grid 2xN (Baseado na Referência V3)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5, // Ajusta a altura
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              // V3: Lógica de Edição (Item 1)
              _SummaryItem(
                title: 'Objetivo',
                value: formatObjective(data.objective),
                onTap: () => onNavigate(context, const ObjectiveScreen()),
              ),
              // V3: Lógica de Edição (Item 2)
              _SummaryItem(
                title: 'Idade',
                value: "${data.age ?? 'N/D'} anos",
                onTap: () => onNavigate(context, const VitalDataScreen()),
              ),
              // V3: Lógica de Edição (Item 3)
              _SummaryItem(
                title: 'Nível Físico',
                value: formatExperience(data.experienceLevel),
                onTap: () => onNavigate(context, const ExperienceScreen()),
              ),
              // V3: Lógica de Edição (Item 4)
              _SummaryItem(
                title: 'Gênero',
                value: formatGender(data.gender),
                onTap: () => onNavigate(context, const VitalDataScreen()),
              ),
              // V3: Lógica de Edição (Item 5)
              _SummaryItem(
                title: 'Peso Atual',
                value: "${data.currentWeight?.toStringAsFixed(1) ?? 'N/D'} kg",
                onTap: () => onNavigate(context, const VitalDataScreen()),
              ),
              // V3: Lógica de Edição (Item 6)
              _SummaryItem(
                title: 'Equipamento',
                value: formatEquipment(data.equipmentLocation),
                onTap: () => onNavigate(context, const EquipmentScreen()),
              ),
              // V3: Lógica de Edição (Item 7)
              _SummaryItem(
                title: 'Frequência',
                value: formatSchedule(data),
                onTap: () => onNavigate(context, const ScheduleScreen()),
              ),
              // V3: Lógica de Edição (Item 8)
              _SummaryItem(
                title: 'Lesões',
                value: formatInjury(data.hasInjury),
                onTap: () => onNavigate(context, const InjuriesScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// V3: O item individual (Ex: "Objetivo: Ganhar Músculo")
class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // V3: Lógica 2 (Edição)
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              // V3: Tema (Cor Secundária)
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              // V3: Tema (Cor Primária)
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// V3: A Seção "Personalizado" (UI da Referência V3)
class _PersonalizedSection extends StatelessWidget {
  final ThemeData theme;

  const _PersonalizedSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personalizado",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // V3: Stack (Imagem)
          Stack(
            children: [
              // V3: Imagem (Usando o 'hero_image.png' V1 como placeholder)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/hero_image.png',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // V3: Fade (Opcional, pois o botão saiu)
                  // color: Colors.black.withOpacity(0.1),
                  // colorBlendMode: BlendMode.darken,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
