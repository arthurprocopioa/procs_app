// V3.1.15 (A CORREÇÃO):
// O Handoff V3.1.14 (anterior) tinha 'package:/flutter...'.
// O Handoff V3.1.15 (corrigido) remove a barra '/'.
import 'package:flutter/foundation.dart';
// V3.1.14 (REMOVIDO): O UserCredential (V3.1.1) não é mais necessário no
// fluxo "Guest-first" (V3.1.7).
// import 'package:firebase_auth/firebase_auth.dart';

/// V3.1.14: O Formulário (Data Model "Burro")
/// (lib/features/onboarding/domain/onboarding_data_model.dart)
///
/// V3.1.14: Revertido para "Guest-first" (V3.1.7) (sem UserCredential),
/// mas mantendo o 'name' (V3.1.14) para a nova NameScreen (V3.1.13).
@immutable
class OnboardingDataModel {
  // V3.1.14 (REMOVIDO):
  // final UserCredential? userCredential;

  // Módulo 1: Acesso (Telas 1.1 - 1.2)
  // V3.1.14 (MANTIDO): O 'name' (V3.1.13) é capturado na NameScreen.
  final String? name;
  final bool termsAccepted;

  // Módulo 2.1: Dados Vitais (Tela 1.3)
  final int? age;
  final int? height;
  final double? currentWeight;
  final String? gender;

  // Módulo 2.2: Treino (Telas 1.4 - 1.12)
  final String? objective;
  final double? targetWeight;
  final String? experienceLevel;
  final String schedulingMode;
  final int? smartFrequency;
  final Set<String> fixedDays;
  final String? equipmentLocation;
  final Set<String> homeEquipment;
  final String? otherEquipment;
  final Set<String> focusAreas;
  final bool hasInjury;
  final String? injuryDetails;
  final String? cardioPreference;
  final String? cardioSchedule;

  // Módulo 2.3: Dieta (Telas 1.14 - 1.17)
  final Set<String> dietRestrictions;
  final int? mealCount;
  final Set<String> foodDislikes;
  final bool? interestInSupplements;

  // Módulo 2.4: Fechamento (Telas 1.20 - 1.24)
  final String? phoneNumber;
  final String? selectedPlan;

  /// Construtor V3.1.14
  const OnboardingDataModel({
    // V3.1.14 (REMOVIDO):
    // this.userCredential,
    // M1
    this.name, // V3.1.14 (MANTIDO)
    this.termsAccepted = false,
    // M2.1
    this.age,
    this.height,
    this.currentWeight,
    this.gender,
    // M2.2
    this.objective,
    this.targetWeight,
    this.experienceLevel,
    this.schedulingMode = 'smart',
    this.smartFrequency,
    this.fixedDays = const <String>{},
    this.equipmentLocation,
    this.homeEquipment = const <String>{},
    this.otherEquipment,
    this.focusAreas = const <String>{},
    this.hasInjury = false,
    this.injuryDetails,
    this.cardioPreference,
    this.cardioSchedule,
    // M2.3
    this.dietRestrictions = const <String>{},
    this.mealCount = 4,
    this.foodDislikes = const <String>{},
    this.interestInSupplements,
    // M2.4
    this.phoneNumber,
    this.selectedPlan,
  });

  /// Método CopyWith V3.1.14 (Imutável)
  OnboardingDataModel copyWith({
    // V3.1.14 (REMOVIDO):
    // UserCredential? userCredential,
    String? name,
    bool? termsAccepted,
    int? age,
    int? height,
    double? currentWeight,
    String? gender,
    String? objective,
    double? targetWeight,
    String? experienceLevel,
    String? schedulingMode,
    int? smartFrequency,
    Set<String>? fixedDays,
    String? equipmentLocation,
    Set<String>? homeEquipment,
    String? otherEquipment,
    Set<String>? focusAreas,
    bool? hasInjury,
    String? injuryDetails,
    String? cardioPreference,
    String? cardioSchedule,
    Set<String>? dietRestrictions,
    int? mealCount,
    Set<String>? foodDislikes,
    bool? interestInSupplements,
    String? phoneNumber,
    String? selectedPlan,
  }) {
    return OnboardingDataModel(
      // V3.1.14 (REMOVIDO):
      // userCredential: userCredential ?? this.userCredential,
      name: name ?? this.name,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      age: age ?? this.age,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      gender: gender ?? this.gender,
      objective: objective ?? this.objective,
      targetWeight: targetWeight ?? this.targetWeight,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      schedulingMode: schedulingMode ?? this.schedulingMode,
      smartFrequency: smartFrequency ?? this.smartFrequency,
      fixedDays: fixedDays ?? this.fixedDays,
      equipmentLocation: equipmentLocation ?? this.equipmentLocation,
      homeEquipment: homeEquipment ?? this.homeEquipment,
      otherEquipment: otherEquipment ?? this.otherEquipment,
      focusAreas: focusAreas ?? this.focusAreas,
      hasInjury: hasInjury ?? this.hasInjury,
      injuryDetails: injuryDetails ?? this.injuryDetails,
      cardioPreference: cardioPreference ?? this.cardioPreference,
      cardioSchedule: cardioSchedule ?? this.cardioSchedule,
      dietRestrictions: dietRestrictions ?? this.dietRestrictions,
      mealCount: mealCount ?? this.mealCount,
      foodDislikes: foodDislikes ?? this.foodDislikes,
      // ---
      // V3.1.14 (A CORREÇÃO)
      // O Handoff V3.1.14 (anterior) tinha um 'S' maiúsculo aqui.
      // O Handoff V3.1.14 (corrigido) usa o 's' minúsculo (V3).
      // ---
      interestInSupplements:
          interestInSupplements ?? this.interestInSupplements,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      selectedPlan: selectedPlan ?? this.selectedPlan,
    );
  }
}
