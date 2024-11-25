import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_drawer.dart';
import 'package:ogloszenia/pages/offer_page.dart';
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
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    String name = post['OfferName'];
                    String text = post['OfferText'];
                    String userEmail = post['UserEmail'];

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1 * (index % 2 + 1)), // Dynamiczny kolor
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: GestureDetector(
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
                        child: ListTile(
                          title: Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "$text\n$userEmail",
                            style: TextStyle(color: Colors.black87),
                          ),
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
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.pushNamed(context, '/users_page');
              },
            ),
            Icon(
              Icons.list_alt,
              color: Colors.blue,
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
    );
  }
}
