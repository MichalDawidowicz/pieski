import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_drawer.dart';
import 'package:ogloszenia/pages/offer_page.dart';
import 'package:ogloszenia/pages/post_page.dart';

import '../database/firestore.dart';

class OffersPage extends StatelessWidget {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController editingController = TextEditingController();
  OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.list_alt),
        title: Text("lista ofert"),
      ),

      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
                stream: database.getOfferStream(),
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
                            String name = post['OfferName'];
                            String text = post['OfferText'];
                            String userEmail = post['UserEmail'];
                            // String url = post['Photo'];

                            return GestureDetector(
                              child: ListTile(
                                title: Text(name),
                                subtitle: Text(text + "\n" + userEmail),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OfferPage(
                                        title: name,
                                        message: text,
                                        userEmail: userEmail,
                                        photoUrl: post['OfferPhoto'],
                                        offerID: post.id,
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
            Icon(Icons.list_alt,color: Colors.blue,),
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

