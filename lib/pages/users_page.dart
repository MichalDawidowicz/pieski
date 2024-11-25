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
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Schowaj klawiaturę po dotknięciu ekranu
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lista ogłoszeń")
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: editingController,
                      decoration: InputDecoration(
                        hintText: "Szukaj...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        searchText = editingController.text;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
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
                      String userEmail = post['UserEmail'];

                      return GestureDetector(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1 * (index % 2 + 1)), // Zmienny kolor
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blueAccent),
                          ),
                          child: ListTile(
                            title: Text(
                              title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "$message",
                              style: TextStyle(color: Colors.black87),
                            ),
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
                icon: Icon(Icons.person),
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
