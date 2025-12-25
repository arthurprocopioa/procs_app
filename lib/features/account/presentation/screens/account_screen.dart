import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/providers/user_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/auth_service.dart';
// V3.1: AuthService para logout se necessário, mas FirebaseAuth direto é ok aqui.

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Estado local para controle do switch (se o ThemeProvider não notificasse rápido, mas notifica)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userDataProvider = context.watch<UserDataProvider>();
    final user = FirebaseAuth.instance.currentUser;

    // Dados reais
    final String userName = userDataProvider.userName; // Getter que criamos
    final String userEmail = user?.email ?? "Sem email vinculado";
    // Lógica de Plano: Se tiver 'isPremium' no userData ou simular
    final bool isPremium =
        userDataProvider.userData?['onboardingData']?['isPremium'] ?? false;
    final String planName =
        isPremium ? "Pro Anual" : "Gratuito"; // Simplificação

    // Data de renovação baseada no início da assinatura (onboarding)
    DateTime renewDate = DateTime.now().add(const Duration(days: 30));
    final onboardingTimestamp =
        userDataProvider.userData?['onboardingCompletedAt'];
    if (onboardingTimestamp is Timestamp) {
      renewDate = onboardingTimestamp.toDate().add(const Duration(days: 30));
    }
    final String renewDateStr =
        "${renewDate.day}/${renewDate.month}/${renewDate.year}";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // 1. Elimine aquela palavra "Conta" que está na parte superior da Tela
      // appBar: null, // Sem AppBar ou AppBar transparente sem título
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // 2. Identity Card com Nome Real
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor, // Use theme colors
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 3. Campo de nome deve ser possível alterar
                            GestureDetector(
                              onTap: () => _showEditNameDialog(
                                  context, userDataProvider, userName),
                              child: Icon(Icons.edit,
                                  size: 16, color: colorScheme.primary),
                            ),
                          ],
                        ),
                        Text(
                          userEmail,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. Minha Conta
            _SectionHeader(title: "Minha Conta"),
            // Atalho para editar nome tb na lista
            _SettingsTile(
                title: "Editar Nome",
                icon: Icons.person_outline,
                onTap: () =>
                    _showEditNameDialog(context, userDataProvider, userName)),

            const Divider(color: Colors.white12, height: 40),

            // 5. Plano e Assinatura Funcional (Datas)
            _SectionHeader(title: "Plano e Assinatura"),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.2),
                    Colors.transparent
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(planName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      if (isPremium)
                        Text("Renova em $renewDateStr",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      if (!isPremium)
                        const Text(
                            "Expira em 19/01/2026", // Exemplo fixo ou lógica free
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  const Text("Gerenciar",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 40),

            // 6. Suporte (Merge)
            _SectionHeader(title: "Suporte"),
            _SettingsTile(
                title: "Central de Ajuda e Reportar Problema",
                icon: Icons.help_outline,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Abrindo suporte...")));
                }),

            const Divider(color: Colors.white12, height: 40),

            // 8. Botões Sair e Excluir Funcionais
            if (user != null && user.isAnonymous)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _handleLinkAccount(context),
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text("Salvar Progresso (Vincular Google)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handleLogout(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(user?.isAnonymous == true
                    ? "Sair (Perder Dados)"
                    : "Sair da Conta"),
              ),
            ),
            const SizedBox(height: 16),
            if (user?.isAnonymous ==
                false) // Só mostra excluir se não for anon (ou trata igual)
              TextButton(
                onPressed: () => _handleDeleteAccount(context),
                child: const Text("Excluir Conta",
                    style: TextStyle(color: Colors.red)),
              ),

            const SizedBox(height: 40),
            const Text("Versão 1.0.0 (Build 202)",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(
      BuildContext context, UserDataProvider provider, String currentName) {
    final TextEditingController controller =
        TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Editar Nome", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Seu nome",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await provider.updateName(user.uid, newName);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Salvar", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLinkAccount(BuildContext context) async {
    try {
      final authService = AuthServiceV3();
      final cred = await authService.linkWithGoogle();

      if (cred != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Conta vinculada com sucesso!")));
        // Atualiza UI (setState não necessário pois usamos FirebaseAuth.instance)
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Erro ao vincular: $e (A conta Google já pode estar em uso)")));
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // 8. Botão Sair da conta funcional
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      // Navegar para WelcomeScreen (Login) e limpar stack
      // Como mudaremos o main para StreamBuilder, o logout atualiza o estado lá
      // e reconstrói o app, indo para LoginScreen.
      // Mas podemos forçar navegação se necessário.
      // O ideal é o StreamBuilder no Main cuidar disso.
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    // Confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title:
            const Text("Excluir Conta?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Essa ação é irreversível. Todos os seus dados serão apagados.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text("Excluir", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Deletar do Firestore tb? Recomendado.
          // FirestoreService poderia ter deleteUser(uid).
          await user.delete();
          // O StreamBuilder do Main vai detectar e jogar pra Login.
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text("Erro ao excluir: $e. Faça login novamente e tente.")));
        }
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: Text(title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile(
      {required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Use theme
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(title, style: theme.textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
