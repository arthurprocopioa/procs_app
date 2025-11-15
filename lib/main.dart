import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:procs_ai/features/onboarding/presentation/screens/checkout_screen.dart';

// V3.5.8 (REMOVIDO) Facebook
// import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:provider/provider.dart';

// Nossas classes de fundação V3
import 'firebase_options.dart';
import 'core/services/analytics_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/application/onboarding_provider.dart';
// V3.5.10 (REMOVIDO) AuthService
// import 'core/services/auth_service.dart';
// V3.5.10 (REMOVIDO) FirebaseAuth
// import 'package:firebase_auth/firebase_auth.dart';

// Importação da tela de boas-vindas
import 'features/onboarding/presentation/screens/welcome_screen.dart';

/// V3.5.10 (FIX): Arquitetura de Provider (sem 'sl', 'locator' ou 'AuthService')
Future<
    ({
      AnalyticsService analyticsService,
      FirebaseAnalyticsObserver analyticsObserver
      // V3.5.10 (REMOVIDO) AuthService
      // AuthService authService
    })> _initializeServices(FirebaseApp app) async {
  // 1. Inicializa o Firebase (SEGURO E EXPLÍCITO)
  final firebaseAnalytics = FirebaseAnalytics.instanceFor(app: app);

  // 2. V3.5.8 (REMOVIDO) Facebook
  // const metaAnalytics = null;

  // 3. V3.5.8 (FIX): Passa 'null' para o metaAnalytics (Facebook)
  final analyticsService = AnalyticsService(firebaseAnalytics, null);
  final analyticsObserver =
      FirebaseAnalyticsObserver(analytics: firebaseAnalytics);

  // 4. V3.5.10 (REMOVIDO) AuthService
  // final authService = AuthService(FirebaseAuth.instanceFor(app: app));

  // 5. V3.5.10 (FIX): Retorna um "Record" (Tupla) sem o AuthService
  return (
    analyticsService: analyticsService,
    analyticsObserver: analyticsObserver
    // V3.5.10 (REMOVIDO) AuthService
    // authService: authService
  );
}

Future<void> main() async {
  // Garantir que os bindings do Flutter estejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 1. V3.5.5 (FIX 5): Captura a instância explícita do 'app'
  final FirebaseApp app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. V3.5.5 (FIX 5): Passa o 'app' para o inicializador
  final services = await _initializeServices(app);

  // TODO: Inicializar o RevenueCat (V3)

  // 3. V3.5.10 (FIX): Injeta os serviços (sem AuthService)
  runApp(MyApp(
    analyticsService: services.analyticsService,
    analyticsObserver: services.analyticsObserver,
    // V3.5.10 (REMOVIDO) AuthService
    // authService: services.authService,
  ));
}

class MyApp extends StatelessWidget {
  // V3.5.10 (FIX): Serviços injetados (Sem AuthService)
  final AnalyticsService analyticsService;
  final FirebaseAnalyticsObserver analyticsObserver;
  // V3.5.10 (REMOVIDO) AuthService
  // final AuthService authService;

  // V3.5.10 (FIX): Construtor (Sem AuthService)
  const MyApp({
    super.key,
    required this.analyticsService,
    required this.analyticsObserver,
    // V3.5.10 (REMOVIDO) AuthService
    // required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    // V3.5.5: (Igual ao V3.5.4)
    // MultiProvider é a raiz para o gerenciamento de estado
    return MultiProvider(
      providers: [
        // V3.5.5: Provedor do Analytics Service (Híbrido V3.3)
        Provider<AnalyticsService>.value(value: analyticsService),

        // V3.5.10 (REMOVIDO) AuthService
        // Provider<AuthService>.value(value: authService),

        // V3.4: Provider do Onboarding (V3 Imutável)
        ChangeNotifierProvider<OnboardingProvider>(
          create: (_) => OnboardingProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Procs AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,

        // V3.5.5: Usa o observer injetado (que já está pronto)
        navigatorObservers: [
          analyticsObserver,
        ],

        home: const CheckoutScreen(),
      ),
    );
  }
}
