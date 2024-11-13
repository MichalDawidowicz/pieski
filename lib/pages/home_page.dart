import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ogloszenia/components/back_to_home.dart';
import 'package:ogloszenia/components/my_back_button.dart';
import 'package:ogloszenia/components/my_post_button.dart';
import 'package:ogloszenia/components/my_textfield.dart';
import 'package:ogloszenia/database/firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img; // Import biblioteki image
import 'package:ogloszenia/pages/users_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Post {
  String title;
  String post;
  List<String> photoUrls;

  Post({required this.title, required this.post, this.photoUrls = const []});
}

class _HomePageState extends State<HomePage> {
  final FirestoreDatabase database = FirestoreDatabase();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController postController = TextEditingController();
  List<File> _images = [];
  bool _isPosting = false; // Dodajemy zmienną _isPosting

  // Funkcja do zmniejszenia rozmiaru zdjęcia
  Future<File> compressImage(File imageFile) async {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    // Zmniejsz rozmiar zdjęcia na 200x200px
    img.Image resizedImage = img.copyResize(image!, width: 200, height: 200);

    // Zapisz zmniejszone zdjęcie do pliku tymczasowego
    final tempDir = await Directory.systemTemp;
    final compressedImageFile = File('${tempDir.path}/compressed_image.jpg')
      ..writeAsBytesSync(
          img.encodeJpg(resizedImage, quality: 50)); // 85 to wartość jakości

    return compressedImageFile;
  }

  bool isButtonEnabled() {
    // Sprawdź, czy tytuł, opis i przynajmniej jedno zdjęcie zostało dodane
    return titleController.text.isNotEmpty &&
        postController.text.isNotEmpty &&
        _images.isNotEmpty;
  }

  Future<void> postMessage() async {
    if (isButtonEnabled()) {
      setState(() {
        _isPosting = true; // Ustawiamy _isPosting na true podczas dodawania wpisu
      });

      String title = titleController.text;
      String post = postController.text;
      List<String> photoUrls = [];

      // Prześlij każde zdjęcie do Firebase Storage i uzyskaj jego URL
      for (File image in _images) {
        File compressedImage = await compressImage(image);
        String photoUrl = await database.uploadImageToFirebaseStorage(
            compressedImage);
        photoUrls.add(photoUrl);
      }

      // Dodaj post z listą URL-i zdjęć
      await database.addPostWithPhotos(
          Post(title: title, post: post, photoUrls: photoUrls));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dodano wpis'),
          duration: Duration(seconds: 2),
        ),
      );

      titleController.clear();
      postController.clear();
      setState(() {
        _images.clear();
        _isPosting = false; // Po dodaniu wpisu, ustawiamy _isPosting z powrotem na false
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UsersPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tytuł, treść i co najmniej jedno zdjęcie są wymagane'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Funkcja do pobrania zdjęcia z galerii lub z aparatu
  Future<void> pickImage(ImageSource source) async {
    if (_images.length < 3) {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nie wybrano zdjęcia '),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Możesz dodać maksymalnie 3 zdjęcia'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Funkcja do usuwania zdjęcia
  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // Funkcja do zmiany zdjęcia
  Future<void> changeImage(int index) async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _images[index] = File(pickedFile.path);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Wyłącz klawiaturę po dotknięciu ekranu poza obszarem klawiatury
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Dodaj ogłoszenie"),
          leading: BackToHome(),
          elevation: 1,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(25),
                child: MyTextField(
                  hintText: "Tytuł",
                  obscureText: false,
                  controller: titleController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: MyTextField(
                  hintText: "Treść",
                  obscureText: false,
                  controller: postController,
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Pokaż listę opcji dla klikniętego zdjęcia
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.delete),
                                      title: Text('Usuń zdjęcie'),
                                      onTap: () {
                                        removeImage(index);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.camera_alt),
                                      title: Text('Wykonaj zdjęcie ponownie'),
                                      onTap: () {
                                        changeImage(index);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          width: 150,
                          child: Image.file(_images[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.camera),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Wybierz z galerii'),
                              onTap: () {
                                pickImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_camera),
                              title: Text('Zrób zdjęcie'),
                              onTap: () {
                                pickImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              MyPostButton(
                onTap: _isPosting ? null : postMessage, // Dodaj logikę do przycisku
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add_offer');
                },
                child: Text("Chcesz dodać ofertę? Kliknij tutaj"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
