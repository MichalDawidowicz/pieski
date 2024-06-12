import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ogloszenia/components/backToMyPage.dart';
import 'package:ogloszenia/components/back_prev.dart';
import 'package:ogloszenia/pages/opinie.dart';

class Wolontariusz extends StatefulWidget {
  final String userEmail;

  Wolontariusz({Key? key, required this.userEmail}) : super(key: key);

  @override
  _WolontariuszState createState() => _WolontariuszState();
}

class _WolontariuszState extends State<Wolontariusz> {
  bool isLoading = false;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.userEmail)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserOpinionsStream() {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userEmail)
        .collection('opinie')
        .snapshots();
  }

  double calculateAverageRating(QuerySnapshot<Map<String, dynamic>> snapshot) {
    double averageRating = 0;
    int totalRatings = 0;
    for (DocumentSnapshot<Map<String, dynamic>> document in snapshot.docs) {
      Map<String, dynamic> data = document.data()!;
      int rating = data['rating'];
      averageRating += rating;
      totalRatings++;
    }
    if (totalRatings > 0) {
      averageRating /= totalRatings;
    }
    return averageRating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text("Błąd: ${snapshot.error}");
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            return Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 50.0, left: 25),
                    child: Row(
                      children: [
                        BackPrev(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "Profil",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black26,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    user!['email'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  if (user.containsKey('Info') && user['Info'] != null)
                    Column(
                      children: [
                        const Text(
                          'Opis wolontariusza:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                user['Info'],
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (!user.containsKey('Info') || user['Info'] == null)
                    const Text(
                      'Brak opisu wolontariusza',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 25),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: getUserOpinionsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Błąd: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        double averageRating =
                        calculateAverageRating(snapshot.data!);
                        int roundedRating = averageRating.round();
                        List<Widget> starIcons = [];
                        for (int i = 0; i < roundedRating; i++) {
                          starIcons.add(Icon(Icons.star, color: Colors.yellow));
                        }
                        return Column(
                          children: [
                            Text(
                              'Średnia ocena: ${averageRating.toStringAsFixed(1)}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 5),
                            Center(
                              child: Row(
                                children: [
                                  ...starIcons,
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Recenzje:"),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: snapshot.data!.docs.map((DocumentSnapshot<dynamic> document) {
                                Map<String, dynamic> data = document.data()!;
                                int stars = data['rating'];
                                String description = data['comment'] ?? '';
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Ocena: $stars'),
                                      if(description.isNotEmpty)
                                        Text('Opis: $description'),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ],
              ),
            );
          } else {
            return Text("Brak danych");
          }
        },
      ),
    );
  }
}
