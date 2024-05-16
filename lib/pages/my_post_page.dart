import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/backToMyPage.dart';
import 'package:ogloszenia/pages/wolontariusz.dart';

import '../components/my_back3_button.dart';
import '../database/firestore.dart';
import 'edit_my_post.dart';

class MyPostPage extends StatelessWidget {
  final String title;
  final String message;
  final String postID;
  final String photoUrl;
  final String state;
  final String vol;
  // final String uemail;
  MyPostPage({
    super.key,
    required this.title,
    required this.message,
    required this.postID,
    required this.photoUrl,
    required this.state, required this.vol,
    // required this.uemail
  });
  final FirestoreDatabase database = FirestoreDatabase();


  void _deletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Potwierdzenie"),
          content: Text("Czy na pewno chcesz usunąć ogłoszenie?"),
          actions: [
            TextButton(
              onPressed: () {
                database.deletePost(postID);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Tak", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Nie", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackToMyPage(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMyPostPage(
                          postID: postID,
                          oldPost: message,
                          oldTitle: title,
                          oldUrl: photoUrl,
                          state: state,
                          vol: vol,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () => _deletePost(context),
                  icon: Icon(Icons.delete),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "Wiadomość:  $message",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10.0),
                  if (photoUrl.isNotEmpty)
                    Image.network(
                      photoUrl,
                      width: MediaQuery.of(context).size.width,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  SizedBox(height: 10.0),
                  if (state == 'zarezerwowane')
                    Column(
                      children: [
                        GestureDetector(onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Wolontariusz(userEmail: vol),
                            ),
                          );
                        },
                            child: Text('Wolontariusz: $vol',
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                database.updateState(postID, 'sprzedano');
                                Navigator.pushNamed(context, '/my_page');
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 10.0)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      )
                                  )
                              ),
                              child: Text('Zaakceptuj współpracę', style: TextStyle(color: Colors.black)),
                            ),
                            SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: () {
                                print(FirebaseAuth.instance.currentUser!.uid);
                                database.updateState(postID, 'nowe');
                                Navigator.pushNamed(context, '/my_page');
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                side: BorderSide(color: Colors.black),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                              child: Text('Odrzuć współpracę', style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
