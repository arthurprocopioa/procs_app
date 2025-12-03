import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../onboarding/application/onboarding_provider.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final isPremium = provider.data.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (isPremium)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.star, color: Colors.amber),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isPremium ? 'Premium Access' : 'Free Access',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (!isPremium) const Text('Upgrade to unlock AI features!'),
          ],
        ),
      ),
    );
  }
}
