import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../../features/nutrition/domain/diet_models.dart'; // Import Models

/// Provider responsável por gerenciar os dados "vivos" do usuário,
/// incluindo a sincronização com o Firestore para receber o treino/dieta da IA.
class UserDataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;

  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  // Cache do plano parseado para evitar re-parse a cada build
  DietPlan? _cachedDietPlan;

  UserDataProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userData => _userData;

  bool get hasTrainingPlan => _userData?['trainingPlan'] != null;
  // Agora verificamos se dietPlanJSON existe, ou dietPlan antigo
  bool get hasDietPlan =>
      _userData?['dietPlan'] != null || _userData?['dietPlanJSON'] != null;

  String? get trainingPlan => _userData?['trainingPlan'] as String?;

  // Getter antigo para compatibilidade (se ainda for string)
  String? get dietPlanString => _userData?['dietPlan'] as String?;

  // NOVO: Getter estruturado
  DietPlan? get dietPlanObj {
    if (_cachedDietPlan != null) return _cachedDietPlan;

    final json = _userData?['dietPlanJSON'];
    if (json != null) {
      try {
        _cachedDietPlan = DietPlan.fromMap(json);
        return _cachedDietPlan;
      } catch (e) {
        debugPrint("Erro ao parsear dieta JSON: $e");
      }
    }
    return null;
  }

  // Getters de Perfil
  String get userName {
    final onboarding = _userData?['onboardingData'] as Map<String, dynamic>?;
    return onboarding?['name'] as String? ?? "Usuário";
  }

  double get userWeight {
    final onboarding = _userData?['onboardingData'] as Map<String, dynamic>?;
    // Tenta pegar currentWeight
    var w = onboarding?['currentWeight'];
    if (w is int) return w.toDouble();
    if (w is double) return w;
    return 70.0; // Fallback
  }

  // Preferências
  List<String> get dislikedFoods =>
      List<String>.from(_userData?['preferences']?['dislikedFoods'] ?? []);

  List<String> get favoriteFoods =>
      List<String>.from(_userData?['preferences']?['favoriteFoods'] ?? []);

  // Lista de Compras (Array de Maps no Firestore)
  List<Map<String, dynamic>> get shoppingList =>
      List<Map<String, dynamic>>.from(_userData?['shoppingList'] ?? []);

  // --- Actions ---

  /// Atualiza o nome do usuário no Firestore
  Future<void> updateName(String uid, String newName) async {
    await _firestoreService.updateUserData(uid, {
      'onboardingData.name': newName,
    });
  }

  /// Toggle Dislike (Negativar alimento)
  Future<void> toggleFoodDislike(String uid, String foodName) async {
    final currentDislikes = dislikedFoods;
    if (currentDislikes.contains(foodName)) {
      currentDislikes.remove(foodName);
    } else {
      currentDislikes.add(foodName);
    }
    await _firestoreService.updateUserData(uid, {
      'preferences.dislikedFoods': currentDislikes,
    });
  }

  /// Toggle Favorite (Recomendar sempre)
  Future<void> toggleFoodFavorite(String uid, String foodName) async {
    final currentFavs = favoriteFoods;
    if (currentFavs.contains(foodName)) {
      currentFavs.remove(foodName);
    } else {
      currentFavs.add(foodName);
    }
    await _firestoreService.updateUserData(uid, {
      'preferences.favoriteFoods': currentFavs,
    });
  }

  /// Salvar Lista de Compras
  Future<void> saveShoppingList(
      String uid, List<Map<String, dynamic>> items) async {
    await _firestoreService.updateUserData(uid, {
      'shoppingList': items,
    });
  }

  /// Atualizar item da lista de compras (check/uncheck)
  Future<void> toggleShoppingItem(String uid, int index) async {
    final currentList = shoppingList;
    if (index < 0 || index >= currentList.length) return;

    currentList[index]['isChecked'] =
        !(currentList[index]['isChecked'] ?? false);

    await _firestoreService.updateUserData(uid, {
      'shoppingList': currentList,
    });
  }

  /// Selecionar Opção de Refeição (apenas local por enquanto, ou salvar no user data se quiser persistir a escolha)
  void selectMealOption(int mealIndex, int optionIndex) {
    if (_cachedDietPlan != null && mealIndex < _cachedDietPlan!.meals.length) {
      _cachedDietPlan!.meals[mealIndex].selectedOptionIndex = optionIndex;
      notifyListeners();
      // Opcional: Salvar no Firestore qual opção foi escolhida para aquela refeição
    }
  }

  /// Aprovar Dieta (Gera Lista de Compras)
  Future<void> approveDietPlan(String uid) async {
    if (_cachedDietPlan == null) return;

    // 1. Gera lista de compras baseada nas opções selecionadas
    final List<Map<String, dynamic>> newList = [];

    for (var meal in _cachedDietPlan!.meals) {
      final selectedOption = meal.options[meal.selectedOptionIndex];
      for (var item in selectedOption.items) {
        newList.add({
          'name': item.name,
          'quantity': item.portion,
          'isChecked': false,
          'category': meal.name, // Agrupa por refeição ou categoria se tiver
        });
      }
    }

    // 2. Salva no Firestore
    await _firestoreService.updateUserData(uid, {
      'shoppingList': newList,
      'dietPlanJSON.status': 'approved',
    });
  }

  /// Inicia a escuta dos dados do usuário no Firestore.
  void listenToUser(String uid) {
    _userSubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    debugPrint('[UserDataProvider] Iniciando stream para user: $uid');

    _userSubscription = _firestoreService.streamUserData(uid).listen(
      (snapshot) {
        if (snapshot.exists) {
          _userData = snapshot.data();
          _cachedDietPlan = null; // Invalida cache para re-parsear se mudou
          debugPrint(
              '[UserDataProvider] Dados recebidos. JSON presente? ${_userData?['dietPlanJSON'] != null}');
        } else {
          debugPrint('[UserDataProvider] Documento do usuário não encontrado.');
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('[UserDataProvider] Erro na stream: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Limpa os dados (útil no logout)
  void clearData() {
    _userSubscription?.cancel();
    _userSubscription = null;
    _userData = null;
    _cachedDietPlan = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
