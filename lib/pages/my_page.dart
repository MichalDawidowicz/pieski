import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/pages/my_post_page.dart';
import '../components/my_back_button.dart';
import '../database/firestore.dart';

class MyPage extends StatelessWidget {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController editingController = TextEditingController();
  MyPage({super.key});
  String? email = FirebaseAuth.instance.currentUser?.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MOJE OGŁOSZENIA"),
        leading: MyBackButton(),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 1
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
                stream: database.getUserPostStream(email!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final posts = snapshot.data!.docs;
                  print(posts);
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
                            String postID = post.id;

                            return GestureDetector(
                              child: ListTile(
                                title: Text(title),
                                subtitle: Text(message + "\n" + userEmail),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyPostPage(
                                        postID: postID,
                                        title: title,
                                        message: message,
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

