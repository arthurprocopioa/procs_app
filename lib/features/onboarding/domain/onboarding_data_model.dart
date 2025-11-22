// V3 (SPRINT 1): Refatorado para Agenda (Ponto 6) e Cardio (Ponto 9)
// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/foundation.dart';

@immutable
class OnboardingDataModel {
  // Módulo 1: Acesso (Telas 1.1 - 1.2)
  final String? name;
  final bool termsAccepted;
  // V3 (Ponto 15 - Terms Screen): Adicionado para UX do Zing
  final bool healthDataAccepted;

  // Módulo 2.1: Dados Vitais (Tela 1.3)
  final int? age;
  final int? height;
  final double? currentWeight;
  final String? gender;

  // Módulo 2.2: Treino (Telas 1.4 - 1.12)
  final String? objective;
  final double? targetWeight;
  final String? experienceLevel;

  // V3 (Ref. Ponto 6 - Agenda)
  final String? scheduleMode; // 'days_of_week' ou 'times_per_week'
  final Set<String> scheduleDaysOfWeek;
  final int? scheduleTimesPerWeek;

  final String? equipmentLocation;
  final Set<String> homeEquipment;
  final String? otherEquipment;
  final Set<String> focusAreas;
  final bool hasInjury;
  final String? injuryDetails;

  // V3 (Ref. Ponto 9 - Cardio)
  final String? cardioPreference; // 'sim', 'nao', 'ia_decide'
  final String? cardioType; // 'corrida', 'natacao', 'ciclismo', 'outros'
  final String? cardioOtherDetail; // "Dança"
  final String?
      cardioScheduleMode; // 'on_days', 'days_of_week', 'times_per_week'
  final Set<String> cardioDaysOfWeek;
  final int? cardioTimesPerWeek;

  // NOVO: Tempo de treino diário (Passo 10/15)
  final String? trainingTime; // Ex: '30min', '60min'

  // Módulo 2.3: Dieta (Telas 1.14 - 1.17)
  // V3 (Ref. Ponto 11 - Dieta): Adicionados
  final bool dietHasNoRestrictions;
  final String? dietOtherRestriction;
  final Set<String> dietRestrictions;

  final int? mealCount;
  final Set<String> foodDislikes;
  final bool? interestInSupplements;

  // NOVO: Localização do Usuário (Passo 15/15)
  final String? userRegion; // Ex: 'sudeste', 'sul', 'nordeste'

  // Módulo 2.4: Fechamento (Telas 1.20 - 1.24)
  final String? phoneNumber;
  final String? selectedPlan;

  /// Construtor V3 (Sprint 1)
  const OnboardingDataModel({
    // M1
    this.name,
    this.termsAccepted = false,
    this.healthDataAccepted = false, // V3 (Ponto 15)
    // M2.1
    this.age,
    this.height,
    this.currentWeight,
    this.gender,
    // M2.2
    this.objective,
    this.targetWeight,
    this.experienceLevel,
    // V3 (Ponto 6 - Agenda)
    this.scheduleMode,
    this.scheduleDaysOfWeek = const <String>{},
    this.scheduleTimesPerWeek,
    //
    this.equipmentLocation,
    this.homeEquipment = const <String>{},
    this.otherEquipment,
    this.focusAreas = const <String>{},
    this.hasInjury = false,
    this.injuryDetails,
    // V3 (Ponto 9 - Cardio)
    this.cardioPreference,
    this.cardioType,
    this.cardioOtherDetail,
    this.cardioScheduleMode,
    this.cardioDaysOfWeek = const <String>{},
    this.cardioTimesPerWeek,
    // NOVO (Tempo de Treino)
    this.trainingTime,
    // M2.3
    // V3 (Ponto 11 - Dieta)
    this.dietHasNoRestrictions = false,
    this.dietOtherRestriction,
    this.dietRestrictions = const <String>{},
    //
    this.mealCount = 4,
    this.foodDislikes = const <String>{},
    this.interestInSupplements,
    // NOVO (Localização)
    this.userRegion,
    // M2.4
    this.phoneNumber,
    this.selectedPlan,
  });

  /// Método CopyWith V3 (Sprint 1)
  OnboardingDataModel copyWith({
    String? name,
    bool? termsAccepted,
    bool? healthDataAccepted, // V3 (Ponto 15)
    int? age,
    int? height,
    double? currentWeight,
    String? gender,
    String? objective,
    double? targetWeight,
    String? experienceLevel,
    // V3 (Ponto 6 - Agenda)
    String? scheduleMode,
    Set<String>? scheduleDaysOfWeek,
    int? scheduleTimesPerWeek,
    //
    String? equipmentLocation,
    Set<String>? homeEquipment,
    String? otherEquipment,
    Set<String>? focusAreas,
    bool? hasInjury,
    String? injuryDetails,
    // V3 (Ponto 9 - Cardio)
    String? cardioPreference,
    String? cardioType,
    String? cardioOtherDetail,
    String? cardioScheduleMode,
    Set<String>? cardioDaysOfWeek,
    int? cardioTimesPerWeek,
    // NOVO (Tempo de Treino)
    String? trainingTime,
    // V3 (Ponto 11 - Dieta)
    bool? dietHasNoRestrictions,
    String? dietOtherRestriction,
    Set<String>? dietRestrictions,
    //
    int? mealCount,
    Set<String>? foodDislikes,
    bool? interestInSupplements,
    // NOVO (Localização)
    String? userRegion,
    String? phoneNumber,
    String? selectedPlan,
  }) {
    return OnboardingDataModel(
      name: name ?? this.name,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      healthDataAccepted: healthDataAccepted ?? this.healthDataAccepted, // V3
      age: age ?? this.age,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      gender: gender ?? this.gender,
      objective: objective ?? this.objective,
      targetWeight: targetWeight ?? this.targetWeight,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      // V3 (Ponto 6 - Agenda)
      scheduleMode: scheduleMode ?? this.scheduleMode,
      scheduleDaysOfWeek: scheduleDaysOfWeek ?? this.scheduleDaysOfWeek,
      scheduleTimesPerWeek: scheduleTimesPerWeek ?? this.scheduleTimesPerWeek,
      //
      equipmentLocation: equipmentLocation ?? this.equipmentLocation,
      homeEquipment: homeEquipment ?? this.homeEquipment,
      otherEquipment: otherEquipment ?? this.otherEquipment,
      focusAreas: focusAreas ?? this.focusAreas,
      hasInjury: hasInjury ?? this.hasInjury,
      injuryDetails: injuryDetails ?? this.injuryDetails,
      // V3 (Ponto 9 - Cardio)
      cardioPreference: cardioPreference ?? this.cardioPreference,
      cardioType: cardioType ?? this.cardioType,
      cardioOtherDetail: cardioOtherDetail ?? this.cardioOtherDetail,
      cardioScheduleMode: cardioScheduleMode ?? this.cardioScheduleMode,
      cardioDaysOfWeek: cardioDaysOfWeek ?? this.cardioDaysOfWeek,
      cardioTimesPerWeek: cardioTimesPerWeek ?? this.cardioTimesPerWeek,
      // NOVO (Tempo de Treino)
      trainingTime: trainingTime ?? this.trainingTime,
      // V3 (Ponto 11 - Dieta)
      dietHasNoRestrictions:
          dietHasNoRestrictions ?? this.dietHasNoRestrictions,
      dietOtherRestriction: dietOtherRestriction ?? this.dietOtherRestriction,
      dietRestrictions: dietRestrictions ?? this.dietRestrictions,
      //
      mealCount: mealCount ?? this.mealCount,
      foodDislikes: foodDislikes ?? this.foodDislikes,
      interestInSupplements:
          interestInSupplements ?? this.interestInSupplements,
      // NOVO (Localização)
      userRegion: userRegion ?? this.userRegion,
      // M2.4
      phoneNumber: phoneNumber ?? this.phoneNumber,
      selectedPlan: selectedPlan ?? this.selectedPlan,
    );
  }
}
