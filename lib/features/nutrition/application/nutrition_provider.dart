import 'package:flutter/material.dart';

class NutritionProvider extends ChangeNotifier {
  // Mock Data
  final Map<String, bool> _mealsCompleted = {};
  int _waterIntake = 0;
  final int _waterGoal = 10; // copos (approx 3L)

  // Getters
  int get waterIntake => _waterIntake;
  int get waterGoal => _waterGoal;

  bool isMealCompleted(String id) => _mealsCompleted[id] ?? false;

  int get consumedCalories {
    // Mock calculation based on checked meals
    // Assuming each meal is roughly 500kcal for demo
    int count = _mealsCompleted.values.where((e) => e).length;
    return count * 500;
  }

  int get targetCalories => 2400; // Mock target

  int get consumedProtein {
    // Mock calculation
    // Assuming each meal is 40g protein
    int count = _mealsCompleted.values.where((e) => e).length;
    return count * 40;
  }

  int get targetProtein => 160;

  // Actions
  void toggleMeal(String id) {
    bool current = _mealsCompleted[id] ?? false;
    _mealsCompleted[id] = !current;

    // Add points logic placeholder
    // if (!current) Gamification.addPoints(15);

    notifyListeners();
  }

  void addWater() {
    _waterIntake++;
    // Add points placeholder
    notifyListeners();
  }

  void removeWater() {
    if (_waterIntake > 0) _waterIntake--;
    notifyListeners();
  }

  String generateShoppingList() {
    return "Lista de Compras PROCS AI:\n- Ovos\n- Pão Integral\n- Frango\n- Arroz\n- Whey Protein\n- Creatina";
  }
}
