import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../database/firestore.dart';
import 'my_post_page.dart';

class EditMyPostPage extends StatefulWidget {
  final String postID;

  EditMyPostPage({Key? key, required this.postID}) : super(key: key);

  @override
  _EditMyPostPageState createState() => _EditMyPostPageState();
}

class _EditMyPostPageState extends State<EditMyPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FirestoreDatabase database = FirestoreDatabase();
  final FocusNode _focusNode = FocusNode();
  List<String> _photoUrls = [];
  List<File> _newPhotos = []; // Lista nowych zdjęć do dodania
  List<String> _photosToDelete = []; // Lista zdjęć do usunięcia

  @override
  void initState() {
    super.initState();
    database.getPostData(widget.postID).then((postData) {
      if (postData != null) {
        setState(() {
          _titleController.text = postData.title;
          _messageController.text = postData.message;
          _photoUrls = postData.photoUrls;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edytuj post'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Tytuł'),
                  focusNode: _focusNode,
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(labelText: 'Opis'),
                  maxLines: null,
                  focusNode: _focusNode,
                ),
                SizedBox(height: 16.0),
                _buildPhotoGallery(),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _editPost,
                    child: Text(
                      'Zapisz zmiany',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _photoUrls.length + 1,
        itemBuilder: (context, index) {
          if (index < _photoUrls.length) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImagePage(
                            imageUrl: _photoUrls[index],
                            postID: widget.postID,
                            photoID: index.toString(),
                          ),
                        ),
                      );
                    },
                    child: Image.network(_photoUrls[index]),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      _confirmDeletePhoto(context, index);
                    },
                  ),
                ),
              ],
            );
          } else {
            return GestureDetector(
              onTap: _showAddPhotoOptions,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.grey[300],
                  width: 100,
                  height: 100,
                  child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey[700]),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmDeletePhoto(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Usuń zdjęcie'),
        content: Text('Czy na pewno chcesz usunąć to zdjęcie?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _markPhotoForDeletion(index);
            },
            child: Text('Usuń'),
          ),
        ],
      ),
    );
  }

  void _markPhotoForDeletion(int index) {
    setState(() {
      _photosToDelete.add(_photoUrls[index]);
      _photoUrls.removeAt(index);
    });
  }

  void _showAddPhotoOptions() {
    if (_photoUrls.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Można dodać maksymalnie 3 zdjęcia.'),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Wybierz z galerii'),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Zrób zdjęcie'),
            onTap: () {
              Navigator.pop(context);
              _takePhoto();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _addPhoto(File(pickedFile.path));
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _addPhoto(File(pickedFile.path));
    }
  }

  Future<void> _addPhoto(File file) async {
    final img.Image? image = img.decodeImage(file.readAsBytesSync());

    if (image != null) {
      // Zmniejsz rozmiar zdjęcia
      final img.Image resized = img.copyResize(image, width: 200, height: 200);

      // Zapisz zmniejszone zdjęcie do pliku tymczasowego
      final String tempPath = '${file.parent.path}/resized_${file.uri.pathSegments.last}';
      File(tempPath).writeAsBytesSync(img.encodeJpg(resized));

      // Prześlij zmniejszone zdjęcie do Firebase Storage
      String newUrl = await database.uploadImageToFirebaseStorage(File(tempPath));

      setState(() {
        _photoUrls.add(newUrl);
        _newPhotos.add(File(tempPath));
      });
    } else {
      throw Exception('Nie można przetworzyć obrazu');
    }
  }

  void _editPost() {
    String newTitle = _titleController.text.trim();
    String newMessage = _messageController.text.trim();

    // Sprawdź, czy jest co najmniej jedno zdjęcie
    if (_photoUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ogłoszenie musi mieć co najmniej jedno zdjęcie.'),
        ),
      );
      return;
    }

    database.editPost(widget.postID, newTitle, newMessage).then((_) {
      // Usuń zdjęcia oznaczone do usunięcia
      for (String photoUrl in _photosToDelete) {
        database.deletePhotoFromPost(widget.postID, photoUrl);
      }

      // Dodaj nowe zdjęcia
      if (_newPhotos.isNotEmpty) {
        database.addPhotosToPost(widget.postID, _newPhotos).then((_) {
          _navigateToPostPage();
        });
      } else {
        _navigateToPostPage();
      }
    });
  }

  void _navigateToPostPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyPostPage(
          postID: widget.postID,
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String postID;
  final String photoID;

  FullScreenImagePage({
    required this.imageUrl,
    required this.postID,
    required this.photoID,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
