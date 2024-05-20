import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/back_to_home.dart';
import 'package:ogloszenia/pages/my_post_page.dart';
import '../components/my_back_button.dart';
import '../database/firestore.dart';

class Coop extends StatelessWidget {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController editingController = TextEditingController();
  Coop({Key? key});
  String? email = FirebaseAuth.instance.currentUser?.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.diversity_1),
        title: Text("MOJE WSPÓŁPRACE"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: database.getUserCoopStream(email!),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    String title = post['PostTitle'];
                    String message = post['PostMessage'];
                    String userEmail = post['UserEmail'];
                    String postID = post.id;
                    String state = post['PostState'];

                    String trailingText = state == 'nowe' ? 'Właściciel odrzucił twoją ofertę' : state;

                    return Dismissible(
                      key: Key(postID), // unikalny klucz dla każdego elementu
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        if (state != 'nowe') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Tego wpisu nie można usunąć."),
                            ),
                          );
                          return false;
                        }
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Potwierdzenie"),
                              content: Text("Czy na pewno chcesz usunąć ten wpis?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text("Anuluj"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text("Usuń"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        // Usuń wpis z bazy danych
                        database.deletEmail(postID);
                      },
                      child: GestureDetector(
                        onTap: () {},
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(message + "\n" + userEmail),
                          trailing: Text(trailingText),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home_page');
              },
            ),
            Icon(Icons.diversity_1,color: Colors.blue,),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/users_page');
              },
            ),
            IconButton(
              icon: Icon(Icons.list_alt),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/offers');
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile_page');
              },
            ),
          ],
        ),
      ),
    );
  }
}
