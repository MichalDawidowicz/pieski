import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ogloszenia/components/my_textfield.dart';
import 'package:image_picker/image_picker.dart';
import '../components/my_back3_button.dart';
import '../database/firestore.dart';
import 'edit_my_post.dart';
import 'my_post_page.dart';
import 'package:image/image.dart' as img; // Import biblioteki image

class EditMyPostPage extends StatelessWidget {
  final String oldTitle;
  final String oldPost;
  final String postID;
  final String oldUrl;
  EditMyPostPage({
    super.key, required this.oldTitle, required this.oldPost, required this.postID, required this.oldUrl});
  // Future String id;\
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newTitleController = TextEditingController();

  final TextEditingController newPostController = TextEditingController();
  // File? _image;
  //
  // Future<File> compressImage(File imageFile) async {
  //   img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
  //
  //   // Zmniejsz rozmiar zdjęcia do maksymalnej szerokości 800 pikseli
  //   img.Image resizedImage = img.copyResize(image!, width: 200,height: 200);
  //
  //   // Zapisz zmniejszone zdjęcie do pliku tymczasowego
  //   final tempDir = await Directory.systemTemp;
  //   final compressedImageFile = File('${tempDir.path}/compressed_image.jpg')
  //     ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 50)); // 85 to wartość jakości
  //
  //   return compressedImageFile;
  // }
  // Future getImage(ImageSource source) async {
  //   final pickedFile = await ImagePicker().pickImage(source: source);
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);
  //     } else {
  //
  //     };
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0,right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyBack3Button(),
                    // IconButton(onPressed: (){}, icon: Icon(Icons.settings),)
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextField(hintText: oldTitle, obscureText: false  , controller: newTitleController),
                      SizedBox(height: 10.0),
                      MyTextField(hintText: oldPost, obscureText: false  , controller: newPostController),
                      SizedBox(height: 10.0),
                      // Wyświetlanie zdjęcia
                      if (oldUrl.isNotEmpty)
                        Image.network(
                          oldUrl,
                          width: MediaQuery.of(context).size.width, // Ustaw szerokość zdjęcia na pełną szerokość ekranu
                          height: 200.0, // Ustaw wysokość zdjęcia na 200 pikseli (możesz dostosować do własnych preferencji)
                          fit: BoxFit.cover, // Dopasuj zdjęcie do obszaru wyświetlania
                        ),
                    ],
                  ),
                ),
              ),
              //
              // _image != null
              //     ? Image.file(_image!)
              //     : IconButton(
              //   icon: Icon(Icons.camera),
              //   onPressed: () {
              //     // Po kliknięciu ikony aparatu, użytkownik może wybrać źródło zdjęcia
              //     showModalBottomSheet(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return SafeArea(
              //           child: Column(
              //             mainAxisSize: MainAxisSize.min,
              //             children: <Widget>[
              //               ListTile(
              //                 leading: Icon(Icons.photo_library),
              //                 title: Text('Wybierz z galerii'),
              //                 onTap: () {
              //                   getImage(ImageSource.gallery);
              //                   Navigator.pop(context);
              //                 },
              //               ),
              //               ListTile(
              //                 leading: Icon(Icons.photo_camera),
              //                 title: Text('Zrób zdjęcie'),
              //                 onTap: () {
              //                   getImage(ImageSource.camera);
              //                   Navigator.pop(context);
              //                 },
              //               ),
              //             ],
              //           ),
              //         );
              //       },
              //     );
              //   },
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(onPressed: (){
                    {
                      Navigator.pushNamed(context, '/my_page');
                    }
                  },
                    child: Text("anuluj"),
                    color: Colors.white60,),
                  MaterialButton(onPressed: (){
                    if(newTitleController.text.isNotEmpty){
                      database.updatePostTitle(postID, newTitleController.text);
                      print("Zmieniono tytuł");
                    }
                    if(newPostController.text.isNotEmpty){
                      database.updatePost(postID, newPostController.text);
                      print("Zmieniono tresc");
                      // if(_image!=null){
                      //   // Zmniejsz rozmiar zdjęcia przed przesłaniem do Firebase Storage
                      //   File compressedImage = await compressImage(_image!);
                      //   // Prześlij zmniejszone zdjęcie do Firebase Storage i uzyskaj jego URL
                      //   photoUrl = await database.uploadImageToFirebaseStorage(compressedImage);
                      // }
                    }
                    else{
                      database.updateAll(postID, oldPost, oldTitle, oldUrl);
                      print("nic nie zmieniono");
                    }

                  },child: Text("zapisz"),
                    color: Colors.white10,),
        
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
