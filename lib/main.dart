import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/auth/auth.dart';
import 'package:ogloszenia/auth/login_or_register.dart';
import 'package:ogloszenia/firebase_options.dart';
import 'package:ogloszenia/pages/add_offer_page.dart';
import 'package:ogloszenia/pages/home_page.dart';
import 'package:ogloszenia/pages/my_page.dart';
import 'package:ogloszenia/pages/my_post_page.dart';
import 'package:ogloszenia/pages/offers_page.dart';
import 'package:ogloszenia/pages/post_page.dart';
import 'package:ogloszenia/pages/profile_page.dart';
import 'package:ogloszenia/pages/users_page.dart';
import 'package:ogloszenia/pages/wspolprace.dart';
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
      routes: {
        '/login_register_page':(context) => const LoginOrRegister(),
        '/home_page':(context) =>  HomePage(),
        '/profile_page':(context) =>  ProfilePage(),
        '/users_page':(context) =>  UsersPage(),
        '/offers':(context) =>  OffersPage(),
        '/add_offer':(context) =>  AddOffer(),
        // '/post_page':(context) => const PostPage(),
        // '/my_post_page':(context) => MyPostPage(),
        '/my_page':(context) =>  MyPage(),
        '/auth_page': (context) => AuthPage(),
        '/coop': (context) => Coop(),

      },
    );
  }
}
