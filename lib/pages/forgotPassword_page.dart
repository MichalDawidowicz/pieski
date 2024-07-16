import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/my_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final _emailController=TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset()async{
    try{await FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailController.text.trim());
    showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Text("Wysłano email z linkiem do resetu hasła"),
      );
    });
    }on FirebaseAuthException catch (e){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text(e.message.toString()),
        );
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Wpisz adres email do zresetowania hasła"),
          const SizedBox(height: 11),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: MyTextField(hintText: "Email", obscureText: false, controller: _emailController),
          ),
          const SizedBox(height: 11),
          MaterialButton(
            onPressed: passwordReset,
            child: Text("Zresetuj hasło"),
          color: Colors.deepPurpleAccent,)
        ],
      ),

    );
  }
}
