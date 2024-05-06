import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_drawer.dart';

import '../components/my_back2_button.dart';
import '../components/my_back_button.dart';
import '../database/firestore.dart';

class PostPage extends StatelessWidget {
  final String title;
  final String message;
  final String userEmail;
  final String photoUrl;
  final String id;
  const PostPage({super.key, required this.title, required this.message, required this.userEmail, required this.photoUrl, required this.id});
  // Future String id;

  @override
  Widget build(BuildContext context) {
    final FirestoreDatabase database = FirestoreDatabase();
    String? loggedInUserEmail = FirebaseAuth.instance.currentUser?.email;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyBack2Button(),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "OGŁOSZENIE",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
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
                  Text(
                    "Adres email: $userEmail",
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
                  SizedBox(height: 10.0),
                  // Dodaj warunek wyświetlania przycisku "Edytuj ofertę"
                  if (loggedInUserEmail != null && loggedInUserEmail != userEmail)
                    GestureDetector(child: Text("Zgłoś chęć"),
                      onTap: () {
                        database.changeState(id, "zarezerwowane");
                        Navigator.pushNamed(context, '/users_page');
                      },),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}