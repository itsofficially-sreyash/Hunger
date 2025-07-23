import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/Pages/screens/auth/login_screen.dart';
import 'package:food_delivery_app/Pages/screens/auth/signup_screen.dart';
import 'package:food_delivery_app/Pages/screens/home/app_main_screen.dart';
import 'package:food_delivery_app/Pages/screens/home/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top], // Keep only status bar
  );
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  const supabaseUrl = "https://koqcrhmuprjomjsmdiwf.supabase.co";
  final supabaseKey = dotenv.env["SUPABASE_KEY"]!;
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: AuthCheck(),
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  final supaBase = Supabase.instance.client;
  AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: supaBase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supaBase.auth.currentSession;
        if (session != null) {
          return AppMainScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
