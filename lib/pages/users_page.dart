import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/pages/post_page.dart';
import '../database/firestore.dart';

class UsersPage extends StatefulWidget {
  UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController editingController = TextEditingController();
  String searchText="";

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Dodaj GestureDetector jako rodzica Scaffoldu
      onTap: () {
        FocusScope.of(context).unfocus(); // Schowaj klawiaturę po dotknięciu ekranu
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.list),
          title: Text("Lista ogłoszeń"),
        ),
        body: Column(
          children: [
            Container(
              child: TextField(controller: editingController,),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  searchText=editingController.text;
                });
              },
            ),
            SizedBox(height: 10,),
            Expanded(
              child: StreamBuilder(
                stream: database.getPostSearchStream(searchText),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final List<DocumentSnapshot> posts =
                  snapshot.data!.docs as List<DocumentSnapshot>;
                  if (posts.isEmpty) {
                    return Center(
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
                      String userEmail = post['UserEmail']; // Dodaj pobieranie adresu URL zdjęcia

                      return GestureDetector(
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(message + "\n" + userEmail),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostPage(
                                  title: title,
                                  message: message,
                                  userEmail: userEmail,
                                  id: post.id,
                                ),
                              ),
                            );
                          },
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
                  Navigator.pushNamed(context, '/home_page');
                },
              ),
              IconButton(
                icon: Icon(Icons.diversity_1),
                onPressed: () {
                  Navigator.pushNamed(context, '/coop');
                },
              ),
              Icon(Icons.list, color: Colors.blue),
              IconButton(
                icon: Icon(Icons.list_alt),
                onPressed: () {
                  Navigator.pushNamed(context, '/offers');
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile_page');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
