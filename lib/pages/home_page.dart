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
  bool _isPosting = false;

  Future<File> compressImage(File imageFile) async {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    img.Image resizedImage = img.copyResize(image!, width: 200, height: 200);
    final tempDir = await Directory.systemTemp;
    final compressedImageFile = File('${tempDir.path}/compressed_image.jpg')
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 50));
    return compressedImageFile;
  }

  bool isButtonEnabled() {
    return titleController.text.isNotEmpty &&
        postController.text.isNotEmpty &&
        _images.isNotEmpty;
  }

  Future<void> postMessage() async {
    if (isButtonEnabled()) {
      setState(() {
        _isPosting = true;
      });

      // Wyświetlenie dialogu z komunikatem
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Dodawanie wpisu, czekaj..."),
              ],
            ),
          );
        },
      );

      String title = titleController.text;
      String post = postController.text;
      List<String> photoUrls = [];

      for (File image in _images) {
        File compressedImage = await compressImage(image);
        String photoUrl =
        await database.uploadImageToFirebaseStorage(compressedImage);
        photoUrls.add(photoUrl);
      }

      await database.addPostWithPhotos(
          Post(title: title, post: post, photoUrls: photoUrls));

      Navigator.pop(context); // Zamknij dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dodano wpis')),
      );

      titleController.clear();
      postController.clear();
      setState(() {
        _images.clear();
        _isPosting = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UsersPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tytuł, treść i co najmniej jedno zdjęcie są wymagane'),
        ),
      );
    }
  }

  Future<void> pickImage(ImageSource source) async {
    if (_images.length < 3) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie wybrano zdjęcia')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Możesz dodać maksymalnie 3 zdjęcia')),
      );
    }
  }

  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> changeImage(int index) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
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
                                      title: Text('Zrób zdjęcie ponownie'),
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
                icon: Icon(Icons.camera_alt, size: 30),
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
                onTap: _isPosting ? null : postMessage,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add_offer');
                },
                child: Text("Chcesz dodać ofertę? Kliknij tutaj"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
