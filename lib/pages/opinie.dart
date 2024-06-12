import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class OpiniePage extends StatelessWidget {
  final String userEmail;

  OpiniePage({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opinie'),
      ),
      body: OpinieList(userEmail: userEmail),
    );
  }
}
class OpinieList extends StatelessWidget {
  final String userEmail;

  OpinieList({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('opinie')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Wystąpił błąd: ${snapshot.error}'));
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Brak opinii'));
        }

        // Obliczenie średniej oceny
        double averageRating = 0;
        double totalRatings = 0;
        for (DocumentSnapshot document in snapshot.data!.docs) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          int rating = data['rating'];
          averageRating += rating;
          totalRatings++;
        }
        averageRating /= totalRatings;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: Text(
                'Średnia ocena: ${averageRating.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  int stars = data['rating'];
                  String description = data['comment'] ?? '';

                  return ListTile(
                    title: Text('Ocena: $stars'),
                    subtitle: description.isNotEmpty ? Text('Opis: $description') : null,
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
