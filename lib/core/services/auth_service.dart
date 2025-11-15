import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// V3.1 (CORREÇÃO): Importa a biblioteca 'foundation' inteira,
// o que nos dá acesso a 'kDebugMode' E 'debugPrint'.
import 'package:flutter/foundation.dart';

/// V3.1: Repositório de Lógica de Autenticação.
///
/// Isto NÃO é um Provider. É uma classe de serviço simples
/// chamada diretamente pela UI (ex: welcome_screen.dart)
/// para executar a lógica de login e aderir à "Estrela Norte" V2.
class AuthServiceV3 {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // Usa instâncias padrão para simplicidade.
  AuthServiceV3({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Executa o fluxo de Login com Google.
  ///
  /// Retorna o [UserCredential] em sucesso (para a "Memória RAM" V3).
  /// Retorna `null` se o usuário cancelar ou se houver um erro.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Inicia o fluxo de login do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // 2. Se o usuário cancelar, retorna null
      if (googleUser == null) {
        // (Corrigido) Agora 'debugPrint' é reconhecido
        debugPrint('[AuthServiceV3] Login com Google cancelado pelo usuário.');
        return null;
      }

      // 3. Obtém os detalhes de autenticação (token)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 4. Cria a credencial do Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Faz o login no Firebase Auth (Custo Zero)
      // Isso SÓ cria o usuário no "Firebase Authentication",
      // NÃO escreve no "Firestore" (Banco de Dados).
      // Estamos 100% em conformidade com a "Estrela Norte" V2.
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // (Corrigido) Agora 'debugPrint' é reconhecido
      debugPrint(
          '[AuthServiceV3] Login com Google OK: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e, st) {
      // Trata erros específicos do Firebase
      // (Corrigido) 'kDebugMode' e 'debugPrint' funcionam
      if (kDebugMode) {
        debugPrint('[AuthServiceV3] FirebaseAuthException: $e\n$st');
      }
      return null;
    } catch (e, st) {
      // Trata outros erros (rede, etc.)
      if (kDebugMode) {
        debugPrint('[AuthServiceV3] Erro genérico de login: $e\n$st');
      }
      return null;
    }
  }

  // TODO (Feature 2): Adicionar signInWithApple() aqui.

  /// Helper de logout para testes.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      debugPrint('[AuthServiceV3] Usuário deslogado.');
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AuthServiceV3] Erro ao deslogar: $e\n$st');
      }
    }
  }
}
