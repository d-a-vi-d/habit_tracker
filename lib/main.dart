import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_shell.dart';
import 'utils/themes.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Habit Tracker', theme: Themes.light, home: const AppShell());
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load();
  // final supabaseUrl = dotenv.get('SUPABASE_URL');
  // final anonKey = dotenv.get('SUPABASE_ANON_KEY');

  await Supabase.initialize(url: 'supabaseUrl', publishableKey: 'anonKey');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.lightBlue[100],
        colorScheme:
            ColorScheme.fromSwatch(
              primarySwatch: Colors.lightBlue,
              brightness: Brightness.light,
            ).copyWith(
              secondary: Colors.lightGreen[100],
              surface: Colors.grey[200],
              onPrimary: Colors.black87,
              onSecondary: Colors.black87,
              onSurface: Colors.black87,
            ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.lightBlue[100],
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.lightBlue[800]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen[300],
            foregroundColor: Colors.black87,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.lightBlue[300],
          inactiveTrackColor: Colors.lightBlue[100],
          thumbColor: Colors.lightBlue[300],
          overlayColor: Colors.lightBlue[100]?.withOpacity(0.2),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey[900],
        colorScheme:
            ColorScheme.fromSwatch(
              primarySwatch: Colors.blueGrey,
              brightness: Brightness.dark,
            ).copyWith(
              secondary: Colors.teal[200],
              surface: Colors.grey[800],
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.white,
            ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          color: Colors.blueGrey[900],
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.teal[200]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal[700],
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.teal[700],
          inactiveTrackColor: Colors.teal[200],
          thumbColor: Colors.teal[700],
          overlayColor: Colors.teal[200]?.withOpacity(0.2),
        ),
      ),
      themeMode: _themeMode,
      home: HomeScreen(toggleThemeMode: _toggleThemeMode),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final PageController _pageController = PageController();
  final VoidCallback toggleThemeMode;

  HomeScreen({super.key, required this.toggleThemeMode});

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: [
        TriggerScreen(pageController: _pageController, toggleThemeMode: toggleThemeMode),
        SymptomScreen(pageController: _pageController, toggleThemeMode: toggleThemeMode),
        OverviewScreen(pageController: _pageController, toggleThemeMode: toggleThemeMode),
      ],
    );
  }
}
