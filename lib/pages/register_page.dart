import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_button.dart';
import 'package:ogloszenia/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ogloszenia/helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  Future<void> register() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    //try to create user
    try {
      //create
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      //kolo
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Center(
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
              Text(
                "PIESKOWE OGŁOSZENIA",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 25),
              //email textfield
              MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController),
              const SizedBox(height: 11),
              //password textfield
              MyTextField(
                  hintText: "Hasło",
                  obscureText: true,
                  controller: passwordController),
              const SizedBox(height: 22),
              //zarejestruj
              MyButton(text: "Zarejestruj", onTap: register),
              const SizedBox(height: 11),
              //logowanie
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Mam już konto "),
                  GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        " Zaloguj się",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
