import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/auth/login_or_register.dart';
import 'package:ogloszenia/pages/post_page.dart';
import 'package:ogloszenia/pages/users_page.dart';


class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            return  UsersPage();
          }else{
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
