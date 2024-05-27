import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/backToMyPage.dart';
import 'package:ogloszenia/pages/wolontariusz.dart';

import '../database/firestore.dart';
import 'edit_my_post.dart';

class MyPostPage extends StatelessWidget {
  final String title;
  final String message;
  final String postID;
  final String photoUrl;
  final String state;
  final String vol;

  MyPostPage({
    super.key,
    required this.title,
    required this.message,
    required this.postID,
    required this.photoUrl,
    required this.state,
    required this.vol,
  });

  final FirestoreDatabase database = FirestoreDatabase();

  void _deletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Potwierdzenie"),
          content: Text("Czy na pewno chcesz usunąć ogłoszenie?"),
          actions: [
            TextButton(
              onPressed: () {
                database.deletePost(postID);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Tak", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Nie", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _endCooperation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Zakończenie współpracy"),
          content: Text("Czy na pewno chcesz zakończyć współpracę?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Zamknięcie okna dialogowego potwierdzenia
                _addOpinion(context); // Wywołanie metody do dodania opinii
              },
              child: Text("Tak", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Zamknięcie okna dialogowego
              },
              child: Text("Nie", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }


  void _addOpinion(BuildContext context) {
    TextEditingController starsController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Dodaj opinię"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: starsController,
                  decoration: InputDecoration(labelText: 'Liczba gwiazdek (0-5)'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Opis (opcjonalnie)'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                int stars = int.tryParse(starsController.text) ?? 0;
                String description = descriptionController.text.trim();

                // Sprawdzanie, czy liczba gwiazdek mieści się w zakresie 0-5
                if (stars >= 0 && stars <= 5) {
                  // Dodanie opinii do bazy danych
                  database.addOpinion(vol, stars, description).then((_) {
                    // Po dodaniu opinii, aktualizacja stanu ogłoszenia i nawigacja do strony my_page
                    database.updateState(postID, 'nowe');
                    Navigator.pushNamed(context, '/my_page');
                  });
                  Navigator.pop(context); // Zamknięcie okna dialogowego
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Liczba gwiazdek musi być w zakresie od 0 do 5.'),
                  ));
                }
              },
              child: Text("Dodaj"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Zamknięcie okna dialogowego
              },
              child: Text("Anuluj"),
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
              padding: EdgeInsets.only(left: 20.0, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackToMyPage(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMyPostPage(
                          postID: postID,
                          oldPost: message,
                          oldTitle: title,
                          oldUrl: photoUrl,
                          state: state,
                          vol: vol,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () => _deletePost(context),
                  icon: Icon(Icons.delete),
                )
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
                  if (photoUrl.isNotEmpty)
                    Image.network(
                      photoUrl,
                      width: MediaQuery.of(context).size.width,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  SizedBox(height: 20.0),
                  if (state == 'zarezerwowane' || state == 'sprzedano')
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Wolontariusz(userEmail: vol),
                              ),
                            );
                          },
                          child: Text(
                            'Wolontariusz: $vol',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        if (state == 'zarezerwowane')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  database.updateState(postID, 'sprzedano');
                                  Navigator.pushNamed(context, '/my_page');
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 10.0)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                  ),
                                ),
                                child: Text('Zaakceptuj współpracę', style: TextStyle(color: Colors.black)),
                              ),
                              SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: () {
                                  database.updateState(postID, 'nowe');
                                  Navigator.pushNamed(context, '/my_page');
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  side: BorderSide(color: Colors.black),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                                child: Text('Odrzuć współpracę', style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        if (state == 'sprzedano')
                          Center(
                            child: ElevatedButton(
                              onPressed: () => _endCooperation(context),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 10.0)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                              ),
                              child: Text('Zakończ współpracę', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                      ],
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
