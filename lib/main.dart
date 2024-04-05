import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/auth/auth.dart';
import 'package:ogloszenia/firebase_options.dart';
import 'package:ogloszenia/theme/dark_mode.dart';
import 'package:ogloszenia/theme/light_mode.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
