import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  // binding for the widget tree
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    //data persistence on disk using river_pod
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {          
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {   
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mindful Calories',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 21, 105, 214),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 21, 105, 214),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ref.watch(themeModeProvider),          
      home: const HomeScreen(),
    );
  }
}