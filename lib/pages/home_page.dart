import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_drawer.dart';
import 'package:ogloszenia/components/my_post_button.dart';
import 'package:ogloszenia/components/my_textfield.dart';
import 'package:ogloszenia/database/firestore.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FirestoreDatabase database = FirestoreDatabase();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController postController = TextEditingController();

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage(){
    //post only if title and message is not empty
    if(titleController.text.isNotEmpty && postController.text.isNotEmpty){
      String title = titleController.text;
      String post = postController.text;
      database.addPost(title, post);
    }
    titleController.clear();
    postController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DODAJ OGŁOSZENIE"),
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
            child: MyTextField(
              hintText: "Tresc",
              obscureText: false,
              controller: postController,
            ),
          ),
          PostButton(
            onTap: postMessage,
          ),
        ],
      ),
    );
  }
}
