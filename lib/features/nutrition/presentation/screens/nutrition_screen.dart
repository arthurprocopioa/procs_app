import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:provider/provider.dart';
import '../../application/nutrition_provider.dart';
import '../widgets/meal_card.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the NutritionProvider locally here if not provided higher up
    // Ideally should be in MainWrapper or Global, but for simplicity:
    return ChangeNotifierProvider(
      create: (_) => NutritionProvider(),
      child: const _NutritionView(),
    );
  }
}

class _NutritionView extends StatelessWidget {
  const _NutritionView();

  void _showRecipe(BuildContext context, String prep) {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1A1A1A),
        builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Modo de Preparo",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(prep, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 32),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NutritionProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header Custom
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const Text("Metas Diárias",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Calorie Ring
                      _buildRing(context,
                          title: "Calorias",
                          current: provider.consumedCalories,
                          target: provider.targetCalories,
                          color: Colors.orange),
                      // Protein Ring
                      _buildRing(context,
                          title: "Proteínas",
                          current: provider.consumedProtein,
                          target: provider.targetProtein,
                          color: colorScheme.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Meals List
                MealCard(
                  id: "meal1",
                  title: "Café da Manhã",
                  food: "3 Ovos Mexidos + 2 Fatias de Pão",
                  subtext: "Use frigideira antiaderente. Toste o pão.",
                  isCompleted: provider.isMealCompleted("meal1"),
                  onToggle: () => provider.toggleMeal("meal1"),
                  onSwap: () {},
                  onRecipe: () => _showRecipe(context,
                      "Misture os ovos e mexa na frigideira quente. Sirva com pão torrado."),
                ),
                MealCard(
                  id: "meal2",
                  title: "Almoço",
                  food: "150g Peito de Frango + 100g Arroz",
                  subtext: "Grelhe o frango com temperos naturais.",
                  isCompleted: provider.isMealCompleted("meal2"),
                  onToggle: () => provider.toggleMeal("meal2"),
                  onSwap: () {},
                  onRecipe: () =>
                      _showRecipe(context, "Grelhe o frango. Cozinhe o arroz."),
                ),
                MealCard(
                  id: "meal3",
                  title: "Lanche da Tarde",
                  food: "1 Scoop Whey + 30g Aveia",
                  subtext: "Misture com água ou leite desnatado.",
                  isCompleted: provider.isMealCompleted("meal3"),
                  onToggle: () => provider.toggleMeal("meal3"),
                  onSwap: () {},
                  onRecipe: () =>
                      _showRecipe(context, "Misture tudo no shaker."),
                ),
                MealCard(
                  id: "meal4",
                  title: "Jantar",
                  food: "150g Patinho Moído + Salada",
                  subtext: "Refogue a carne. Salada à vontade.",
                  isCompleted: provider.isMealCompleted("meal4"),
                  onToggle: () => provider.toggleMeal("meal4"),
                  onSwap: () {},
                  onRecipe: () =>
                      _showRecipe(context, "Refogue a carne moída."),
                ),

                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 24),

                // Hydration
                Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text("Hidratação",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text("Meta: ${provider.waterGoal * 0.3}L",
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.grey),
                      onPressed: provider.removeWater,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "${provider.waterIntake} copos",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: provider.addWater,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Supplementation
                const Text("Suplementação Educativa",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _SupplementCard(
                  name: "Creatina",
                  desc: "3g a 5g todos os dias. Auxilia na força.",
                ),
                _SupplementCard(
                  name: "Multivitamínico",
                  desc: "1 cápsula no café da manhã.",
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sugestões educativas. Consulte um médico antes de iniciar.",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 80), // Fab space
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final list = provider.generateShoppingList();
          Clipboard.setData(ClipboardData(text: list));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lista de compras copiada!")),
          );
        },
        backgroundColor: colorScheme.primary,
        label: const Text("Lista de Compras",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.shopping_cart_checkout, color: Colors.black),
      ),
    );
  }

  Widget _buildRing(BuildContext context,
      {required String title,
      required int current,
      required int target,
      required Color color}) {
    double progress = (current / target).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.grey[800],
                color: color,
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      current.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    Text(
                      "/$target",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SupplementCard extends StatelessWidget {
  final String name;
  final String desc;

  const _SupplementCard({required this.name, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading:
            const Icon(Icons.medical_services_outlined, color: Colors.white70),
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(desc, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.info_outline, size: 16, color: Colors.grey),
      ),
    );
  }
}
