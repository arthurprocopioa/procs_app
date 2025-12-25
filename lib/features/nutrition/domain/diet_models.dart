class DietPlan {
  final List<Meal> meals;
  final String status; // 'pending_approval', 'approved'

  DietPlan({required this.meals, this.status = 'pending_approval'});

  factory DietPlan.fromMap(Map<String, dynamic> map) {
    return DietPlan(
      meals: (map['meals'] as List<dynamic>?)
              ?.map((x) => Meal.fromMap(x))
              .toList() ??
          [],
      status: map['status'] ?? 'pending_approval',
    );
  }
}

class Meal {
  final String name; // "Café da Manhã", "Almoço"...
  final List<MealOption> options; // Opção 1, Opção 2...
  int selectedOptionIndex; // Qual opção o usuário escolheu (0 default)

  Meal({
    required this.name,
    required this.options,
    this.selectedOptionIndex = 0,
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'] ?? 'Refeição',
      options: (map['options'] as List<dynamic>?)
              ?.map((x) => MealOption.fromMap(x))
              .toList() ??
          [],
      selectedOptionIndex: map['selectedOptionIndex'] ?? 0,
    );
  }
}

class MealOption {
  final String name; // "Opção Leve", "Opção Proteica"...
  final List<FoodItem> items;
  final Map<String, int> macros; // {calories, protein, carbs, fat}

  MealOption({
    required this.name,
    required this.items,
    required this.macros,
  });

  factory MealOption.fromMap(Map<String, dynamic> map) {
    return MealOption(
      name: map['name'] ?? 'Opção',
      items: (map['items'] as List<dynamic>?)
              ?.map((x) => FoodItem.fromMap(x))
              .toList() ??
          [],
      macros: Map<String, int>.from(map['macros'] ?? {}),
    );
  }
}

class FoodItem {
  final String name;
  final String portion; // "100g", "1 unidade"
  final String prepMethod; // "Grelhado", "Cozido"

  FoodItem({
    required this.name,
    required this.portion,
    this.prepMethod = '',
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] ?? '',
      portion: map['portion'] ?? '',
      prepMethod: map['prepMethod'] ?? '',
    );
  }
}
