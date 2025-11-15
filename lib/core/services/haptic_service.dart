import 'package:flutter/services.dart';

/// Wrapper de serviço para feedback tátil (Haptics) premium.
///
/// Abstrai as chamadas do sistema para facilitar o uso e a consistência
/// em todo o aplicativo, conforme o Documento Mestre de UX.
///
/// Substitui pacotes de terceiros, usando a implementação nativa do Flutter.
class HapticService {
  /// Feedback leve: Usado para seleções, checkboxes, sliders.
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Falha silenciosa. Não queremos quebrar a UX
      // se o dispositivo não suportar haptics.
      // debugPrint("HapticService (Light) Error: $e");
    }
  }

  /// Feedback médio: Usado para navegação, botões [Próximo].
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Falha silenciosa.
      // debugPrint("HapticService (Medium) Error: $e");
    }
  }

  /// Feedback pesado: Usado para eventos-chave (Manifesto, Pagamento).
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Falha silenciosa.
      // debugPrint("HapticService (Heavy) Error: $e");
    }
  }
}
