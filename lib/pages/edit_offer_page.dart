import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_back_button.dart';
import 'package:ogloszenia/database/firestore.dart';
import 'package:ogloszenia/pages/offer_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../components/my_back2_button.dart';

class EditMyOfferPage extends StatefulWidget {
  final String oldTitle;
  final String oldPost;
  final String postID;
  final String oldUrl;

  EditMyOfferPage({
    Key? key,
    required this.oldTitle,
    required this.oldPost,
    required this.postID,
    required this.oldUrl,
  }) : super(key: key);

  @override
  _EditMyOfferPageState createState() => _EditMyOfferPageState();
}

class _EditMyOfferPageState extends State<EditMyOfferPage> {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newTitleController = TextEditingController();
  final TextEditingController newPostController = TextEditingController();
  File? _image;
  String photoUrl = '';
  String? email = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    newTitleController.text = widget.oldTitle;
    newPostController.text = widget.oldPost;
    photoUrl = widget.oldUrl;
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<File> compressImage(File imageFile) async {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    // Zmniejsz rozmiar zdjęcia do maksymalnej szerokości 200 pikseli
    img.Image resizedImage = img.copyResize(image!, width: 200, height: 200);

    // Zapisz zmniejszone zdjęcie do pliku tymczasowego
    final tempDir = await Directory.systemTemp;
    final compressedImageFile = File('${tempDir.path}/compressed_image.jpg')
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 50));

    return compressedImageFile;
  }

  Future<void> _uploadImageAndSave() async {
    if (_image != null) {
      // Zmniejsz rozmiar zdjęcia przed przesłaniem do Firebase Storage
      File compressedImage = await compressImage(_image!);
      // Prześlij zmniejszone zdjęcie do Firebase Storage i uzyskaj jego URL
      photoUrl = await database.uploadImageToFirebaseStorage(compressedImage);
    }

    // Zaktualizuj link URL w bazie danych
    database.updateOfferUrl(widget.postID, photoUrl);
  }

  Future<void> _deleteOffer(BuildContext context) async {
    bool? delete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Czy na pewno chcesz usunąć ofertę?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Usuń ofertę
              },
              child: Text(
                "Tak",
                style: TextStyle(color: Colors.red), // Kolor czerwony dla 'Tak'
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Nie usuwaj oferty
              },
              child: Text("Nie"),
            ),
          ],
        );
      },
    );

    if (delete == true) {
      await database.deleteOffer(widget.postID);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Usunięto twoją ofertę."),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushNamed(context, '/offers'); // Wróć do poprzedniego widoku po usunięciu oferty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: newTitleController,
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        controller: newPostController,
                      ),
                      SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () async {
                          final source = await showDialog<ImageSource>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Wybierz źródło"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, ImageSource.gallery);
                                    },
                                    child: Text("Galeria"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, ImageSource.camera);
                                    },
                                    child: Text("Aparat"),
                                  ),
                                ],
                              );
                            },
                          );
                          if (source != null) {
                            await getImage(source);
                          }
                        },
                        child: _image != null
                            ? Image.file(
                          _image!,
                          width: MediaQuery.of(context).size.width,
                          height: 200.0,
                          fit: BoxFit.cover,
                        )
                            : Image.network(
                          widget.oldUrl,
                          width: MediaQuery.of(context).size.width,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyBack2Button(),
                  ElevatedButton(
                    onPressed: () async {
                      await _deleteOffer(context);
                    },
                    child: Text("Usuń"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Kolor czerwony dla przycisku "Usuń"
                  ),
                  MaterialButton(
                    onPressed: () async {
                      await _uploadImageAndSave();

                      String newTitle = newTitleController.text;
                      String newPost = newPostController.text;

                      if (newTitle.isNotEmpty || newPost.isNotEmpty) {
                        await database.updateOfferName(widget.postID, newTitle);
                        await database.updateOfferText(widget.postID, newPost);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Zmiany zostały zapisane"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OfferPage(
                              title: newTitle,
                              message: newPost,
                              offerID: widget.postID,
                              photoUrl: photoUrl,
                              userEmail: email!,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Nic nie zmieniono"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Text("Zapisz"),
                    color: Colors.white10,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
