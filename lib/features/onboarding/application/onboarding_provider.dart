import 'package:flutter/foundation.dart';
import '../domain/onboarding_data_model.dart';

/// V3 (SPRINT 1): Provider (O "Entrevistador" Imutável)
/// Refatorado para Agenda (Ponto 6) e Cardio (Ponto 9)
class OnboardingProvider extends ChangeNotifier {
  OnboardingDataModel _data = const OnboardingDataModel();
  OnboardingDataModel get data => _data;

  // ---
  // SETTERS V3 (Imutáveis: usam copyWith)
  // ---

  // (Tela 1.2)
  void setTermsAccepted(bool accepted) {
    if (_data.termsAccepted == accepted) return;
    _data = _data.copyWith(termsAccepted: accepted);
    notifyListeners();
  }

  // V3 (Ponto 15 - Terms Screen)
  void setHealthDataAccepted(bool accepted) {
    if (_data.healthDataAccepted == accepted) return;
    _data = _data.copyWith(healthDataAccepted: accepted);
    notifyListeners();
  }

  // (Tela 1.2.1 - Name)
  void setName(String? name) {
    if (_data.name == name) return;
    _data = _data.copyWith(name: name);
    notifyListeners();
  }

  // (Tela 1.3 - Vitais)
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

  // (Tela 1.4 - Objetivo)
  void setObjective(String objective) {
    if (_data.objective == objective) return;
    _data = _data.copyWith(objective: objective);
    notifyListeners();
  }

  // (Tela 1.5 - Peso-Alvo)
  void setTargetWeight(double target) {
    if (_data.targetWeight == target) return;
    _data = _data.copyWith(targetWeight: target);
    notifyListeners();
  }

  // (Tela 1.6 - Experiência)
  void setExperienceLevel(String level) {
    if (_data.experienceLevel == level) return;
    _data = _data.copyWith(experienceLevel: level);
    notifyListeners();
  }

  // ---
  // V3 (Ref. Ponto 6 - Agenda): Setters da Agenda
  // ---
  void setScheduleMode(String mode) {
    // mode: 'days_of_week' ou 'times_per_week'
    if (_data.scheduleMode == mode) return;
    _data = _data.copyWith(
      scheduleMode: mode,
      // Reseta a outra opção ao trocar o modo
      scheduleDaysOfWeek:
          mode == 'days_of_week' ? _data.scheduleDaysOfWeek : const <String>{},
      scheduleTimesPerWeek:
          mode == 'times_per_week' ? _data.scheduleTimesPerWeek : null,
    );
    notifyListeners();
  }

  void toggleScheduleDay(String dayKey) {
    final newDays = Set<String>.from(_data.scheduleDaysOfWeek);
    if (newDays.contains(dayKey)) {
      newDays.remove(dayKey);
    } else {
      newDays.add(dayKey);
    }
    _data = _data.copyWith(scheduleDaysOfWeek: newDays);
    notifyListeners();
  }

  void setScheduleTimesPerWeek(int? times) {
    if (_data.scheduleTimesPerWeek == times) return;
    _data = _data.copyWith(scheduleTimesPerWeek: times);
    notifyListeners();
  }

  // (Tela 1.8 - Equipment)
  void setEquipmentLocation(String location) {
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
    // (Não notifica, salvo no 'onNext')
  }

  // (Tela 1.10 - Focus Area)
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

  // (Tela 1.11 - Injuries)
  void setInjuryData({required bool hasInjury, String? details}) {
    final String injuryDetails = (hasInjury ? details : '') ?? '';
    if (_data.hasInjury == hasInjury && _data.injuryDetails == injuryDetails) {
      return;
    }
    _data = _data.copyWith(
      hasInjury: hasInjury,
      injuryDetails: injuryDetails,
    );
    notifyListeners();
  }

  // ---
  // V3 (Ref. Ponto 9 - Cardio): Setters do Cardio
  // ---
  void setCardioPreference(String preference) {
    // preference: 'sim', 'nao', 'ia_decide'
    if (_data.cardioPreference == preference) return;

    // Reseta todo o sub-fluxo de cardio se a preferência principal mudar
    _data = _data.copyWith(
      cardioPreference: preference,
      cardioType: null,
      cardioOtherDetail: null,
      cardioScheduleMode: null,
      cardioDaysOfWeek: const <String>{},
      cardioTimesPerWeek: null,
    );
    notifyListeners();
  }

  void setCardioType(String type, {String? otherDetail}) {
    // type: 'corrida', 'natacao', 'outros'
    // otherDetail: "Dança"
    _data = _data.copyWith(
      cardioType: type,
      cardioOtherDetail: (type == 'outros') ? otherDetail : null,
    );
    notifyListeners();
  }

  void setCardioScheduleMode(String mode) {
    // mode: 'on_days', 'days_of_week', 'times_per_week'
    if (_data.cardioScheduleMode == mode) return;
    _data = _data.copyWith(
      cardioScheduleMode: mode,
      // Reseta as outras opções ao trocar o modo
      cardioDaysOfWeek:
          mode == 'days_of_week' ? _data.cardioDaysOfWeek : const <String>{},
      cardioTimesPerWeek:
          mode == 'times_per_week' ? _data.cardioTimesPerWeek : null,
    );
    notifyListeners();
  }

  void toggleCardioDay(String dayKey) {
    final newDays = Set<String>.from(_data.cardioDaysOfWeek);
    if (newDays.contains(dayKey)) {
      newDays.remove(dayKey);
    } else {
      newDays.add(dayKey);
    }
    _data = _data.copyWith(cardioDaysOfWeek: newDays);
    notifyListeners();
  }

  void setCardioTimesPerWeek(int? times) {
    if (_data.cardioTimesPerWeek == times) return;
    _data = _data.copyWith(cardioTimesPerWeek: times);
    notifyListeners();
  }

  // ---
  // V3 (Ref. Ponto 11 - Dieta): Setters da Dieta
  // ---
  void setDietHasNoRestrictions(bool hasNoRestrictions) {
    if (_data.dietHasNoRestrictions == hasNoRestrictions) return;
    _data = _data.copyWith(
      dietHasNoRestrictions: hasNoRestrictions,
      // Se "Não tenho" for true, limpa as restrições
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
      dietHasNoRestrictions: false, // Se marcar algo, "Não tenho" é falso
    );
    notifyListeners();
  }

  void setDietOtherRestriction(String? text) {
    _data = _data.copyWith(
      dietOtherRestriction: text,
      dietHasNoRestrictions: false, // Se digitar algo, "Não tenho" é falso
    );
    notifyListeners();
  }

  // (Tela 1.15 - Refeições)
  void setMealCount(int count) {
    if (_data.mealCount == count) return;
    _data = _data.copyWith(mealCount: count);
    notifyListeners();
  }

  // (Tela 1.16 - Food Dislikes)
  void setFoodDislikes(Set<String> dislikes) {
    if (setEquals(_data.foodDislikes, dislikes)) return;
    _data = _data.copyWith(foodDislikes: dislikes);
    notifyListeners(); // Notifica no 'onNext'
  }

  // (Tela 1.17 - Supplements)
  void setInterestInSupplements(bool interest) {
    if (_data.interestInSupplements == interest) return;
    _data = _data.copyWith(interestInSupplements: interest);
    notifyListeners();
  }

  // (Tela 1.23 - WhatsApp)
  void setPhoneNumber(String? phone) {
    if (_data.phoneNumber == phone) return;
    _data = _data.copyWith(phoneNumber: phone);
    notifyListeners(); // Notifica no 'onNext'
  }

  // (Tela 1.24 - Checkout)
  void setSelectedPlan(String plan) {
    if (_data.selectedPlan == plan) return;
    _data = _data.copyWith(selectedPlan: plan);
    notifyListeners();
  }
}
