import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/backToMyPage.dart';
import 'package:ogloszenia/pages/opinie.dart';

class Wolontariusz extends StatefulWidget {
  final String userEmail; // Zmieniamy typ na String

  Wolontariusz({Key? key, required this.userEmail}) : super(key: key);

  @override
  _WolontariuszState createState() => _WolontariuszState();
}

class _WolontariuszState extends State<Wolontariusz> {
  bool isLoading = false; // Dodajemy zmienną do śledzenia stanu ładowania

  // Przyszłość do pobrania szczegółów użytkownika
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget
            .userEmail) // Używamy widget.currentUserEmail jako adresu e-mail
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          // Ładowanie
          if (snapshot.connectionState == ConnectionState.waiting ||
              isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Błąd
          else if (snapshot.hasError) {
            return Text("Błąd: ${snapshot.error}");
          }
          // Dane
          else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            return Center(
              child: Column(
                children: [
                  // Przycisk powrotu
                  const Padding(
                    padding: EdgeInsets.only(top: 50.0, left: 25),
                    child: Row(
                      children: [
                        BackToMyPage(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // Tekst profilowy
                  const Text(
                    "Profil",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black26,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Adres e-mail
                  Text(
                    user!['email'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  // Pole 'Info'
                  if (user.containsKey('Info'))
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        user['Info'],
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    child: Text('Opinie'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OpiniePage(userEmail: widget.userEmail),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return Text("Brak opisu");
          }
        },
      ),
    );
  }
}
