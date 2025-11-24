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
  // NOVO: Dias e Horários de Treino (Map<String, TimeOfDay>)
  // Ex: {'monday': TimeOfDay(18, 0), 'wednesday': TimeOfDay(07, 0)}
  // Como TimeOfDay não é serializável facilmente aqui, vamos guardar String "HH:mm"
  final Map<String, String>? trainingNotificationSchedule;

  final String? equipmentLocation;
  final Set<String> homeEquipment;
  final String? otherEquipment;
  final Set<String> focusAreas;
  final bool hasInjury;
  final String? injuryDetails;
  final Set<String> healthConditions;
  final String? healthConditionsOther;

  // Cardio
  final String? cardioPreference; // 'sim', 'nao' (IA Decide removido)
  final String? cardioType;
  final String? cardioOtherDetail;
  final int? cardioTimesPerWeek;
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
    this.trainingNotificationSchedule, // NOVO
    this.equipmentLocation,
    this.homeEquipment = const <String>{},
    this.otherEquipment,
    this.focusAreas = const <String>{},
    this.hasInjury = false,
    this.injuryDetails,
    this.healthConditions = const <String>{},
    this.healthConditionsOther,
    this.cardioPreference,
    this.cardioType,
    this.cardioOtherDetail,
    this.cardioTimesPerWeek,
    this.cardioNotificationSchedule, // NOVO
    this.trainingTime,
    this.dietHasNoRestrictions = false,
    this.dietOtherRestriction,
    this.dietRestrictions = const <String>{},
    this.mealCount = 4,
    this.mealNotificationSchedule, // NOVO
    this.foodDislikes = const <String>{},
    this.interestInSupplements,
    this.userRegion,
    this.groceryShoppingFrequency, // NOVO
    this.groceryNotificationSchedule, // NOVO
    this.phoneNumber,
    this.selectedPlan,
    this.notificationsEnabled = false, // NOVO
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
    Map<String, String>? trainingNotificationSchedule,
    String? equipmentLocation,
    Set<String>? homeEquipment,
    String? otherEquipment,
    Set<String>? focusAreas,
    bool? hasInjury,
    String? injuryDetails,
    Set<String>? healthConditions,
    String? healthConditionsOther,
    String? cardioPreference,
    String? cardioType,
    String? cardioOtherDetail,
    int? cardioTimesPerWeek,
    Map<String, String>? cardioNotificationSchedule,
    String? trainingTime,
    bool? dietHasNoRestrictions,
    String? dietOtherRestriction,
    Set<String>? dietRestrictions,
    int? mealCount,
    List<String>? mealNotificationSchedule,
    Set<String>? foodDislikes,
    bool? interestInSupplements,
    String? userRegion,
    int? groceryShoppingFrequency,
    Map<int, String>? groceryNotificationSchedule,
    String? phoneNumber,
    String? selectedPlan,
    bool? notificationsEnabled,
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
      trainingNotificationSchedule:
          trainingNotificationSchedule ?? this.trainingNotificationSchedule,
      equipmentLocation: equipmentLocation ?? this.equipmentLocation,
      homeEquipment: homeEquipment ?? this.homeEquipment,
      otherEquipment: otherEquipment ?? this.otherEquipment,
      focusAreas: focusAreas ?? this.focusAreas,
      hasInjury: hasInjury ?? this.hasInjury,
      injuryDetails: injuryDetails ?? this.injuryDetails,
      healthConditions: healthConditions ?? this.healthConditions,
      healthConditionsOther:
          healthConditionsOther ?? this.healthConditionsOther,
      cardioPreference: cardioPreference ?? this.cardioPreference,
      cardioType: cardioType ?? this.cardioType,
      cardioOtherDetail: cardioOtherDetail ?? this.cardioOtherDetail,
      cardioTimesPerWeek: cardioTimesPerWeek ?? this.cardioTimesPerWeek,
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
    );
  }
}
