import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../application/nutrition_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/providers/user_data_provider.dart';
import '../../domain/diet_models.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = context.watch<UserDataProvider>();
    final theme = Theme.of(context);

    if (userDataProvider.isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Se não tiver plano ainda
    if (!userDataProvider.hasDietPlan) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _buildLoadingState(theme),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => NutritionProvider(),
      child: const _NutritionView(),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            "A IA está montando sua dieta...",
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            "Isso pode levar alguns segundos.",
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _NutritionView extends StatefulWidget {
  const _NutritionView();

  @override
  State<_NutritionView> createState() => _NutritionViewState();
}

class _NutritionViewState extends State<_NutritionView>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = context.watch<UserDataProvider>();
    final dietPlan = userDataProvider.dietPlanObj;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userWeight = userDataProvider.userWeight;

    // Meta de água: 35ml por kg.
    // Se não vier do Firestore, usamos o cálculo padrão.
    final waterGoalLiters = (userWeight * 35) / 1000;

    // Fallback para Markdown se não tiver o objeto estruturado
    if (dietPlan == null) {
      return _buildMarkdownFallback(context, userDataProvider, theme);
    }

    // Inicializa TabController se necessário
    if (_tabController == null ||
        _tabController!.length != dietPlan.meals.length) {
      _tabController?.dispose();
      _tabController =
          TabController(length: dietPlan.meals.length, vsync: this);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // AppBar com Tabs
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Dieta Inteligente"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          splashFactory: NoSplash.splashFactory,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: dietPlan.meals.map((meal) => Tab(text: meal.name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: dietPlan.meals.asMap().entries.map((entry) {
          final index = entry.key;
          final meal = entry.value;
          return _buildMealPage(
              context, userDataProvider, index, meal, waterGoalLiters);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showShoppingList(context, userDataProvider),
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.shopping_cart, color: Colors.black),
        label: const Text("Lista de Compras",
            style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildMealPage(BuildContext context, UserDataProvider provider,
      int mealIndex, Meal meal, double waterGoalLiters) {
    final theme = Theme.of(context);
    final selectedOption = meal.options[meal.selectedOptionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget de Hidratação (Topo de cada aba para dar visibilidade)
          _buildHydrationCard(context, waterGoalLiters),
          const SizedBox(height: 24),

          // Seletor de Opções (Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: meal.options.asMap().entries.map((entry) {
                final optIndex = entry.key;
                final opt = entry.value;
                final isSelected = optIndex == meal.selectedOptionIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(opt.name), // "Opção 1"
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) provider.selectMealOption(mealIndex, optIndex);
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                    backgroundColor: Colors.white10,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Lista de Alimentos da Opção Selecionada
          ...selectedOption.items.map((item) {
            final isDisliked = provider.dislikedFoods.contains(item.name);
            final isFavorite = provider.favoriteFoods.contains(item.name);

            return Card(
              color: const Color(0xFF1A1A1A),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(item.name,
                    style: TextStyle(
                      color: isDisliked
                          ? Colors.red.withOpacity(0.5)
                          : Colors.white,
                      decoration:
                          isDisliked ? TextDecoration.lineThrough : null,
                    )),
                subtitle: Text("${item.portion} • ${item.prepMethod}",
                    style: const TextStyle(color: Colors.grey)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Like / Dislike
                    IconButton(
                      icon: Icon(
                        isDisliked
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                        color: isDisliked ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null)
                          provider.toggleFoodDislike(uid, item.name);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.pink : Colors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null)
                          provider.toggleFoodFavorite(uid, item.name);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 32),
          // Botão Aprovar esta opção para compras
          if (provider.dietPlanObj?.status != 'approved')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Aprovar Dieta e Gerar Lista"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    await provider.approveDietPlan(uid);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Dieta Aprovada! Lista gerada.")));
                      _showShoppingList(context, provider);
                    }
                  }
                },
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHydrationCard(BuildContext context, double waterGoalLiters) {
    // Usa o provider local de nutrição para o contador de copos (estado efêmero)
    // Idealmente, isso deveria persistir no Firestore também, mas por enquanto segue o padrão local.
    return Consumer<NutritionProvider>(builder: (context, provider, _) {
      final currentLiters = (provider.waterIntake * 0.25); // 250ml por copo
      final progress = (currentLiters / waterGoalLiters).clamp(0.0, 1.0);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.water_drop, color: Colors.blue),
                    SizedBox(width: 8),
                    Text("Hidratação Diária",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(
                    "${currentLiters.toStringAsFixed(1)} / ${waterGoalLiters.toStringAsFixed(1)} L",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: provider.removeWater,
                    icon: const Icon(Icons.remove, color: Colors.grey)),
                const SizedBox(width: 16),
                Text("${provider.waterIntake} copos (250ml)",
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(width: 16),
                IconButton(
                    onPressed: provider.addWater,
                    icon: const Icon(Icons.add, color: Colors.blue)),
              ],
            )
          ],
        ),
      );
    });
  }

  void _showShoppingList(BuildContext context, UserDataProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151515),
      builder: (ctx) {
        // Usa Consumer para reagir a mudanças locais na lista
        return Consumer<UserDataProvider>(builder: (context, provider, _) {
          final shoppingList = provider.shoppingList;

          if (shoppingList.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: 300,
              child: const Center(
                  child: Text(
                      "Sua lista de compras está vazia.\nAprove a dieta para gerar.")),
            );
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Lista de Compras",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: shoppingList.length,
                      itemBuilder: (ctx, index) {
                        final item = shoppingList[index];
                        final isChecked = item['isChecked'] ?? false;

                        return CheckboxListTile(
                          value: isChecked,
                          title: Text(item['name'],
                              style: TextStyle(
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isChecked ? Colors.grey : Colors.white,
                              )),
                          subtitle:
                              Text("${item['quantity']} (${item['category']})"),
                          activeColor: Colors.green,
                          onChanged: (val) {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid != null)
                              provider.toggleShoppingItem(uid, index);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        });
      },
    );
  }

  // Fallback para o Markdown Original
  Widget _buildMarkdownFallback(BuildContext context,
      UserDataProvider userDataProvider, ThemeData theme) {
    final provider = context.watch<NutritionProvider>();

    // Recalcula água corretamente aqui tb
    final userWeight = userDataProvider.userWeight;
    final waterGoal = (userWeight * 35); // ml
    final waterConsumedMl = (provider.waterIntake * 250); // ml

    return Scaffold(
      appBar: AppBar(title: const Text("Dieta")),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Text(
                  "⚠️ Visualizando modo legado (Markdown). Atualize o Agente IA para suportar o novo formato JSON.",
                  style: TextStyle(color: Colors.amber)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: MarkdownBody(
                    data:
                        userDataProvider.dietPlanString ?? "Erro ao carregar.",
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // Hydration Fixed for Fallback
                Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text("Hidratação (Real)",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text("Meta: ${(waterGoal / 1000).toStringAsFixed(1)}L",
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                // Exibe o consumo atual
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (waterConsumedMl / waterGoal).clamp(0.0, 1.0),
                  color: Colors.blue,
                  backgroundColor: Colors.grey[800],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: provider.removeWater,
                        icon: const Icon(Icons.remove)),
                    Text(
                        "${provider.waterIntake} copos (${(waterConsumedMl / 1000).toStringAsFixed(2)}L)",
                        style: const TextStyle(color: Colors.white)),
                    IconButton(
                        onPressed: provider.addWater,
                        icon: const Icon(Icons.add)),
                  ],
                )
              ]),
            ),
          )
        ],
      ),
    );
  }
}
