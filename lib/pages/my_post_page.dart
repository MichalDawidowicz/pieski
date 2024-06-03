import 'package:flutter/material.dart';
import 'package:ogloszenia/components/backToMyPage.dart';
import 'package:ogloszenia/pages/wolontariusz.dart';
import '../database/firestore.dart';
import 'edit_my_post.dart';

class MyPostPage extends StatefulWidget {
  final String postID;

  MyPostPage({Key? key, required this.postID}) : super(key: key);

  @override
  _MyPostPageState createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  final FirestoreDatabase database = FirestoreDatabase();
  late Future<PostData?> _postDataFuture;

  @override
  void initState() {
    super.initState();
    _postDataFuture = database.getPostData(widget.postID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<PostData?>(
          future: _postDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final postData = snapshot.data;
              if (postData != null) {
                return _buildPostPage(postData);
              } else {
                return Center(child: Text('Post data not found'));
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildPostPage(PostData postData) {
    return Column(
      children: [
        Padding(
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
                    builder: (context) => EditMyPostPage(postID: widget.postID),
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
                postData.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Text(
                "Wiadomość: ${postData.message}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10.0),
              // Wyświetlenie zdjęć
              if (postData.photoUrls.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: postData.photoUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Image.network(
                          postData.photoUrls[index],
                          width: 150,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 20.0),
              if (postData.state == 'zarezerwowane' ||
                  postData.state == 'sprzedano')
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Wolontariusz(userEmail: postData.vol),
                          ),
                        );
                      },
                      child: Text(
                        'Wolontariusz: ${postData.vol}',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    if (postData.state == 'zarezerwowane')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              database.updateState(widget.postID, 'sprzedano');
                              Navigator.pushNamed(context, '/my_page');
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(horizontal: 10.0)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                            ),
                            child: Text('Zaakceptuj współpracę',
                                style: TextStyle(color: Colors.black)),
                          ),
                          SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () {
                              database.updateState(widget.postID, 'nowe');
                              Navigator.pushNamed(context, '/my_page');
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              side: BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            child: Text('Odrzuć współpracę',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    if (postData.state == 'sprzedano')
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _endCooperation(context),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                                    EdgeInsets.symmetric(horizontal: 10.0)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                          ),
                          child: Text('Zakończ współpracę',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

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
                database.deletePost(widget.postID);
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

  void _endCooperation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Zakończenie współpracy"),
          content: Text("Czy na pewno chcesz zakończyć współpracę?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context); // Zamknięcie okna dialogowego potwierdzenia
                _addOpinion(context); // Wywołanie metody do dodania opinii
              },
              child: Text("Tak", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Zamknięcie okna dialogowego
              },
              child: Text("Nie", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _addOpinion(BuildContext context) {
    TextEditingController starsController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Dodaj opinię"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: starsController,
                  decoration:
                  InputDecoration(labelText: 'Liczba gwiazdek (0-5)'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration:
                  InputDecoration(labelText: 'Opis (opcjonalnie)'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                int stars = int.tryParse(starsController.text) ?? 0;
                String description = descriptionController.text.trim();

                // Sprawdzanie, czy liczba gwiazdek mieści się w zakresie 0-5
                if (stars >= 0 && stars <= 5) {
                  // Pobranie danych z bazy danych na podstawie postID
                  database.getPostData(widget.postID).then((postData) {
                    if (postData != null) {
                      // Dodanie opinii do bazy danych
                      database.addOpinion(postData.vol, stars, description)
                          .then((_) {
                        // Po dodaniu opinii, aktualizacja stanu ogłoszenia i nawigacja do strony my_page
                        database.updateState(widget.postID, 'nowe');
                        Navigator.pushNamed(context, '/my_page');
                      });
                      Navigator.pop(context); // Zamknięcie okna dialogowego
                    } else {
                      // Obsługa sytuacji, gdy dane postu nie zostały znalezione
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Dane postu nie zostały znalezione.'),
                      ));
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                    Text('Liczba gwiazdek musi być w zakresie od 0 do 5.'),
                  ));
                }
              },
              child: Text("Dodaj"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Zamknięcie okna dialogowego
              },
              child: Text("Anuluj"),
            ),
          ],
        );
      },
    );
  }

}

class PostData {
  final String title;
  final String message;
  final List<String> photoUrls;
  final String state;
  final String vol;

  PostData({
    required this.title,
    required this.message,
    required this.photoUrls,
    required this.state,
    required this.vol,
  });
}
