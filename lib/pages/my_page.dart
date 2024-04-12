import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_textfield.dart';
import 'package:ogloszenia/helper/helper_functions.dart';

import '../components/my_back_button.dart';
import '../database/firestore.dart';
/*
TODO: Wyświetla ogłoszenia uzytkownika, po kliknieciu w nie mozna edytowac,
zmienić ekran dodawania, zmienic ekran startowy na listę ogłoszeń
ekran dodawania ogłoszenia = ekran edycji
dodawanie zdjęć
 */
class MyPage extends StatelessWidget {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController editingController = TextEditingController();
  MyPage({super.key});
  void updateMessage(String? docID, String message) {
    //post only if title and message is not empty
    if (editingController.text.isNotEmpty && docID != null) {
      String post = editingController.text;
      database.updatePost(docID, post);
    }
    editingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("Users").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              displayMessageToUser("Coś poszło nie tak", context);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == null) {
              return const Text("Brak danych");
            }
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 50.0, left: 25),
                  child: Row(
                    children: [
                      MyBackButton(),
                    ],
                  ),
                ),
                Expanded(
                    child: StreamBuilder(
                      stream: database.getPostStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final posts = snapshot.data!.docs;
                        if (snapshot.data == null || posts.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(25),
                              child: Text("Brak danych"),
                            ),
                          );
                        }
                        return Expanded(
                            child: ListView.builder(
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot document = posts[index];
                                  String docID = document.id;

                                  final post = posts[index];
                                  String title = post['PostTitle'];
                                  String message = post['PostMessage'];
                                  String userEmail = post['UserEmail'];

                                  return GestureDetector(
                                    child: ListTile(
                                      title: Text(title),
                                      subtitle: Text(message + "\n" + userEmail),
                                      trailing: IconButton(
                                        onPressed: () {
                                          if (userEmail ==
                                              FirebaseAuth.instance.currentUser!
                                                  .email) {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                  content: MyTextField(
                                                    hintText:
                                                    "Nowa treść",
                                                    obscureText: false,
                                                    controller:
                                                    editingController,
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: () =>
                                                            database.deletePost(docID),
                                                        child: Text(
                                                            "Usuń ogłoszenie",
                                                            style: TextStyle(
                                                                color: Theme.of(context)
                                                                    .colorScheme
                                                                    .secondary))),
                                                    ElevatedButton(
                                                        onPressed: () =>
                                                            updateMessage(
                                                              docID,
                                                              editingController
                                                                  .text,
                                                            ),
                                                        child: Text(
                                                            "zapisz",
                                                            style: TextStyle(
                                                                color: Theme.of(context)
                                                                    .colorScheme
                                                                    .inversePrimary))),
                                                  ],
                                                ));
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                  content: Text(
                                                      "Nie masz uprawnień do edycji."),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Text(
                                                            "Zamknij",
                                                            style: TextStyle(
                                                                color: Theme.of(context)
                                                                    .colorScheme
                                                                    .inversePrimary))),
                                                  ],
                                                ));
                                          }
                                        },
                                        icon: Icon(Icons.settings),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.pushNamed(context, '/post_page');
                                      },
                                    ),
                                  );
                                }));
                      },
                    )),
              ],
            );
          }),
    );
  }

// void onTap() {
//   Navigator.pop(context);
//   Navigator.pushNamed(context, '/users_page');
// }
}
