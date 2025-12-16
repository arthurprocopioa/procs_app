import 'package:flutter/foundation.dart';

@immutable
class OnboardingDataModel {
  // ... (Campos anteriores mantidos)
  final String? name;
  final bool termsAccepted;
  final bool healthDataAccepted;
  final int? age;
  final int? height;
  final double? currentWeight;
  final String? gender;
  final String? objective;
  final double? targetWeight;
  final String? experienceLevel;

  // Agenda de Treino
  final int? scheduleTimesPerWeek;
  final Set<String>
      selectedTrainingDays; // NOVO: Dias da semana selecionados (ex: 'monday', 'wednesday')
  // NOVO: Dias e Horários de Treino (Map<String, TimeOfDay>)
  // Ex: {'monday': TimeOfDay(18, 0), 'wednesday': TimeOfDay(07, 0)}
  // Como TimeOfDay não é serializável facilmente aqui, vamos guardar String "HH:mm"
  final Map<String, String>? trainingNotificationSchedule;

  final String? equipmentLocation;
  final Set<String> homeEquipment;
  final String? otherEquipment;
  final Set<String> focusAreas;
  final bool? hasInjury;
  final String? injuryDetails;
  final bool? hasHealthCondition; // NOVO: Nível 1 da seleção
  final Set<String> healthConditions;
  final String? healthConditionsOther;

  // Cardio
  final String? cardioPreference; // 'sim', 'nao' (IA Decide removido)
  final String? cardioType;
  final int? cardioTimesPerWeek;
  final Set<String> selectedCardioDays; // NOVO: Dias de cardio selecionados
  // NOVO: Dias e Horários de Cardio
  final Map<String, String>? cardioNotificationSchedule;

  final String? trainingTime;
  final bool dietHasNoRestrictions;
  final String? dietOtherRestriction;
  final Set<String> dietRestrictions;
  final int? mealCount;
  // NOVO: Horários das Refeições (Lista ordenada "08:00", "12:00", etc)
  final List<String>? mealNotificationSchedule;

  final Set<String> foodDislikes;
  final bool eatsEverything; // NOVO
  final bool? interestInSupplements;
  final String? userRegion;

  // NOVO: Compras de Mercado
  final int? groceryShoppingFrequency; // 1x, 2x, 3x, 4x no mês
  // Dias do mês e horário (Map<int, String>) Ex: {5: "10:00", 20: "10:00"}
  final Map<int, String>? groceryNotificationSchedule;

  final String? phoneNumber;
  final String? selectedPlan;

  // Permissão Geral
  final bool notificationsEnabled;
  final bool isPremium;

  const OnboardingDataModel({
    this.name,
    this.termsAccepted = false,
    this.healthDataAccepted = false,
    this.age,
    this.height,
    this.currentWeight,
    this.gender,
    this.objective,
    this.targetWeight,
    this.experienceLevel,
    this.scheduleTimesPerWeek,
    this.selectedTrainingDays = const <String>{}, // NOVO
    this.trainingNotificationSchedule, // NOVO
    this.equipmentLocation,
    this.homeEquipment = const <String>{},
    this.otherEquipment,
    this.focusAreas = const <String>{},
    this.hasInjury,
    this.injuryDetails,
    this.hasHealthCondition, // NOVO
    this.healthConditions = const <String>{},
    this.healthConditionsOther,
    this.cardioPreference,
    this.cardioType,
    this.cardioTimesPerWeek,
    this.selectedCardioDays = const <String>{}, // NOVO
    this.cardioNotificationSchedule, // NOVO
    this.trainingTime,
    this.dietHasNoRestrictions = false,
    this.dietOtherRestriction,
    this.dietRestrictions = const <String>{},
    this.mealCount = 4,
    this.mealNotificationSchedule, // NOVO
    this.foodDislikes = const <String>{},
    this.eatsEverything = false, // NOVO
    this.interestInSupplements,
    this.userRegion,
    this.groceryShoppingFrequency, // NOVO
    this.groceryNotificationSchedule, // NOVO
    this.phoneNumber,
    this.selectedPlan,
    this.notificationsEnabled = false, // NOVO
    this.isPremium = false, // Default to false (Free)
  });

  OnboardingDataModel copyWith({
    String? name,
    bool? termsAccepted,
    bool? healthDataAccepted,
    int? age,
    int? height,
    double? currentWeight,
    String? gender,
    String? objective,
    double? targetWeight,
    String? experienceLevel,
    int? scheduleTimesPerWeek,
    Set<String>? selectedTrainingDays,
    Map<String, String>? trainingNotificationSchedule,
    String? equipmentLocation,
    Set<String>? homeEquipment,
    String? otherEquipment,
    Set<String>? focusAreas,
    bool? hasInjury,
    String? injuryDetails,
    bool? hasHealthCondition, // NOVO
    Set<String>? healthConditions,
    String? healthConditionsOther,
    String? cardioPreference,
    String? cardioType,
    int? cardioTimesPerWeek,
    Set<String>? selectedCardioDays,
    Map<String, String>? cardioNotificationSchedule,
    String? trainingTime,
    bool? dietHasNoRestrictions,
    String? dietOtherRestriction,
    Set<String>? dietRestrictions,
    int? mealCount,
    List<String>? mealNotificationSchedule,
    Set<String>? foodDislikes,
    bool? eatsEverything, // NOVO
    bool? interestInSupplements,
    String? userRegion,
    int? groceryShoppingFrequency,
    Map<int, String>? groceryNotificationSchedule,
    String? phoneNumber,
    String? selectedPlan,
    bool? notificationsEnabled,
    bool? isPremium,
  }) {
    return OnboardingDataModel(
      name: name ?? this.name,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      healthDataAccepted: healthDataAccepted ?? this.healthDataAccepted,
      age: age ?? this.age,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      gender: gender ?? this.gender,
      objective: objective ?? this.objective,
      targetWeight: targetWeight ?? this.targetWeight,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      scheduleTimesPerWeek: scheduleTimesPerWeek ?? this.scheduleTimesPerWeek,
      selectedTrainingDays: selectedTrainingDays ?? this.selectedTrainingDays,
      trainingNotificationSchedule:
          trainingNotificationSchedule ?? this.trainingNotificationSchedule,
      equipmentLocation: equipmentLocation ?? this.equipmentLocation,
      homeEquipment: homeEquipment ?? this.homeEquipment,
      otherEquipment: otherEquipment ?? this.otherEquipment,
      focusAreas: focusAreas ?? this.focusAreas,
      hasInjury: hasInjury ?? this.hasInjury,
      injuryDetails: injuryDetails ?? this.injuryDetails,
      hasHealthCondition: hasHealthCondition ?? this.hasHealthCondition, // NOVO
      healthConditions: healthConditions ?? this.healthConditions,
      healthConditionsOther:
          healthConditionsOther ?? this.healthConditionsOther,
      cardioPreference: cardioPreference ?? this.cardioPreference,
      cardioType: cardioType ?? this.cardioType,
      cardioTimesPerWeek: cardioTimesPerWeek ?? this.cardioTimesPerWeek,
      selectedCardioDays: selectedCardioDays ?? this.selectedCardioDays,
      cardioNotificationSchedule:
          cardioNotificationSchedule ?? this.cardioNotificationSchedule,
      trainingTime: trainingTime ?? this.trainingTime,
      dietHasNoRestrictions:
          dietHasNoRestrictions ?? this.dietHasNoRestrictions,
      dietOtherRestriction: dietOtherRestriction ?? this.dietOtherRestriction,
      dietRestrictions: dietRestrictions ?? this.dietRestrictions,
      mealCount: mealCount ?? this.mealCount,
      mealNotificationSchedule:
          mealNotificationSchedule ?? this.mealNotificationSchedule,
      foodDislikes: foodDislikes ?? this.foodDislikes,
      eatsEverything: eatsEverything ?? this.eatsEverything, // NOVO
      interestInSupplements:
          interestInSupplements ?? this.interestInSupplements,
      userRegion: userRegion ?? this.userRegion,
      groceryShoppingFrequency:
          groceryShoppingFrequency ?? this.groceryShoppingFrequency,
      groceryNotificationSchedule:
          groceryNotificationSchedule ?? this.groceryNotificationSchedule,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
