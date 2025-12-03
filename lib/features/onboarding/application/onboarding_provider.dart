import 'package:flutter/foundation.dart';
import '../domain/onboarding_data_model.dart';

class OnboardingProvider extends ChangeNotifier {
  static const int totalOnboardingSteps = 17;

  OnboardingDataModel _data = const OnboardingDataModel();
  OnboardingDataModel get data => _data;

  // ... (Métodos anteriores de nome, termos, vitais, treino mantidos igual) ...

  // --- Módulo 1 ---
  void setTermsAccepted(bool accepted) {
    if (_data.termsAccepted == accepted) return;
    _data = _data.copyWith(termsAccepted: accepted);
    notifyListeners();
  }

  void setHealthDataAccepted(bool accepted) {
    if (_data.healthDataAccepted == accepted) return;
    _data = _data.copyWith(healthDataAccepted: accepted);
    notifyListeners();
  }

  void setName(String? name) {
    if (_data.name == name) return;
    _data = _data.copyWith(name: name);
    notifyListeners();
  }

  // --- Módulo 2.1 ---
  void setAge(int age) {
    if (_data.age == age) return;
    _data = _data.copyWith(age: age);
    notifyListeners();
  }

  void setHeight(int height) {
    if (_data.height == height) return;
    _data = _data.copyWith(height: height);
    notifyListeners();
  }

  void setCurrentWeight(double weight) {
    if (_data.currentWeight == weight) return;
    _data = _data.copyWith(currentWeight: weight);
    notifyListeners();
  }

  void setGender(String gender) {
    if (_data.gender == gender) return;
    _data = _data.copyWith(gender: gender);
    notifyListeners();
  }

  // --- Módulo 2.2 ---
  void setObjective(String objective) {
    if (_data.objective == objective) return;
    _data = _data.copyWith(objective: objective);
    notifyListeners();
  }

  void setTargetWeight(double target) {
    if (_data.targetWeight == target) return;
    _data = _data.copyWith(targetWeight: target);
    notifyListeners();
  }

  void setExperienceLevel(String level) {
    if (_data.experienceLevel == level) return;
    _data = _data.copyWith(experienceLevel: level);
    notifyListeners();
  }

  void setScheduleTimesPerWeek(int? times) {
    if (_data.scheduleTimesPerWeek == times) return;
    _data = _data.copyWith(scheduleTimesPerWeek: times);
    notifyListeners();
  }

  // NOVO: Salvar dias de treino selecionados
  void setSelectedTrainingDays(Set<String> days) {
    if (setEquals(_data.selectedTrainingDays, days)) return;
    _data = _data.copyWith(selectedTrainingDays: days);
    notifyListeners();
  }

  // NOVO: Salvar agenda de treino
  void setTrainingNotificationSchedule(Map<String, String> schedule) {
    _data = _data.copyWith(trainingNotificationSchedule: schedule);
    notifyListeners();
  }

  void setEquipmentLocation(String? location) {
    if (_data.equipmentLocation == location) return;
    _data = _data.copyWith(equipmentLocation: location);
    if (location != 'casa_com') {
      _data = _data.copyWith(
        homeEquipment: const <String>{},
        otherEquipment: '',
      );
    }
    notifyListeners();
  }

  void toggleHomeEquipment(String equipmentKey) {
    if (_data.equipmentLocation != 'casa_com') return;
    final newEquip = Set<String>.from(_data.homeEquipment);
    if (newEquip.contains(equipmentKey)) {
      newEquip.remove(equipmentKey);
    } else {
      newEquip.add(equipmentKey);
    }
    _data = _data.copyWith(homeEquipment: newEquip);
    notifyListeners();
  }

  void setOtherEquipment(String text) {
    if (_data.otherEquipment == text) return;
    _data = _data.copyWith(otherEquipment: text);
  }

  void toggleFocusArea(String areaKey) {
    final newAreas = Set<String>.from(_data.focusAreas);
    if (areaKey == 'full_body') {
      if (newAreas.contains(areaKey)) {
        newAreas.clear();
      } else {
        newAreas.clear();
        newAreas.add(areaKey);
      }
    } else {
      newAreas.remove('full_body');
      if (newAreas.contains(areaKey)) {
        newAreas.remove(areaKey);
      } else {
        newAreas.add(areaKey);
      }
    }
    _data = _data.copyWith(focusAreas: newAreas);
    notifyListeners();
  }

  void setInjuryData({required bool hasInjury, String? details}) {
    final String injuryDetails = (hasInjury ? details : '') ?? '';
    if (_data.hasInjury == hasInjury && _data.injuryDetails == injuryDetails) {
      return;
    }
    _data = _data.copyWith(hasInjury: hasInjury, injuryDetails: injuryDetails);
    notifyListeners();
  }

  void setHasHealthCondition(bool hasCondition) {
    if (_data.hasHealthCondition == hasCondition) return;

    // Se mudou para "Não possuo", limpa as condições específicas
    if (!hasCondition) {
      _data = _data.copyWith(
        hasHealthCondition: false,
        healthConditions: const <String>{},
        healthConditionsOther: null,
      );
    } else {
      _data = _data.copyWith(hasHealthCondition: true);
    }
    notifyListeners();
  }

  void toggleHealthCondition(String conditionKey) {
    final newConditions = Set<String>.from(_data.healthConditions);
    if (conditionKey == 'none') {
      if (newConditions.contains('none')) {
        newConditions.remove('none');
      } else {
        newConditions.clear();
        newConditions.add('none');
      }
      setHealthConditionOther(null);
    } else {
      newConditions.remove('none');
      if (newConditions.contains(conditionKey)) {
        newConditions.remove(conditionKey);
      } else {
        newConditions.add(conditionKey);
      }
    }

    // Se selecionou alguma condição específica (que não seja none), garante que hasHealthCondition é true
    // Mas a lógica principal agora é controlada pelo setHasHealthCondition
    _data = _data.copyWith(healthConditions: newConditions);
    notifyListeners();
  }

  void setHealthConditionOther(String? text) {
    if (text != null &&
        text.isNotEmpty &&
        _data.healthConditions.contains('none')) {
      final newConditions = Set<String>.from(_data.healthConditions);
      newConditions.remove('none');
      _data = _data.copyWith(healthConditions: newConditions);
      notifyListeners();
    }
    if (_data.healthConditionsOther == text) return;
    _data = _data.copyWith(healthConditionsOther: text);
  }

  // V3 (Ref. Ponto 9 - Cardio)
  void setCardioPreference(String preference) {
    if (_data.cardioPreference == preference) return;
    _data = _data.copyWith(
      cardioPreference: preference,
      cardioType: null,
      cardioTimesPerWeek: null,
    );
    notifyListeners();
  }

  void setCardioType(String type) {
    _data = _data.copyWith(
      cardioType: type,
    );
    notifyListeners();
  }

  void setCardioTimesPerWeek(int? times) {
    if (_data.cardioTimesPerWeek == times) return;
    _data = _data.copyWith(cardioTimesPerWeek: times);
    notifyListeners();
  }

  // NOVO: Salvar dias de cardio selecionados
  void setSelectedCardioDays(Set<String> days) {
    if (setEquals(_data.selectedCardioDays, days)) return;
    _data = _data.copyWith(selectedCardioDays: days);
    notifyListeners();
  }

  // NOVO: Salvar agenda de cardio
  void setCardioNotificationSchedule(Map<String, String> schedule) {
    _data = _data.copyWith(cardioNotificationSchedule: schedule);
    notifyListeners();
  }

  void setTrainingTime(String? time) {
    if (_data.trainingTime == time) return;
    _data = _data.copyWith(trainingTime: time);
    notifyListeners();
  }

  // --- Módulo 2.3 ---
  void setDietHasNoRestrictions(bool hasNoRestrictions) {
    if (_data.dietHasNoRestrictions == hasNoRestrictions) return;
    _data = _data.copyWith(
      dietHasNoRestrictions: hasNoRestrictions,
      dietRestrictions:
          hasNoRestrictions ? const <String>{} : _data.dietRestrictions,
      dietOtherRestriction:
          hasNoRestrictions ? null : _data.dietOtherRestriction,
    );
    notifyListeners();
  }

  void toggleDietRestriction(String restrictionKey) {
    final newRestrictions = Set<String>.from(_data.dietRestrictions);
    if (newRestrictions.contains(restrictionKey)) {
      newRestrictions.remove(restrictionKey);
    } else {
      newRestrictions.add(restrictionKey);
    }
    _data = _data.copyWith(
      dietRestrictions: newRestrictions,
      dietHasNoRestrictions: false,
    );
    notifyListeners();
  }

  void setDietOtherRestriction(String? text) {
    _data = _data.copyWith(
      dietOtherRestriction: text,
      dietHasNoRestrictions: false,
    );
    notifyListeners();
  }

  void setMealCount(int count) {
    if (_data.mealCount == count) return;
    _data = _data.copyWith(mealCount: count);
    notifyListeners();
  }

  // NOVO: Salvar agenda de refeições
  void setMealNotificationSchedule(List<String> schedule) {
    _data = _data.copyWith(mealNotificationSchedule: schedule);
    notifyListeners();
  }

  void setFoodDislikes(Set<String> dislikes) {
    if (setEquals(_data.foodDislikes, dislikes)) return;
    _data = _data.copyWith(
      foodDislikes: dislikes,
      eatsEverything: false,
    );
    notifyListeners();
  }

  void setEatsEverything() {
    _data = _data.copyWith(
      eatsEverything: true,
      foodDislikes: const <String>{},
    );
    notifyListeners();
  }

  void setInterestInSupplements(bool? interest) {
    if (_data.interestInSupplements == interest) return;
    _data = _data.copyWith(interestInSupplements: interest);
    notifyListeners();
  }

  void setUserRegion(String? region) {
    if (_data.userRegion == region) return;
    _data = _data.copyWith(userRegion: region);
    notifyListeners();
  }

  // NOVO: Compras de Mercado
  void setGroceryShoppingFrequency(int frequency) {
    _data = _data.copyWith(groceryShoppingFrequency: frequency);
    notifyListeners();
  }

  void setGroceryNotificationSchedule(Map<int, String> schedule) {
    _data = _data.copyWith(groceryNotificationSchedule: schedule);
    notifyListeners();
  }

  // NOVO: Permissão Geral de Notificações
  void setNotificationsEnabled(bool enabled) {
    _data = _data.copyWith(notificationsEnabled: enabled);
    notifyListeners();
  }

  // --- Módulo 2.4 ---
  void setPhoneNumber(String? phone) {
    if (_data.phoneNumber == phone) return;
    _data = _data.copyWith(phoneNumber: phone);
    notifyListeners();
  }

  void setSelectedPlan(String plan) {
    if (_data.selectedPlan == plan) return;
    _data = _data.copyWith(selectedPlan: plan);
    notifyListeners();
  }

  void setIsPremium(bool isPremium) {
    if (_data.isPremium == isPremium) return;
    _data = _data.copyWith(isPremium: isPremium);
    notifyListeners();
  }
}
