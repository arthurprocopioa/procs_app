import 'dart:ui'; // Para BackdropFilter
import 'package:flutter/cupertino.dart'; // Para CupertinoDatePicker
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../application/onboarding_provider.dart';
import 'commitment_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Estado Visual
  bool _showOverlay = true; // Começa com o overlay de decisão
  bool _showConfig = false; // Configuração só aparece após ativar

  // Estado local para as configurações
  Map<String, TimeOfDay> _trainingSchedule = {};
  Map<String, TimeOfDay> _cardioSchedule = {};
  Map<int, TimeOfDay> _mealSchedule = {};

  // Estado para Compras (Mensal)
  int _groceryFrequency = 1; // Quantas vezes por mês
  List<int> _groceryDays = []; // Dias do mês (1-31)
  // Nota: Horário de compras removido por simplificação, será salvo um padrão.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsService>(context, listen: false)
          .trackScreenView('notifications');
    });
  }

  Future<void> _onActivate() async {
    HapticService.heavyImpact();
    final provider = context.read<OnboardingProvider>();

    try {
      final messaging = FirebaseMessaging.instance;
      // Solicita permissão
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        provider.setNotificationsEnabled(true);
        setState(() {
          _showOverlay = false;
          _showConfig = true;
        });
      } else {
        // Se negou, seguimos sem configurar (ou avisamos)
        _onSkip();
      }
    } catch (e) {
      debugPrint("Erro ao pedir notificação: $e");
      _onSkip();
    }
  }

  void _onSkip() {
    HapticService.lightImpact();
    final provider = context.read<OnboardingProvider>();
    provider.setNotificationsEnabled(false);
    _navigateToNext();
  }

  void _navigateToNext() {
    // Salvar configurações no Provider antes de ir
    if (_showConfig) {
      _saveConfigurations();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CommitmentScreen()),
    );
  }

  void _saveConfigurations() {
    final provider = context.read<OnboardingProvider>();

    // Converter TimeOfDay para String "HH:mm"
    final trainingMap = _trainingSchedule
        .map((key, value) => MapEntry(key, '${value.hour}:${value.minute}'));
    provider.setTrainingNotificationSchedule(trainingMap);

    final cardioMap = _cardioSchedule
        .map((key, value) => MapEntry(key, '${value.hour}:${value.minute}'));
    provider.setCardioNotificationSchedule(cardioMap);

    final mealList = _mealSchedule.entries
        .toList()
        .map((e) => '${e.value.hour}:${e.value.minute}')
        .toList();
    provider.setMealNotificationSchedule(mealList);

    // Salvar compras (Dia do Mês -> Horário Padrão 09:00)
    provider.setGroceryShoppingFrequency(_groceryFrequency);
    final groceryMap = <int, String>{};
    for (int i = 0; i < _groceryDays.length; i++) {
      final day = _groceryDays[i];
      // Horário fixo conforme solicitado para simplificação
      groceryMap[day] = '09:00';
    }
    provider.setGroceryNotificationSchedule(groceryMap);
  }

  // --- MODAIS DE CONFIGURAÇÃO ---

  void _configureTraining(int timesPerWeek) {
    HapticService.lightImpact();
    final provider = context.read<OnboardingProvider>();
    final selectedDays = provider.data.selectedTrainingDays.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DayTimeSelectorModal(
        title: "Agenda de Treino",
        subtitle: "Defina o horário para os seus dias de treino.",
        maxDays: timesPerWeek,
        fixedDays: selectedDays, // NOVO: Dias fixos vindos da ScheduleScreen
        initialSchedule: _trainingSchedule,
        onSave: (schedule) {
          setState(() {
            _trainingSchedule = schedule;
          });
        },
      ),
    );
  }

  void _configureCardio(int timesPerWeek) {
    HapticService.lightImpact();
    final provider = context.read<OnboardingProvider>();
    // Safe access for Hot Reload support
    final rawDays = provider.data.selectedCardioDays as dynamic;
    final selectedDays =
        rawDays != null ? (rawDays as Set<String>).toList() : <String>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DayTimeSelectorModal(
        title: "Agenda de Cardio",
        subtitle: "Defina o horário para os seus dias de cardio.",
        maxDays: timesPerWeek,
        fixedDays: selectedDays, // NOVO: Dias fixos vindos da CardioScreen
        initialSchedule: _cardioSchedule,
        onSave: (schedule) {
          setState(() {
            _cardioSchedule = schedule;
          });
        },
      ),
    );
  }

  void _configureMeals(int mealCount) {
    HapticService.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MealTimeSelectorModal(
        mealCount: mealCount,
        initialSchedule: _mealSchedule,
        onSave: (schedule) {
          setState(() {
            _mealSchedule = schedule;
          });
        },
      ),
    );
  }

  void _configureGrocery() {
    HapticService.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GroceryPlanningModal(
        initialFrequency: _groceryFrequency,
        initialDays: _groceryDays,
        onSave: (freq, days) {
          setState(() {
            _groceryFrequency = freq;
            _groceryDays = days;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;

    // Validação para habilitar botão de continuar
    bool isConfigValid = true;
    if (_showConfig) {
      if ((data.scheduleTimesPerWeek ?? 0) > 0 &&
          _trainingSchedule.length != data.scheduleTimesPerWeek) {
        isConfigValid = false;
      }
      if (data.cardioPreference == 'sim' &&
          (data.cardioTimesPerWeek ?? 0) > 0 &&
          _cardioSchedule.length != data.cardioTimesPerWeek) {
        isConfigValid = false;
      }
      if ((data.mealCount ?? 0) > 0 && _mealSchedule.length != data.mealCount) {
        isConfigValid = false;
      }
      // Validação de compras: deve ter selecionado os dias conforme a frequência
      if (_groceryDays.length != _groceryFrequency) {
        isConfigValid = false;
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // CAMADA 1: CONTEÚDO DE CONFIGURAÇÃO (Fundo)
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32), // Mais espaço topo
                        Text(
                          "Configure sua Rotina",
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Defina seus horários agora para a IA otimizar seu cronograma.",
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),

                        // 1. TREINO
                        if (data.scheduleTimesPerWeek != null)
                          _NotificationConfigCard(
                            title: "Treino de Musculação",
                            subtitle: "Configure o dia e horário de treino",
                            statusText:
                                "${_trainingSchedule.length}/${data.scheduleTimesPerWeek} dias definidos",
                            icon: Icons.fitness_center,
                            onTap: () =>
                                _configureTraining(data.scheduleTimesPerWeek!),
                            isConfigured: _trainingSchedule.length ==
                                data.scheduleTimesPerWeek,
                          ),

                        // 2. CARDIO
                        if (data.cardioPreference == 'sim' &&
                            data.cardioTimesPerWeek != null)
                          _NotificationConfigCard(
                            title: "Sessões de Cardio",
                            subtitle: "Configure o dia e horário de cardio",
                            statusText:
                                "${_cardioSchedule.length}/${data.cardioTimesPerWeek} dias definidos",
                            icon: Icons.directions_run,
                            onTap: () =>
                                _configureCardio(data.cardioTimesPerWeek!),
                            isConfigured: _cardioSchedule.length ==
                                data.cardioTimesPerWeek,
                          ),

                        // 3. REFEIÇÕES
                        if (data.mealCount != null)
                          _NotificationConfigCard(
                            title: "Horários das Refeições",
                            subtitle:
                                "Configure os horários das suas refeições",
                            statusText:
                                "${_mealSchedule.length}/${data.mealCount} refeições definidas",
                            icon: Icons.restaurant,
                            onTap: () => _configureMeals(data.mealCount!),
                            isConfigured:
                                _mealSchedule.length == data.mealCount,
                          ),

                        // 4. COMPRAS
                        _NotificationConfigCard(
                          title: "Compras de Mercado",
                          subtitle:
                              "Configure os dias e horários da sua compra para garantir que você conseguirá manter a dieta",
                          statusText: _groceryDays.isEmpty
                              ? "Toque para configurar"
                              : "${_groceryDays.length} dias planejados",
                          icon: Icons.shopping_cart,
                          onTap: _configureGrocery,
                          isConfigured: _groceryDays.isNotEmpty &&
                              _groceryDays.length == _groceryFrequency,
                        ),
                        const SizedBox(height: 100), // Espaço para o botão
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CAMADA 2: BOTÃO DE CONFIRMAÇÃO (Só aparece se _showConfig = true)
          if (_showConfig)
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: isConfigValid ? _navigateToNext : null,
                child: const Text('Confirmar Agenda'),
              ),
            ),

          // CAMADA 3: OVERLAY DE DECISÃO (Inicial)
          if (_showOverlay)
            Positioned.fill(
              child: Stack(
                children: [
                  // Blur Effect
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  // Card Central
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 64,
                            color: const Color(0xFFD4AF37), // Dourado
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Não deixe o acaso controlar sua rotina.",
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "O Procs AI é um sistema ativo. Ative para receber lembretes de treino, cardio e dieta exatamente quando precisa.",
                            style: textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onActivate,
                              child: const Text("Ativar Sistema"),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _onSkip,
                            child: Text(
                              "Agora não",
                              style: TextStyle(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _NotificationConfigCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusText;
  final IconData icon;
  final VoidCallback onTap;
  final bool isConfigured;

  const _NotificationConfigCard({
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.icon,
    required this.onTap,
    required this.isConfigured,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isConfigured ? colorScheme.primary : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isConfigured
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // REMOVIDO: Icon(Icons.check)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MODAL: SELETOR DE DIAS E HORAS (PREMIUM) ---

class _DayTimeSelectorModal extends StatefulWidget {
  final String title;
  final String subtitle;
  final int maxDays;
  final List<String>? fixedDays; // NOVO
  final Map<String, TimeOfDay> initialSchedule;
  final Function(Map<String, TimeOfDay>) onSave;

  const _DayTimeSelectorModal({
    required this.title,
    required this.subtitle,
    required this.maxDays,
    this.fixedDays, // NOVO
    required this.initialSchedule,
    required this.onSave,
  });

  @override
  State<_DayTimeSelectorModal> createState() => _DayTimeSelectorModalState();
}

class _DayTimeSelectorModalState extends State<_DayTimeSelectorModal> {
  late Map<String, TimeOfDay> _schedule;
  String? _expandedDay; // Qual dia está com o picker aberto

  // Mapa de tradução (Chave -> Label)
  final Map<String, String> _dayLabels = {
    'monday': 'Segunda-feira',
    'tuesday': 'Terça-feira',
    'wednesday': 'Quarta-feira',
    'thursday': 'Quinta-feira',
    'friday': 'Sexta-feira',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  // Lista de chaves ordenada
  final List<String> _allDayKeys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  @override
  void initState() {
    super.initState();
    _schedule = Map.from(widget.initialSchedule);

    // Se tiver dias fixos, garante que eles estejam no schedule
    if (widget.fixedDays != null) {
      for (final dayKey in widget.fixedDays!) {
        if (!_schedule.containsKey(dayKey)) {
          _schedule[dayKey] = const TimeOfDay(hour: 7, minute: 0);
        }
      }
      // Remove dias que não estão nos fixos (caso tenha mudado)
      _schedule.removeWhere((key, value) => !widget.fixedDays!.contains(key));
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (_expandedDay == day) {
        // Se clicar no mesmo, fecha
        _expandedDay = null;
      } else {
        // Abre este dia
        _expandedDay = day;
        // Se ainda não tem horário, define um default
        if (!_schedule.containsKey(day)) {
          if (_schedule.length < widget.maxDays) {
            _schedule[day] = const TimeOfDay(hour: 7, minute: 0);
          } else {
            _expandedDay = null; // Cancela abertura se limite atingido
          }
        }
      }
    });
  }

  void _removeDay(String day) {
    setState(() {
      _schedule.remove(day);
      if (_expandedDay == day) _expandedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: theme.textTheme.headlineSmall),
                      Text(widget.subtitle, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          // Lista de Dias
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              // Se tiver dias fixos, usa eles. Se não, usa todos.
              itemCount: widget.fixedDays?.length ?? _allDayKeys.length,
              itemBuilder: (context, index) {
                // Determina qual dia mostrar
                final dayKey = widget.fixedDays != null
                    ? widget.fixedDays![index]
                    : _allDayKeys[index];

                final label = _dayLabels[dayKey] ?? dayKey;
                final isSelected = _schedule.containsKey(dayKey);
                final isExpanded = _expandedDay == dayKey;
                final time = _schedule[dayKey];

                return Column(
                  children: [
                    ListTile(
                      title: Text(label),
                      trailing: isSelected
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${time!.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Só mostra botão de remover se NÃO for fixo
                                if (widget.fixedDays == null)
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () => _removeDay(dayKey),
                                  ),
                              ],
                            )
                          : const Icon(Icons.circle_outlined),
                      // Se for fixo, o tap apenas expande (não seleciona/deseleciona)
                      // Mas como ele já vem selecionado do initState, o tap vai expandir.
                      onTap: () => _toggleDay(dayKey),
                      selected: isSelected,
                    ),
                    // PREMIUM TIME PICKER EMBEDDED
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: isExpanded && time != null
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: theme.cardTheme.color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 150,
                                    child: CupertinoTheme(
                                      data: CupertinoThemeData(
                                        brightness: Brightness.dark,
                                        textTheme: CupertinoTextThemeData(
                                          dateTimePickerTextStyle: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.time,
                                        use24hFormat: true,
                                        initialDateTime: DateTime(
                                            2024, 1, 1, time.hour, time.minute),
                                        onDateTimeChanged: (DateTime newTime) {
                                          setState(() {
                                            _schedule[dayKey] = TimeOfDay(
                                                hour: newTime.hour,
                                                minute: newTime.minute);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  // BOTÃO CONFIRMAR
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              theme.colorScheme.surface,
                                          foregroundColor:
                                              theme.colorScheme.onSurface,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _expandedDay = null;
                                          });
                                        },
                                        child: const Text("Confirmar"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                );
              },
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_schedule);
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }
}

// --- MODAL: SELETOR DE REFEIÇÕES (PREMIUM) ---

class _MealTimeSelectorModal extends StatefulWidget {
  final int mealCount;
  final Map<int, TimeOfDay> initialSchedule;
  final Function(Map<int, TimeOfDay>) onSave;

  const _MealTimeSelectorModal({
    required this.mealCount,
    required this.initialSchedule,
    required this.onSave,
  });

  @override
  State<_MealTimeSelectorModal> createState() => _MealTimeSelectorModalState();
}

class _MealTimeSelectorModalState extends State<_MealTimeSelectorModal> {
  late Map<int, TimeOfDay> _schedule;
  int? _expandedMealIndex;

  @override
  void initState() {
    super.initState();
    _schedule = Map.from(widget.initialSchedule);
  }

  void _toggleMeal(int index) {
    setState(() {
      if (_expandedMealIndex == index) {
        _expandedMealIndex = null;
      } else {
        _expandedMealIndex = index;
        if (!_schedule.containsKey(index)) {
          _schedule[index] = TimeOfDay(hour: 8 + (index * 3), minute: 0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text("Horários das Refeições",
                style: theme.textTheme.headlineSmall),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: widget.mealCount,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mealNum = index + 1;
                final time = _schedule[index];
                final isExpanded = _expandedMealIndex == index;

                return Column(
                  children: [
                    ListTile(
                      tileColor: theme.cardTheme.color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      title: Text("Refeição $mealNum"),
                      trailing: time != null
                          ? Text(
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: theme.colorScheme.primary),
                            )
                          : const Text("Definir horário"),
                      onTap: () => _toggleMeal(index),
                    ),
                    // PREMIUM TIME PICKER EMBEDDED
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: isExpanded && time != null
                          ? Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color:
                                    (theme.cardTheme.color ?? theme.cardColor)
                                        .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 150,
                                    child: CupertinoTheme(
                                      data: CupertinoThemeData(
                                        brightness: Brightness.dark,
                                        textTheme: CupertinoTextThemeData(
                                          dateTimePickerTextStyle: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.time,
                                        use24hFormat: true,
                                        initialDateTime: DateTime(
                                            2024, 1, 1, time.hour, time.minute),
                                        onDateTimeChanged: (DateTime newTime) {
                                          setState(() {
                                            _schedule[index] = TimeOfDay(
                                                hour: newTime.hour,
                                                minute: newTime.minute);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  // BOTÃO CONFIRMAR
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              theme.colorScheme.surface,
                                          foregroundColor:
                                              theme.colorScheme.onSurface,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _expandedMealIndex = null;
                                          });
                                        },
                                        child: const Text("Confirmar"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_schedule);
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }
}

// --- MODAL: PLANEJAMENTO DE MERCADO (MENSAL) ---

class _GroceryPlanningModal extends StatefulWidget {
  final int initialFrequency;
  final List<int> initialDays;
  final Function(int, List<int>) onSave;

  const _GroceryPlanningModal({
    required this.initialFrequency,
    required this.initialDays,
    required this.onSave,
  });

  @override
  State<_GroceryPlanningModal> createState() => _GroceryPlanningModalState();
}

class _GroceryPlanningModalState extends State<_GroceryPlanningModal> {
  late int _frequency;
  late List<int> _days;

  @override
  void initState() {
    super.initState();
    _frequency = widget.initialFrequency;
    _days = List.from(widget.initialDays);
  }

  void _incrementFrequency() {
    if (_frequency < 4) {
      setState(() {
        _frequency++;
      });
    }
  }

  void _decrementFrequency() {
    if (_frequency > 1) {
      setState(() {
        _frequency--;
        // Se diminuir, remove o último dia se houver excesso
        if (_days.length > _frequency) {
          _days.removeLast();
        }
      });
    }
  }

  Future<void> _pickDate(int index) async {
    final now = DateTime.now();
    // Data mínima:
    DateTime minDate = now;
    if (index > 0 && index - 1 < _days.length) {
      int prevDay = _days[index - 1];
      DateTime prevDate;
      if (prevDay >= now.day) {
        prevDate = DateTime(now.year, now.month, prevDay);
      } else {
        prevDate = DateTime(now.year, now.month + 1, prevDay);
      }
      minDate = prevDate.add(const Duration(days: 1));
    }

    DateTime initialDate = now;
    if (index < _days.length) {
      int day = _days[index];
      if (day >= now.day) {
        initialDate = DateTime(now.year, now.month, day);
      } else {
        initialDate = DateTime(now.year, now.month + 1, day);
      }
    }

    if (initialDate.isBefore(minDate)) {
      initialDate = minDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: now.add(const Duration(days: 60)),
      locale: const Locale('pt', 'BR'), // LOCALIZAÇÃO PT-BR
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFFD4AF37), // Dourado
                  onPrimary: Colors.black,
                  surface: const Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (index < _days.length) {
          _days[index] = picked.day;
        } else {
          _days.add(picked.day);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Compras de Mercado",
                          style: theme.textTheme.headlineSmall),
                      Text("Planejamento Mensal",
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),

          // Seletor de Frequência
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Frequência mensal:", style: theme.textTheme.titleMedium),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            theme.colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _decrementFrequency,
                        color: theme.colorScheme.primary,
                      ),
                      Text(
                        "$_frequency x",
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _incrementFrequency,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _frequency,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final shopNum = index + 1;
                final hasDay = index < _days.length;
                final day = hasDay ? _days[index] : null;

                return Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasDay
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: ListTile(
                    title: Text("Compra $shopNum"),
                    subtitle: hasDay
                        ? Text("Dia $day")
                        : const Text("Toque para agendar"),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(index),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () {
                // Validação simples: todos os dias devem estar preenchidos
                if (_days.length == _frequency) {
                  widget.onSave(_frequency, _days);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Por favor, selecione todas as datas.")),
                  );
                }
              },
              child: const Text('Salvar Planejamento'),
            ),
          ),
        ],
      ),
    );
  }
}
