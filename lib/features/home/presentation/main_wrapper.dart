import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import '../../../core/providers/user_data_provider.dart'; // Import Provider
import '../../logic/presentation/screens/logic_screen.dart';
import '../../nutrition/presentation/screens/nutrition_screen.dart';
import '../../workout/presentation/screens/workout_screen.dart';
import '../../account/presentation/screens/account_screen.dart';
import '../../../core/theme/app_theme.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // V3: Garantir que os dados sejam inicializados ao entrar na Home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<UserDataProvider>().listenToUser(user.uid);
      }
    });
  }

  final List<Widget> _screens = [
    const LogicScreen(),
    const NutritionScreen(),
    const WorkoutScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainer, // Subtle divider
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined),
              activeIcon: Icon(Icons.psychology),
              label: 'Lógica',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'Dieta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Treino',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Conta',
            ),
          ],
        ),
      ),
    );
  }
}
