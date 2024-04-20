import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/my_back3_button.dart';
import '../database/firestore.dart';
import 'edit_my_post.dart';

class MyPostPage extends StatelessWidget {
  final String title;
  final String message;
  final String postID;
  final String photoUrl;
  MyPostPage({
    super.key, required this.title, required this.message, required this.postID, required this.photoUrl});
  // Future String id;\
  final FirestoreDatabase database = FirestoreDatabase();

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
            const Padding(
              padding: EdgeInsets.only(left: 20.0,right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyBack3Button(),
                  // IconButton(onPressed: (){}, icon: Icon(Icons.settings),)
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMyPostPage(
                        postID: postID,
                        oldPost: message,
                        oldTitle: title,
                        oldUrl: photoUrl,

                      ),
                    ),
                  );
                }, icon: Icon(Icons.edit)),
                IconButton(onPressed:()=>_deletePost(context), icon: Icon(Icons.delete))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "Wiadomość:  $message",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10.0),
                  // Wyświetlanie zdjęcia
                  if (photoUrl.isNotEmpty)
                    Image.network(
                      photoUrl,
                      width: MediaQuery.of(context).size.width, // Ustaw szerokość zdjęcia na pełną szerokość ekranu
                      height: 200.0, // Ustaw wysokość zdjęcia na 200 pikseli (możesz dostosować do własnych preferencji)
                      fit: BoxFit.cover, // Dopasuj zdjęcie do obszaru wyświetlania
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}