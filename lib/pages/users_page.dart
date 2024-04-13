import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_drawer.dart';
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
        title: Text("LISTA OGŁOSZEŃ"),
        // leading: MyBackButton(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 1,
        // actions: [
        //   //logout
        //   IconButton(
        //     onPressed: logout,
        //     icon: Icon(Icons.logout),
        //   )
        // ],
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
            stream: database.getPostStream(),
            builder: (context, snapshot) {
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
              return Expanded(
                  child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        String title = post['PostTitle'];
                        String message = post['PostMessage'];
                        String userEmail = post['UserEmail'];
                        // String url = post['Photo'];

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
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }));
            },
          )),
        ],
      ),
    );
  }
}

