import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase
import 'package:ogloszenia/components/back_to_offer_list.dart';
import 'package:ogloszenia/components/my_drawer.dart';
import 'package:ogloszenia/pages/edit_offer_page.dart';

import '../components/my_back2_button.dart';
import '../components/my_back_button.dart';

class OfferPage extends StatelessWidget {
  final String title;
  final String message;
  final String? userEmail;
  final String photoUrl;
  final String offerID;

  const OfferPage({
    Key? key,
    required this.title,
    required this.message,
    required this.userEmail,
    required this.photoUrl, required this.offerID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? loggedInUserEmail = FirebaseAuth.instance.currentUser?.email; // Adres email aktualnie zalogowanego użytkownika

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
                  const BackToOffList(),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "OFERTA",
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
                    "Opis:  $message",
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
                      width: MediaQuery.of(context).size.width,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  SizedBox(height: 10.0),
                  // Dodaj warunek wyświetlania przycisku "Edytuj ofertę"
                  if (loggedInUserEmail != null && loggedInUserEmail == userEmail)
                    GestureDetector(child: Text("Edytuj ofertę"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMyOfferPage(
                              oldTitle: title,
                              oldPost: message,
                              oldUrl: photoUrl,
                              postID: offerID,
                            ),
                          ),
                        );
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
