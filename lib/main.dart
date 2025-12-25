import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/services/analytics_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/application/onboarding_provider.dart';
import 'core/providers/user_data_provider.dart';
import 'features/onboarding/presentation/screens/welcome_screen.dart'; // Tela de Login/Inicio
import 'features/home/presentation/main_wrapper.dart'; // Tela Principal
import 'features/onboarding/presentation/screens/terms_screen.dart'; // Inicio Onboarding

// V3.5.10 (FIX): Arquitetura de Provider
Future<
    ({
      AnalyticsService analyticsService,
      FirebaseAnalyticsObserver analyticsObserver
    })> _initializeServices(FirebaseApp app) async {
  final firebaseAnalytics = FirebaseAnalytics.instanceFor(app: app);
  final analyticsService = AnalyticsService(firebaseAnalytics, null);
  final analyticsObserver =
      FirebaseAnalyticsObserver(analytics: firebaseAnalytics);

  return (
    analyticsService: analyticsService,
    analyticsObserver: analyticsObserver
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseApp app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final services = await _initializeServices(app);

  runApp(MyApp(
    analyticsService: services.analyticsService,
    analyticsObserver: services.analyticsObserver,
  ));
}

class MyApp extends StatelessWidget {
  final AnalyticsService analyticsService;
  final FirebaseAnalyticsObserver analyticsObserver;

  const MyApp({
    super.key,
    required this.analyticsService,
    required this.analyticsObserver,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AnalyticsService>.value(value: analyticsService),
        ChangeNotifierProvider<OnboardingProvider>(
          create: (_) => OnboardingProvider(),
        ),
        ChangeNotifierProvider<UserDataProvider>(
          create: (_) => UserDataProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Procs AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'),
        ],
        navigatorObservers: [
          analyticsObserver,
        ],
        // Rotas nomeadas
        routes: {
          '/home': (context) => const MainWrapper(),
          '/onboarding': (context) => const TermsScreen(),
          '/login': (context) => const WelcomeScreen(),
        },
        // Entrada padrão (Guest First)
        home: const WelcomeScreen(),
      ),
    );
  }
}
