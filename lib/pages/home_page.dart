import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_drawer.dart';
import 'package:ogloszenia/components/my_post_button.dart';
import 'package:ogloszenia/components/my_textfield.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final TextEditingController titleController = TextEditingController();
  final TextEditingController postController = TextEditingController();

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ogłoszenia"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          //logout
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout),
          )
        ],
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: MyTextField(
              hintText: "Tytuł",
              obscureText: false,
              controller: titleController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Expanded(
              child: MyTextField(
                hintText: "Tresc",
                obscureText: false,
                controller: postController,
              ),
            ),
          ),
          PostButton()
        ],
      ),
    );
  }
}
