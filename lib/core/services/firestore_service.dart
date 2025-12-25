import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/onboarding/domain/onboarding_data_model.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Salva os dados de onboarding na coleção 'users'.
  /// Usa merge: true para não sobrescrever outros campos (como dados de auth).
  Future<void> saveOnboardingData(String uid, OnboardingDataModel data) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'onboardingData': _dataToMap(data),
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
        // Define flag para o Cloud Function/Backend saber que deve processar
        'status': 'processing_onboarding',
      }, SetOptions(merge: true));

      debugPrint(
          '[FirestoreService] Dados de onboarding salvos para o UID: $uid');
    } catch (e) {
      debugPrint('[FirestoreService] Erro ao salvar dados: $e');
      rethrow;
    }
  }

  /// Atualiza campos específicos do usuário
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      debugPrint('[FirestoreService] Dados atualizados para UID: $uid');
    } catch (e) {
      debugPrint('[FirestoreService] Erro ao atualizar dados: $e');
      rethrow;
    }
  }

  /// Ouve as mudanças no documento do usuário (para pegar a resposta da IA).
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Converte o modelo para Map.
  /// Feito aqui para não "sujar" o domínio com detalhes de serialização JSON/Firestore
  /// se não houver necessidade estrita (embora toJson no model seja comum).
  Map<String, dynamic> _dataToMap(OnboardingDataModel data) {
    return {
      'name': data.name,
      'termsAccepted': data.termsAccepted,
      'healthDataAccepted': data.healthDataAccepted,
      'age': data.age,
      'height': data.height,
      'currentWeight': data.currentWeight,
      'gender': data.gender,
      'objective': data.objective,
      'targetWeight': data.targetWeight,
      'experienceLevel': data.experienceLevel,
      // Treino
      'scheduleTimesPerWeek': data.scheduleTimesPerWeek,
      'selectedTrainingDays': data.selectedTrainingDays.toList(),
      'trainingNotificationSchedule': data.trainingNotificationSchedule,
      'equipmentLocation': data.equipmentLocation,
      'homeEquipment': data.homeEquipment.toList(),
      'otherEquipment': data.otherEquipment,
      'focusAreas': data.focusAreas.toList(),
      'hasInjury': data.hasInjury,
      'injuryDetails': data.injuryDetails,
      'hasHealthCondition': data.hasHealthCondition,
      'healthConditions': data.healthConditions.toList(),
      'healthConditionsOther': data.healthConditionsOther,
      // Cardio
      'cardioPreference': data.cardioPreference,
      'cardioType': data.cardioType,
      'cardioTimesPerWeek': data.cardioTimesPerWeek,
      'selectedCardioDays': data.selectedCardioDays.toList(),
      'cardioNotificationSchedule': data.cardioNotificationSchedule,
      'trainingTime': data.trainingTime,
      // Dieta
      'dietHasNoRestrictions': data.dietHasNoRestrictions,
      'dietOtherRestriction': data.dietOtherRestriction,
      'dietRestrictions': data.dietRestrictions.toList(),
      'mealCount': data.mealCount,
      'mealNotificationSchedule': data.mealNotificationSchedule,
      'foodDislikes': data.foodDislikes.toList(),
      'eatsEverything': data.eatsEverything,
      'interestInSupplements': data.interestInSupplements,
      'selectedSupplements': data.selectedSupplements.toList(),
      'otherSupplements': data.otherSupplements,
      // Outros
      'userRegion': data.userRegion,
      'groceryShoppingFrequency': data.groceryShoppingFrequency,
      'groceryNotificationSchedule': data.groceryNotificationSchedule?.map(
        (key, value) => MapEntry(key.toString(), value),
      ), // Map<int, String> precisa virar Map<String, dynamic> para Firestore
      'phoneNumber': data.phoneNumber,
      'selectedPlan': data.selectedPlan,
      'notificationsEnabled': data.notificationsEnabled,
      'isPremium': data.isPremium,
    };
  }
}
