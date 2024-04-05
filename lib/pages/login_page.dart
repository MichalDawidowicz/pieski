import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_button.dart';
import 'package:ogloszenia/components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  final void Function()? onTap;
  //text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key, this.onTap});
  
  void login(){
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // logo
            Icon(
              Icons.accessibility,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(height: 25),
            //app name
              Text("PIESKOWE OGŁOSZENIA", style: TextStyle(fontSize: 20),),
            const SizedBox(height: 25),
            //email textfield
            MyTextField(hintText: "Email", obscureText: false, controller: emailController),
            const SizedBox(height: 11),
            //password textfield
            MyTextField(hintText: "Hasło", obscureText: true, controller: passwordController),
            const SizedBox(height: 11),
            //forgot password
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Zresetuj hasło",
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              ],
            ),
            const SizedBox(height: 11),
            //zaloguj
            MyButton(text: "Zaloguj", onTap: login),
            const SizedBox(height: 11),
            //rejestracja
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text("Nie masz konta? "),
              GestureDetector(
                  onTap: onTap,
                  child: Text(" Zarejestruj się",style: TextStyle(fontWeight: FontWeight.bold),))
            ],)

          ]),
        ),
      ),
    );
  }
}
