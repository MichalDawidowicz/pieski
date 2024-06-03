import 'dart:io';

import 'package:flutter/material.dart';
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
        itemCount: _photoUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImagePage(
                      imageUrl: _photoUrls[index],
                    ),
                  ),
                );
              },
              child: Image.network(_photoUrls[index]),
            ),
          );
        },
      ),
    );
  }

  void _editPost() {
    String newTitle = _titleController.text.trim();
    String newMessage = _messageController.text.trim();

    database.editPost(widget.postID, newTitle, newMessage).then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyPostPage(
            postID: widget.postID,
          ),
        ),
      );
    });
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  FullScreenImagePage({required this.imageUrl});

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
