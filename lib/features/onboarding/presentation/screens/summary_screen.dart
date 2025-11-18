import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'notifications_screen.dart'; // Próxima tela

// ---
// IMPORTS V3 (Fundação e Novos Widgets)
// ---
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import '../../domain/onboarding_data_model.dart';
import '../widgets/premium_selection_card.dart'; // V3 (PONTO 14)
import '../widgets/premium_progress_bar.dart'; // V3 (PONTO 3)

// ---
// IMPORTS V3 (Telas de Edição - PONTO 14)
// (Usaremos os widgets *destas* telas nos modais)
// ---
import 'vital_data_screen.dart'; // Para Idade, Peso, Gênero
import 'objective_screen.dart'; // Para Objetivo
import 'experience_screen.dart'; // Para Nível Físico
import 'schedule_screen.dart'; // Para Frequência
import 'equipment_screen.dart'; // Para Local
import 'injuries_screen.dart'; // Para Lesões
import 'cardio_screen.dart'; // Para Cardio

/// Tela 1.19: O "Hub de Revisão" V3 (Lógica V3).
/// V3 (SPRINT 2/3): Refatorada para corrigir erros de compilação
/// e implementar a edição em Modal (PONTO 14).
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('summary');
    });
  }

  // ---
  // V3 (PONTO 14): NOVA LÓGICA DE EDIÇÃO EM MODAL
  // ---
  Future<void> _showEditModal(BuildContext context,
      {required String title, required Widget child}) async {
    HapticService.lightImpact();

    // V3 (PONTO 18): Reutiliza o estilo do modal de 'vital_data_screen'
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        // Usa StatefulBuilder para que o modal possa ter seu próprio estado
        // (ex: para o editor de texto de lesões)
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return Container(
              // Altura dinâmica baseada no conteúdo
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Encolhe para o conteúdo
                children: [
                  // Header do Modal (Título e Botão "OK")
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: theme.textTheme.headlineSmall),
                        GestureDetector(
                          onTap: () {
                            HapticService.lightImpact();
                            Navigator.of(modalContext).pop();
                          },
                          child: Text(
                            "OK", // V3 (PONTO 18b)
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // V3 (PONTO 15): Garante que o conteúdo do modal seja rolável
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                      // V3: Passa o 'stfSetState' para os editores que precisam
                      // (como o editor de texto de lesões)
                      child: Provider.value(
                        value: context.read<OnboardingProvider>(),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// V3: Navegação FINAL
  void _onNext(BuildContext context) {
    HapticService.mediumImpact();
    context
        .read<AnalyticsService>()
        .trackEvent('summary_continue_to_notifications');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(), // 1.20
      ),
    );
  }

  // ---
  // V3: Helpers de Formatação (CORRIGIDOS para o Sprint 1)
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

  // V3 (CORRIGIDO - Ponto 6)
  String _formatSchedule(OnboardingDataModel data) {
    if (data.scheduleMode == 'days_of_week') {
      return "${data.scheduleDaysOfWeek.length} dias (Fixo)";
    }
    if (data.scheduleMode == 'times_per_week') {
      return "${data.scheduleTimesPerWeek ?? 'N/D'} vezes (Smart)";
    }
    return 'N/D';
  }

  String _formatInjury(bool hasInjury) {
    return hasInjury ? 'Sim (Detalhado)' : 'Sem lesões';
  }

  // V3 (NOVO - Ponto 9)
  String _formatCardio(OnboardingDataModel data) {
    switch (data.cardioPreference) {
      case 'sim':
        return data.cardioType ?? 'N/D';
      case 'nao':
        return 'Não';
      case 'ia_decide':
        return 'IA Decide';
      default:
        return 'N/D';
    }
  }

  @override
  Widget build(BuildContext context) {
    // V3: Lógica 1 (Dados Reais)
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final data = provider.data;
        final name = data.name ?? "Viajante";

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Navigator.canPop(context) ? const BackButton() : null,
          ),
          // V3 (PONTO 15): Adiciona SingleChildScrollView
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(name: name),
                _SummaryCard(
                  data: data,
                  onNavigate: _showEditModal,
                  // Passa os formatters V3
                  formatObjective: _formatObjective,
                  formatExperience: _formatExperience,
                  formatGender: _formatGender,
                  formatEquipment: _formatEquipment,
                  formatSchedule: _formatSchedule,
                  formatInjury: _formatInjury,
                  formatCardio: _formatCardio, // V3: Novo
                ),
                _PersonalizedSection(),

                const SizedBox(height: 40),
                // V3 (PONTO 15): Botão dentro do scroll
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ElevatedButton(
                    onPressed: () => _onNext(context),
                    child: const Text('Confirmar e Continuar'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---
// V3: Widgets Helpers (Layout)
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
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}

/// V3 (CORRIGIDO): O Card "É tudo sobre você" (O Hub Interativo)
class _SummaryCard extends StatelessWidget {
  final OnboardingDataModel data;
  final Function(BuildContext, {required String title, required Widget child})
      onNavigate;
  // Formatters
  final String Function(String?) formatObjective;
  final String Function(String?) formatExperience;
  final String Function(String?) formatGender;
  final String Function(String?) formatEquipment;
  final String Function(OnboardingDataModel) formatSchedule;
  final String Function(bool) formatInjury;
  final String Function(OnboardingDataModel) formatCardio; // V3 (NOVO)

  const _SummaryCard({
    required this.data,
    required this.onNavigate,
    required this.formatObjective,
    required this.formatExperience,
    required this.formatGender,
    required this.formatEquipment,
    required this.formatSchedule,
    required this.formatInjury,
    required this.formatCardio, // V3 (NOVO)
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<OnboardingProvider>(); // Para os editores

    return Container(
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "É tudo sobre você",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              // V3 (PONTO 14): Lógica de Edição em Modal
              _SummaryItem(
                title: 'Objetivo',
                value: formatObjective(data.objective),
                onTap: () => onNavigate(context,
                    title: "Editar Objetivo",
                    child: _buildObjectiveEditor(provider)),
              ),
              _SummaryItem(
                title: 'Nível Físico',
                value: formatExperience(data.experienceLevel),
                onTap: () => onNavigate(context,
                    title: "Editar Nível",
                    child: _buildExperienceEditor(provider)),
              ),
              _SummaryItem(
                title: 'Agenda', // V3 (CORRIGIDO)
                value: formatSchedule(data),
                onTap: () => onNavigate(context,
                    title: "Editar Agenda",
                    child: _buildScheduleEditor(provider)),
              ),
              _SummaryItem(
                title: 'Cardio', // V3 (CORRIGIDO)
                value: formatCardio(data),
                onTap: () => onNavigate(context,
                    title: "Editar Cardio",
                    child: _buildCardioEditor(provider)),
              ),
              _SummaryItem(
                title: 'Equipamento',
                value: formatEquipment(data.equipmentLocation),
                onTap: () => onNavigate(context,
                    title: "Editar Equipamento",
                    child: _buildEquipmentEditor(provider)),
              ),
              _SummaryItem(
                title: 'Lesões',
                value: formatInjury(data.hasInjury),
                onTap: () => onNavigate(context,
                    title: "Editar Lesões",
                    child: _buildInjuriesEditor(provider)),
              ),
              _SummaryItem(
                title: 'Peso Atual',
                value: "${data.currentWeight?.toStringAsFixed(1) ?? 'N/D'} kg",
                onTap: () => onNavigate(context,
                    title: "Editar Peso",
                    child: _buildVitalsEditor(provider, 'weight')),
              ),
              _SummaryItem(
                title: 'Gênero',
                value: formatGender(data.gender),
                onTap: () => onNavigate(context,
                    title: "Editar Gênero",
                    child: _buildVitalsEditor(provider, 'gender')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---
  // V3 (PONTO 14): WIDGETS DE EDIÇÃO PARA OS MODAIS
  // ---

  // Editor de Objetivo
  Widget _buildObjectiveEditor(OnboardingProvider provider) {
    return Column(
      children: [
        PremiumSelectionCard(
          text: 'Perder Gordura',
          isSelected: provider.data.objective == 'perder_gordura',
          onTap: () => provider.setObjective('perder_gordura'),
        ),
        const SizedBox(height: 12),
        PremiumSelectionCard(
          text: 'Manter/Saúde',
          isSelected: provider.data.objective == 'manter_saude',
          onTap: () => provider.setObjective('manter_saude'),
        ),
        const SizedBox(height: 12),
        PremiumSelectionCard(
          text: 'Ganhar Músculo',
          isSelected: provider.data.objective == 'ganhar_musculo',
          onTap: () => provider.setObjective('ganhar_musculo'),
        ),
      ],
    );
  }

  // Editor de Experiência
  Widget _buildExperienceEditor(OnboardingProvider provider) {
    return Column(
      children: [
        PremiumSelectionCard(
          text: 'Sou novo no fitness',
          isSelected: provider.data.experienceLevel == 'iniciante',
          onTap: () => provider.setExperienceLevel('iniciante'),
        ),
        const SizedBox(height: 12),
        PremiumSelectionCard(
          text: 'Eu malho de vez em quando',
          isSelected: provider.data.experienceLevel == 'intermediario',
          onTap: () => provider.setExperienceLevel('intermediario'),
        ),
        const SizedBox(height: 12),
        PremiumSelectionCard(
          text: 'Eu me exercito regularmente',
          isSelected: provider.data.experienceLevel == 'avancado',
          onTap: () => provider.setExperienceLevel('avancado'),
        ),
      ],
    );
  }

  // V3: Os editores de Agenda e Cardio são complexos,
  // então eles precisam ser StatefulWidgets
  Widget _buildScheduleEditor(OnboardingProvider provider) {
    // Reutiliza a tela original como um widget
    return const ScheduleScreen();
  }

  Widget _buildCardioEditor(OnboardingProvider provider) {
    // Reutiliza a tela original como um widget
    return const CardioScreen();
  }

  Widget _buildEquipmentEditor(OnboardingProvider provider) {
    // Reutiliza a tela original como um widget
    return const EquipmentScreen();
  }

  Widget _buildInjuriesEditor(OnboardingProvider provider) {
    // Reutiliza a tela original como um widget
    return const InjuriesScreen();
  }

  Widget _buildVitalsEditor(OnboardingProvider provider, String vital) {
    // Reutiliza a tela original como um widget
    // Idealmente, criaríamos pickers aqui, mas por simplicidade,
    // reutilizar a tela inteira é o mais rápido.
    return const VitalDataScreen();
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          // V3 (PONTO 5): Alinhado à esquerda
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value,
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personalizado",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/hero_image.png',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
