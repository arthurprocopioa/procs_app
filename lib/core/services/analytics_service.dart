import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// V3.5.8 (REMOVIDO)
// import 'package:facebook_app_events/facebook_app_events.dart';

/// Serviço unificado de Analytics (Firebase + Meta Opcional).
class AnalyticsService {
  // Instâncias dos serviços (injetadas via main.dart)
  final FirebaseAnalytics _firebase;

  // V3.5.9 (FIX): Torna o Meta explicitamente nullable (dynamic?)
  final dynamic _meta;

  // V3.5.9 (FIX): O construtor agora aceita null para o _meta
  AnalyticsService(this._firebase, this._meta);

  /// Rastreia uma visualização de tela (Screen View) em ambas as plataformas.
  ///
  /// Ex: trackScreenView('welcome_screen')
  Future<void> trackScreenView(String screenName) async {
    try {
      // Firebase: usar logScreenView em vez de setCurrentScreen (deprecated)
      // Nota: assinatura: logScreenView({String? screenName, String? screenClass})
      await _firebase.logScreenView(screenName: screenName);

      // V3.5.8 (FIX): Adiciona null-check (?.)
      // Meta: log de evento customizado para screen view
      await _meta?.logEvent(name: 'screen_view', parameters: {
        'fb_screen_name': screenName,
      });
    } catch (e, st) {
      _logError('AnalyticsService (ScreenView)', e, st);
    }
  }

  /// Alias compatível com chamadas existentes no código.
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) =>
      trackEvent(name, parameters: parameters);

  /// Rastreia um evento customizado (Onboarding, Jogo, etc.) em ambas as plataformas.
  /// Filtra valores nulos antes de enviar ao Firebase (que aceita Map<String, Object>?).
  ///
  /// Ex: trackEvent('onboarding_started')
  Future<void> trackEvent(String name,
      {Map<String, Object?>? parameters}) async {
    try {
      final Map<String, Object>? safeParameters = parameters == null
          ? null
          : {
              for (final e in parameters.entries)
                if (e.value != null) e.key: e.value as Object
            };

      // 1. Firebase
      await _firebase.logEvent(name: name, parameters: safeParameters);

      // 2. V3.5.8 (FIX): Adiciona null-check (?.)
      final metaParams = _convertParametersForMeta(parameters);
      await _meta?.logEvent(name: name, parameters: metaParams);
    } catch (e, st) {
      _logError('AnalyticsService (Event)', e, st);
    }
  }

  /// Converte parâmetros para o formato aceito pelo Facebook/Meta.
  /// O SDK da Meta só aceita [String] ou [num] como valores.
  Map<String, dynamic>? _convertParametersForMeta(
      Map<String, Object?>? parameters) {
    if (parameters == null) return null;

    return parameters.map((key, value) {
      if (value is String || value is num) {
        return MapEntry(key, value);
      }
      // Converte qualquer outro tipo (bool, List, Map) para String.
      return MapEntry(key, value?.toString() ?? '');
    });
  }

  /// Helper privado para logar erros de analytics sem quebrar o app.
  void _logError(String context, Object e, StackTrace st) {
    // Não queremos que uma falha de analytics quebre o app em produção.
    // Usamos debugPrint para não poluir os logs de release.
    if (kDebugMode) {
      debugPrint('$context Error: $e\n$st');
    }
  }

  // TODO: Adicionar métodos específicos (ex: logPurchase, logLogin)
  // que podem ter lógica de negócios adicional antes de chamar trackEvent.
}
