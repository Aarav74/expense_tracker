import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/budget_history_entry.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/add_expense_screen.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/services/database_service.dart';
import 'package:expense_tracker/services/notification_service.dart';
import 'package:expense_tracker/services/currency_service.dart';
import 'package:expense_tracker/services/sound_service.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  try {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(BudgetHistoryEntryAdapter());
    
    // Open required boxes
    final expenseBox = await Hive.openBox<Expense>('expenses');
    final archiveBox = await Hive.openBox<List<Expense>>('expenses_archive');
    final budgetBox = await Hive.openBox<double>('monthly_budget');
    final currencyBox = await Hive.openBox<String>('currency_preferences');
    final budgetHistoryBox = await Hive.openBox<BudgetHistoryEntry>('budget_history');
    
    // Initialize services
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.requestPermissions();
    final currencyService = CurrencyService(currencyBox);
    final soundService = SoundService();
    await soundService.initialize();

    // Verify sound file exists
    try {
      await rootBundle.load('assets/sounds/coin.wav');
      debugPrint('Sound file loaded successfully');
    } catch (e) {
      debugPrint('Error loading sound file: $e');
    }

    // Run the app with providers
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => DatabaseService(
              expenseBox: expenseBox,
              archiveBox: archiveBox,
              budgetBox: budgetBox,
              budgetHistoryBox: budgetHistoryBox,
              notificationService: notificationService,
              currencyService: currencyService,
              soundService: soundService,
            ),
            lazy: false,
          ),
          ChangeNotifierProvider.value(value: currencyService),
          Provider.value(value: notificationService),
          Provider.value(value: soundService),
        ],
        child: const MyApp(),
      ),
    );
  } catch (error, stackTrace) {
    // Error handling for initialization
    debugPrint('Initialization error: $error');
    debugPrint(stackTrace.toString());
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red[100],
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Error: ${error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // Route configuration
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add-expense': (context) => const AddExpenseScreen(),
      },
      
      // Fallback for unknown routes
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      },
      
      // Global navigator key
      navigatorKey: NavigationService.navigatorKey,
    );
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = 
      GlobalKey<NavigatorState>();
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      shape: CircleBorder(),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      surfaceTintColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.grey[50],
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      shape: CircleBorder(),
      backgroundColor: Colors.deepPurpleAccent,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.grey[800],
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      tileColor: Colors.grey[850],
    ),
  );
}