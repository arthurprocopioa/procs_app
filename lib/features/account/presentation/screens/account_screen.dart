import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user state
    const bool isLoggedIn = true; // Toggle to test
    const String userName = "Procópio Silva";
    const String userEmail = "procopio@gmail.com";
    const String planName = "Pro Anual";

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Conta', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button on main tab
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Identity Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: isLoggedIn
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: colorScheme.primary,
                          child: Text(userName[0],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.black)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(userName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Icon(Icons.edit,
                                      size: 14,
                                      color: colorScheme.primary), // Edit hint
                                ],
                              ),
                              Text(userEmail,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Icon(Icons.warning_amber,
                            color: Colors.orange, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          "Faça login para salvar seu progresso",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _LoginButton(
                            icon: Icons.apple,
                            label: "Entrar com Apple",
                            onTap: () {}),
                        const SizedBox(height: 8),
                        _LoginButton(
                            icon: Icons.g_mobiledata,
                            label: "Entrar com Google",
                            onTap: () {}),
                      ],
                    ),
            ),

            const SizedBox(height: 32),

            // 2. Minha Conta
            _SectionHeader(title: "Minha Conta"),
            _SettingsTile(
                title: "Editar Nome", icon: Icons.person_outline, onTap: () {}),
            _SettingsTile(
                title: "Privacidade e Segurança",
                icon: Icons.lock_outline,
                onTap: () {}),
            SwitchListTile(
              title: const Text("Tema Escuro",
                  style: TextStyle(color: Colors.white)),
              secondary:
                  const Icon(Icons.dark_mode_outlined, color: Colors.white),
              value: true,
              onChanged: (val) {},
              activeColor: colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(color: Colors.white12, height: 40),

            // 3. Plano e Assinatura
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
                      const Text("Renova em 15/05/2026",
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
            _SettingsTile(
                title: "Histórico de Pagamentos",
                icon: Icons.receipt_long,
                onTap: () {}),

            const Divider(color: Colors.white12, height: 40),

            // 4. Dados e Backup
            _SectionHeader(title: "Dados e Backup"),
            _SettingsTile(
                title: "Exportar Dados", icon: Icons.download, onTap: () {}),
            _SettingsTile(
                title: "Backup", icon: Icons.cloud_upload, onTap: () {}),

            const Divider(color: Colors.white12, height: 40),

            // 5. Suporte
            _SectionHeader(title: "Suporte"),
            _SettingsTile(
                title: "Central de Ajuda",
                icon: Icons.help_outline,
                onTap: () {}),
            _SettingsTile(
                title: "Reportar Problema",
                icon: Icons.bug_report_outlined,
                onTap: () {}),

            const Divider(color: Colors.white12, height: 40),

            // 6. Legal
            _SectionHeader(title: "Legal"),
            _SettingsTile(
                title: "Termos de Uso",
                icon: Icons.description_outlined,
                onTap: () {}),
            _SettingsTile(
                title: "Política de Privacidade",
                icon: Icons.privacy_tip_outlined,
                onTap: () {}),

            const SizedBox(height: 40),

            // 7. Actions
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Sair da Conta"),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text("Excluir Conta",
                  style: TextStyle(color: Colors.red)),
            ),

            const SizedBox(height: 40),
            const Text("Versão 1.0.0 (Build 200)",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
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
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}

class _LoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LoginButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black),
        label: Text(label,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Custom standard
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}
