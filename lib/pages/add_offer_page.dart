import 'package:flutter/material.dart';
import 'package:ogloszenia/components/my_back_button.dart';
import 'package:ogloszenia/components/my_post_button.dart';
import 'package:ogloszenia/components/my_textfield.dart';
import 'package:ogloszenia/database/firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img; // Import biblioteki image
import 'package:ogloszenia/pages/users_page.dart';

import '../components/back_to_home.dart';

class AddOffer extends StatefulWidget {
  AddOffer({super.key});

  @override
  State<AddOffer> createState() => _AddOfferState();
}

class _AddOfferState extends State<AddOffer> {
  final FirestoreDatabase database = FirestoreDatabase();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController postController = TextEditingController();
  File? _image;

  bool isButtonEnabled() {
    // Sprawdź, czy tytuł, opis i zdjęcie zostały dodane
    return titleController.text.isNotEmpty &&
        postController.text.isNotEmpty &&
        _image != null;
  }

  void postMessage() async {
    //post only if title, message, and photoUrl is not empty
    if (titleController.text.isNotEmpty &&
        postController.text.isNotEmpty &&
        _image != null) {
      String title = titleController.text;
      String post = postController.text;
      String photoUrl = "";

      // Zmniejsz rozmiar zdjęcia przed przesłaniem do Firebase Storage
      File compressedImage = await compressImage(_image!);
      // Prześlij zmniejszone zdjęcie do Firebase Storage i uzyskaj jego URL
      photoUrl =
      await database.uploadImageToFirebaseStorage(compressedImage);

      database.addOffer(title, post, photoUrl);

      // Pokaż SnackBar po zapisaniu wpisu
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dodano wpis'),
          duration: Duration(seconds: 2),
        ),
      );

      // Wyczyść pola tekstowe i ustawienia po dodaniu wpisu
      titleController.clear();
      postController.clear();
      setState(() {
        _image = null;
      });

      // Przejdź na stronę UsersPage po poprawnym dodaniu postu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UsersPage()),
      );
    } else {
      // Pokaż komunikat o błędzie, jeśli tytuł, opis lub zdjęcie jest puste
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imię, opis i zdjęcie są wymagane'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Funkcja do zmniejszenia rozmiaru zdjęcia
  Future<File> compressImage(File imageFile) async {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    // Zmniejsz rozmiar zdjęcia do maksymalnej szerokości 800 pikseli
    img.Image resizedImage = img.copyResize(image!, width: 200, height: 200);

    // Zapisz zmniejszone zdjęcie do pliku tymczasowego
    final tempDir = await Directory.systemTemp;
    final compressedImageFile = File('${tempDir.path}/compressed_image.jpg')
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 50)); // 85 to wartość jakości

    return compressedImageFile;
  }

  // Funkcja do pobrania zdjęcia z galerii lub z aparatu
  Future getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nie wybrano zdjęcia '),
            duration: Duration(seconds: 2),
          ),
        );
        // print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("dodaj ofertę"),
        leading: MyBackButton(),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25),
              child: MyTextField(
                hintText: "Imię",
                obscureText: false,
                controller: titleController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: MyTextField(
                hintText: "Opis",
                obscureText: false,
                controller: postController,
              ),
            ),
            _image != null
                ? Image.file(_image!)
                : IconButton(
              icon: Icon(Icons.camera),
              onPressed: () {
                // Po kliknięciu ikony aparatu, użytkownik może wybrać źródło zdjęcia
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
                              getImage(ImageSource.gallery);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_camera),
                            title: Text('Zrób zdjęcie'),
                            onTap: () {
                              getImage(ImageSource.camera);
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
              onTap: isButtonEnabled() ? postMessage : null,
            ),
          ],
        ),
      ),
    );
  }
}
