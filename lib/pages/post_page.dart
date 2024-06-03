import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/back_to_home.dart';
import 'package:ogloszenia/components/my_drawer.dart';

import '../components/my_back2_button.dart';
import '../components/my_back_button.dart';
import '../database/firestore.dart';

class PostPage extends StatelessWidget {
  final String title;
  final String message;
  final String userEmail;
  final String id;
  const PostPage(
      {Key? key,
      required this.title,
      required this.message,
      required this.userEmail,
      required this.id});

  @override
  Widget build(BuildContext context) {
    final FirestoreDatabase database = FirestoreDatabase();
    String? loggedInUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: database.getPostState(id),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              String postState = snapshot.data ?? "";
              bool isPostReserved = postState == "zarezerwowane";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BackToHome(),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "ogłoszenie",
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
// Galeria zdjęć z kolekcji 'Photos'
                        FutureBuilder<List<String>>(
                          future: database.getPhotosForPost(id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              // Dodaj warunek sprawdzający czy snapshot zawiera dane
                              List<String>? photoUrls = snapshot.data;
                              if (photoUrls != null && photoUrls.isNotEmpty) {
                                return SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: photoUrls.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Image.network(
                                          photoUrls[index],
                                          width: 150,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return SizedBox
                                    .shrink(); // Brak zdjęć, zwróć pusty widżet
                              }
                            } else {
                              return Text(
                                  'Brak danych zdjęć'); // Dodaj komunikat informujący o braku danych
                            }
                          },
                        ),

                        SizedBox(height: 10.0),
                        // Dodaj warunek wyświetlania przycisku "Edytuj ofertę"
                        if (isPostReserved)
                          Text(
                            "Zarezerwowane",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        if (!isPostReserved &&
                            loggedInUserEmail != null &&
                            loggedInUserEmail != userEmail)
                          GestureDetector(
                            child: Text("Zgłoś chęć"),
                            onTap: () {
                              database.changeState(
                                  id, "zarezerwowane", loggedInUserEmail);
                              Navigator.pushNamed(context, '/users_page');
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
