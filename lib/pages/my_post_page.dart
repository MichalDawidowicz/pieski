import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/my_back3_button.dart';
import '../database/firestore.dart';

class MyPostPage extends StatelessWidget {
  final String title;
  final String message;
  final String userEmail;
  final String postID;
  MyPostPage({
    super.key, required this.title, required this.message, required this.userEmail, required this.postID});
  // Future String id;\
  final FirestoreDatabase database = FirestoreDatabase();

  void editPost(BuildContext context) {
    // Tutaj otwórz okno edycji postu, na przykład poprzez nawigację do innej strony
    // i przekazanie danych edytowanego postu.
    // Na potrzeby przykładu, tutaj po prostu cofnij nawigację.
    Navigator.pop(context);
  }
  void _deletePost(BuildContext context) {
    // Wyświetlenie okna dialogowego z potwierdzeniem usunięcia
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Potwierdzenie"),
          content: Text("Czy na pewno chcesz usunąć ogłoszenie?"),
          actions: [
            TextButton(
              onPressed: () {
                // Usunięcie wpisu z bazy danych i zamknięcie okna dialogowego
                database.deletePost(postID);
                Navigator.pop(context);
                Navigator.pop(context); // Zamknięcie MyPostPage po usunięciu
              },
              child: Text("Tak"),
            ),
            TextButton(
              onPressed: () {
                // Zamknięcie okna dialogowego
                Navigator.pop(context);
              },
              child: Text("Nie"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyBack3Button(),
                  // IconButton(onPressed: (){}, icon: Icon(Icons.settings),)
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: ()=> editPost, icon: Icon(Icons.edit)),
                IconButton(onPressed:()=>_deletePost(context), icon: Icon(Icons.delete))
              ],
            ),
            Text(
              "Tytuł: $title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Wiadomość: $message",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "ID: $postID",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
