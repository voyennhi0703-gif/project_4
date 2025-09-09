import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ← THÊM IMPORT
import 'package:period_tracket/common/colo_extension.dart';
import 'package:period_tracket/views/on_boarding/on_boarding_flow.dart';
import 'package:period_tracket/views/on_boarding/started_view.dart';
import 'package:period_tracket/views/main_tab/main_tab_view.dart';
import 'package:period_tracket/views/data/data_manager.dart'; // ← THÊM IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo DataManager
  final dataManager = DataManager();
  await dataManager.initialize();

  runApp(MyApp(dataManager: dataManager));
}

class MyApp extends StatelessWidget {
  final DataManager dataManager;
  const MyApp({super.key, required this.dataManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: dataManager)],
      child: MaterialApp(
        title: 'Period Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: TColor.primaryColor1,
          fontFamily: "Poppins",
          // Add some additional theme configurations for consistency
          colorScheme: ColorScheme.fromSeed(
            seedColor: TColor.primaryColor1,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        // Set initial route
        initialRoute: '/',

        // Define routes
        routes: {
          '/': (context) => const StartedView(),
          '/onboarding': (context) => const OnboardingFlow(),
          '/home': (context) => const MainTabView(),
        },

        // Handle unknown routes - fallback to home
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const StartedView());
        },

        // Optional: Handle route generation for more complex navigation
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (context) => const StartedView(),
              );
            case '/onboarding':
              return MaterialPageRoute(
                builder: (context) => const OnboardingFlow(),
              );
            case '/home':
              return MaterialPageRoute(
                builder: (context) => const MainTabView(),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const StartedView(),
              );
          }
        },
      ),
    );
  }
}
