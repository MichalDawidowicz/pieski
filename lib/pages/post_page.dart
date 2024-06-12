import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/back_to_home.dart';
import 'package:ogloszenia/database/firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PostPage extends StatelessWidget {
  final String title;
  final String message;
  final String userEmail;
  final String id;

  const PostPage({
    Key? key,
    required this.title,
    required this.message,
    required this.userEmail,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreDatabase database = FirestoreDatabase();
    String? loggedInUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: database.getPostState(id),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              String postState = snapshot.data ?? "";
              bool isPostReserved = postState == "zarezerwowane";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BackToHome(),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "Ogłoszenie",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0),
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
                        Text(
                          "Adres email: $userEmail",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10.0),
                        // Galeria zdjęć z kolekcji 'Photos'
                        FutureBuilder<List<String>>(
                          future: database.getPhotosForPost(id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              // Dodaj warunek sprawdzający czy snapshot zawiera dane
                              List<String>? photoUrls = snapshot.data;
                              if (photoUrls != null && photoUrls.isNotEmpty) {
                                return SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: photoUrls.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => FullScreenImageGallery(
                                                  imageUrls: photoUrls,
                                                  initialIndex: index,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Image.network(
                                            photoUrls[index],
                                            width: 150,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return SizedBox
                                    .shrink(); // Brak zdjęć, zwróć pusty widżet
                              }
                            } else {
                              return Text(
                                  'Brak danych zdjęć'); // Dodaj komunikat informujący o braku danych
                            }
                          },
                        ),
                        SizedBox(height: 10.0),
                        // Dodaj warunek wyświetlania przycisku "Edytuj ofertę"
                        if (isPostReserved)
                          Text(
                            "Zarezerwowane",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        if (!isPostReserved &&
                            loggedInUserEmail != null &&
                            loggedInUserEmail != userEmail)
                          GestureDetector(
                            child: Text("Zgłoś chęć"),
                            onTap: () async {
                              // Zmiana stanu w bazie danych
                              await database.changeState(id, "zarezerwowane", loggedInUserEmail);

                              // Odświeżenie strony
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => PostPage(
                                    title: title,
                                    message: message,
                                    userEmail: userEmail,
                                    id: id,
                                  ),
                                ),
                              );

                              // Oczekiwanie na odświeżenie strony, a następnie wyświetlenie komunikatu
                              Future.delayed(Duration.zero, () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Zgłoszono chęć współpracy"),
                                    duration: Duration(seconds: 2), // Czas wyświetlania komunikatu
                                  ),
                                );
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class FullScreenImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageGallery({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenImageGalleryState createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      appBar: AppBar(
        backgroundColor: Colors.black26,
        leading: IconButton(
          icon: Icon(Icons.close,color: Colors.white70,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imageUrls[index]),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        pageController: PageController(initialPage: widget.initialIndex),
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: EdgeInsets.all(20),
        child: Text(
          '${currentIndex + 1} / ${widget.imageUrls.length}',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
