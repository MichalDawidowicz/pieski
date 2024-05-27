import 'package:flutter/material.dart';
import 'package:ogloszenia/pages/post_page.dart';
import '../database/firestore.dart';

class UsersPage extends StatelessWidget {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController editingController = TextEditingController();

  UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.list),
        title: Text("lista ogłoszeń"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: database.getPostStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final posts = snapshot.data!.docs;
                if (snapshot.data == null || posts.isEmpty) {
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
                                photoUrl: post['Photo'],
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
            Icon(Icons.list,color: Colors.blue,),
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
    );
  }
}
