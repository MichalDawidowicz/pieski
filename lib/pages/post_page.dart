import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_drawer.dart';

import '../components/my_back2_button.dart';
import '../components/my_back_button.dart';

class PostPage extends StatelessWidget {
  final String title;
  final String message;
  final String userEmail;
  const PostPage({super.key, required this.title, required this.message, required this.userEmail});
  // Future String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text("OGŁOSZENIE"),
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyBack2Button(),
                  IconButton(onPressed: (){}, icon: Icon(Icons.settings),)
                ],
              ),
            ),
            Text(
              "$title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Wiadomość:  $message",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Adres email: $userEmail",
              style: TextStyle(fontSize: 16),
            ),

            //Wyswietlanie danych o poscie
          ],
        ),
      ),
    );
  }
}
