import 'package:flutter/material.dart';
import '../widgets/logic_card.dart';
import '../screens/logic_detail_screen.dart';

class LogicScreen extends StatelessWidget {
  const LogicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Lógica', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading:
            const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // BLOCO 1: Treino Logic
            const LogicCard(
              title: "Por que seu treino é assim?",
              description:
                  "Seu treino deste mês foi estruturado com base na sobrecarga progressiva...",
              icon: Icons.fitness_center,
              detailContent:
                  "TEXTO COMPLETO DA IA SOBRE O TREINO...\n\n(Aqui viria o texto gerado na anamnese)",
            ),

            // BLOCO 2: Diet Logic
            const LogicCard(
              title: "Por que sua dieta é assim?",
              description:
                  "Sua dieta foi calculada focando em um superávit leve para ganho seco...",
              icon: Icons.restaurant_menu,
              detailContent:
                  "TEXTO COMPLETO DA IA SOBRE A DIETA...\n\n(Aqui viria o texto gerado na anamnese)",
            ),

            // BLOCO 3: Monthly Report
            // Custom Card for Report as it looks different (more visual)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Material(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LogicDetailScreen(
                          title: "Relatório Mensal",
                          content:
                              "Aqui ficaria o relatório detalhado de progresso...",
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bar_chart,
                                color: Colors.blueAccent, size: 24),
                            SizedBox(width: 12),
                            Text(
                              "Relatório do Mês",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _ReportMetric(label: "Dias Treinados", value: "12"),
                            _ReportMetric(label: "Consistência", value: "82%"),
                            _ReportMetric(
                                label: "Resultado", value: "🔥 Muito bom"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Ver relatório completo →",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // BLOCO 4: Biblioteca de Conceitos
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Biblioteca de Conceitos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _ConceptTile(title: "Sobrecarga Progressiva", onTap: () {}),
                _ConceptTile(title: "Proteína e Hipertrofia", onTap: () {}),
                _ConceptTile(title: "Sono e Recuperação", onTap: () {}),
                _ConceptTile(title: "Hidratação", onTap: () {}),
                _ConceptTile(title: "Consistência", onTap: () {}),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      "Ver todos...",
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ReportMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
      ],
    );
  }
}

class _ConceptTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ConceptTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
