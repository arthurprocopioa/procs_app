import 'package:flutter/foundation.dart';
// V3.1.14 (REMOVIDO):
// import 'package:firebase_auth/firebase_auth.dart';
import '../domain/onboarding_data_model.dart';

/// V3.1.14: Provider (O "Entrevistador" Imutável)
/// Gerencia o OnboardingDataModel como "Memória RAM" V3
///
/// V3.1.14: Revertido para "Guest-first" (V3.1.7) (sem UserCredential),
/// mas mantendo o 'setName' (V3.1.14) para a nova NameScreen (V3.1.13).
class OnboardingProvider extends ChangeNotifier {
  // O "Formulário" (Data Model) que o "EntrevistLdor" gerencia
  OnboardingDataModel _data = const OnboardingDataModel();

  /// Expõe o Data Model (Formulário) de forma pública (Read-Only)
  OnboardingDataModel get data => _data;

  // ---
  // SETTERS V3 (Imutáveis: usam copyWith)
  // ---

  // V3.1.14 (REMOVIDO):
  // void setUserCredential(UserCredential credential) {
  //   ...
  //

  // ---
  // V3.1.14 (MANTIDO E CORRIGIDO): O MÉTODO QUE VOCÊ PRECISA
  // ---
  /// V3.1.14 (Handoff V3.1.13)
  /// Salva o nome do usuário (capturado do TextField V3.1.13)
  /// na "Memória RAM" V3.
  void setName(String? name) {
    if (_data.name == name) return;
    _data = _data.copyWith(name: name);

    // V3.1.14 (FIX): O Handoff V3.1.1 (Auth-first) não notificava,
    // pois o V3.1.1 (setUserCredential) o fazia.
    // O Handoff V3.1.14 (Guest-first) DEVE notificar, pois é uma ação V3.1.14 única.
    notifyListeners();
  }

  // (Tela 1.2)
  void setTermsAccepted(bool accepted) {
    if (_data.termsAccepted == accepted) return;
    _data = _data.copyWith(termsAccepted: accepted);
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

  // ---
  // V3: CORREÇÃO DO BUG (image_a1f41f.png)
  // Renomeado de 'setWeight' (V1) para 'setCurrentWeight' (V3)
  // ---
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

  // (Tela 1.7 - Schedule)
  void setSchedulingMode(String mode) {
    if (mode != 'smart' && mode != 'fixed') return;
    if (_data.schedulingMode == mode) return;
    _data = _data.copyWith(schedulingMode: mode);
    notifyListeners();
  }

  void setSmartFrequency(int? frequency) {
    if (_data.smartFrequency == frequency) return;
    _data = _data.copyWith(
      smartFrequency: frequency,
      fixedDays: const <String>{}, // Reseta o outro
    );
    notifyListeners();
  }

  void toggleFixedDay(String dayKey) {
    final newDays = Set<String>.from(_data.fixedDays);
    if (newDays.contains(dayKey)) {
      newDays.remove(dayKey);
    } else {
      newDays.add(dayKey);
    }
    _data = _data.copyWith(
      fixedDays: newDays,
      smartFrequency: null, // Reseta o outro
    );
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

    // Lógica V3: Se 'Corpo Inteiro' for selecionado, limpa os outros.
    // Se outro for selecionado, limpa 'Corpo Inteiro'.
    if (areaKey == 'full_body') {
      if (newAreas.contains(areaKey)) {
        newAreas.clear();
      } else {
        newAreas.clear();
        newAreas.add(areaKey);
      }
    } else {
      newAreas.remove('full_body'); // Remove 'Corpo Inteiro'
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
    notifyListeners(); // Notifica no 'onNext' da tela
  }

  // (Tela 1.12 - Cardio)
  void setCardioData({required String preference, String? schedule}) {
    final String? cardioSchedule = (preference == 'sim') ? schedule : null;
    if (_data.cardioPreference == preference &&
        _data.cardioSchedule == cardioSchedule) {
      return;
    }

    _data = _data.copyWith(
      cardioPreference: preference,
      cardioSchedule: cardioSchedule,
    );
    notifyListeners();
  }

  // (Tela 1.14 - Dieta)
  void toggleDietRestriction(String restrictionKey) {
    final newRestrictions = Set<String>.from(_data.dietRestrictions);
    if (newRestrictions.contains(restrictionKey)) {
      newRestrictions.remove(restrictionKey);
    } else {
      newRestrictions.add(restrictionKey);
    }
    _data = _data.copyWith(dietRestrictions: newRestrictions);
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
