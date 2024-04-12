import 'package:flutter/material.dart';
import '../components/my_back_button.dart';
import '../database/firestore.dart';

class MyPage extends StatelessWidget {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController editingController = TextEditingController();
  MyPage({super.key});

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

                            return GestureDetector(
                              child: ListTile(
                                title: Text(title),
                                subtitle: Text(message + "\n" + userEmail),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/my_post_page');
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

