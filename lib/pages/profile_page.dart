import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../database/firestore.dart';
import 'opinie.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool isLoading = false;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  void showEditDialog(BuildContext context, String email, String? currentInfo) {
    final TextEditingController aboutMeController = TextEditingController(text: currentInfo);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Opowiedz o sobie"),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8, // 80% szerokości ekranu
            child: TextField(
              controller: aboutMeController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(hintText: "Wpisz coś o sobie"),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Anuluj", style: TextStyle(color: Colors.black)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Zapisz"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
              ),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                Navigator.of(context).pop();
                await FirestoreDatabase().updateProfile(email, aboutMeController.text);
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Wylogowanie"),
          content: Text("Czy na pewno chcesz się wylogować?"),
          actions: <Widget>[
            TextButton(
              child: Text("Anuluj", style: TextStyle(color: Colors.grey)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Wyloguj"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pushNamed(context, '/auth_page');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text("Błąd: ${snapshot.error}");
            } else if (snapshot.hasData) {
              Map<String, dynamic>? user = snapshot.data!.data();
              String info = user?['Info'] ?? 'Napisz coś o sobie';
              return SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0, left: 25, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.person),
                            IconButton(
                              icon: Icon(Icons.logout),
                              onPressed: logout,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      const Text(
                        "Profil",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black26,
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        user!['email'],
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 25),
                      Text(
                        "Opowiedz o sobie",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          showEditDialog(context, user['email'], info);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8, // 80% szerokości ekranu
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            info,
                            style: TextStyle(fontSize: 16, color: info == 'Napisz coś o sobie' ? Colors.grey : Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/my_page');
                        },
                        child: Text('Moje ogłoszenia', style: TextStyle(color: Colors.black)),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OpiniePage(userEmail: user['email']),
                            ),
                          );
                        },
                        child: Text('Opinie', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Text("Brak danych");
            }
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.pushNamed(context, '/home_page');
                },
              ),
              IconButton(
                icon: Icon(Icons.diversity_1),
                onPressed: () {
                  Navigator.pushNamed(context, '/coop');
                },
              ),
              IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  Navigator.pushNamed(context, '/users_page');
                },
              ),
              IconButton(
                icon: Icon(Icons.list_alt),
                onPressed: () {
                  Navigator.pushNamed(context, '/offers');
                },
              ),
              Icon(Icons.settings, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
