import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp() is called here but will only work once
  // google-services.json is added by the user. We wrap in try/catch
  // so the app still launches during development without Firebase configured.
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured yet — app runs in offline-only mode
  }
  runApp(const ProviderScope(child: MyYnabApp()));
}

class MyYnabApp extends StatelessWidget {
  const MyYnabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyYNAB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B6CA8),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B6CA8),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('MyYNAB — setting up...'),
        ),
      ),
    );
  }
}
